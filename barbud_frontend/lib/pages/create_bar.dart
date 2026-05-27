import 'package:flutter/material.dart';
import 'package:barbud_frontend/services/bar_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/ingredient.dart';

class CreateBarPage extends StatefulWidget {
  const CreateBarPage({super.key});

  @override
  State<CreateBarPage> createState() => _CreateBarPageState();
}

class _CreateBarPageState extends State<CreateBarPage>
    with WidgetsBindingObserver {
  final TextEditingController nameController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  String searchQuery = "";
  String selectedCategory = "All";

  final Set<int> selectedIngredients = {};
  late Future<List<BarIngredient>> ingredientsFuture;

  bool isCreating = false;

  @override
  void initState() {
    super.initState();
    ingredientsFuture = BarService.getAllIngredients();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    nameController.dispose();
    searchFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      searchFocusNode.unfocus();
    }

    super.didChangeAppLifecycleState(state);
  }

  List<BarIngredient> getFilteredIngredients(List<BarIngredient> ingredients) {
    var filtered = ingredients;

    if (selectedCategory != "All") {
      filtered = filtered
          .where((ingredient) => ingredient.category == selectedCategory)
          .toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (ingredient) => ingredient.name
                .toLowerCase()
                .contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    return filtered;
  }

  Future<void> createBar() async {
    const FlutterSecureStorage storage = FlutterSecureStorage();

    final userIdString = await storage.read(key: "id");
    final userId = int.tryParse(userIdString ?? "");

    final name = nameController.text.trim();

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not find your user ID. Please log in again."),
        ),
      );
      return;
    }

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a bar name."),
        ),
      );
      return;
    }

    if (selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one ingredient."),
        ),
      );
      return;
    }

    setState(() {
      isCreating = true;
    });

    try {
      await BarService.createBar(
        userId: userId,
        name: name,
        ingredientIds: selectedIngredients.toList(),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Could not create bar: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isCreating = false;
        });
      }
    }
  }

  void toggleIngredient(int ingredientId) {
    setState(() {
      if (selectedIngredients.contains(ingredientId)) {
        selectedIngredients.remove(ingredientId);
      } else {
        selectedIngredients.add(ingredientId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CreateBarHeader(),

            BarNameField(
              controller: nameController,
            ),

            CreateBarSearch(
              focusNode: searchFocusNode,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),

            Expanded(
              child: FutureBuilder<List<BarIngredient>>(
                future: ingredientsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          "Failed to load ingredients:\n${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  }

                  final ingredients = snapshot.data ?? [];

                  final categories = [
                    "All",
                    ...ingredients.map((i) => i.category).toSet().toList()
                      ..sort(),
                  ];

                  final filteredIngredients =
                      getFilteredIngredients(ingredients);

                  if (filteredIngredients.isEmpty) {
                    return const Center(
                      child: Text(
                        "No ingredients found.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      CreateBarCategoryBar(
                        selectedCategory: selectedCategory,
                        categories: categories,
                        onCategorySelected: (category) {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                      ),

                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 90),
                          itemCount: filteredIngredients.length,
                          itemBuilder: (context, index) {
                            final ingredient = filteredIngredients[index];

                            return CreateBarIngredientCard(
                              ingredient: ingredient,
                              selected: selectedIngredients
                                  .contains(ingredient.id),
                              onTap: () {
                                toggleIngredient(ingredient.id);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Colors.black,
                width: 1.5,
              ),
            ),
          ),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isCreating ? null : createBar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.black26,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: isCreating
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.4,
                      ),
                    )
                  : Text(
                      "Create Bar (${selectedIngredients.length})",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class CreateBarHeader extends StatelessWidget {
  const CreateBarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 10, 18, 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),

          const Expanded(
            child: Text(
              "Create Bar",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BarNameField extends StatelessWidget {
  final TextEditingController controller;

  const BarNameField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 1.3),
        ),
      ),
      child: TextField(
        controller: controller,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          hintText: "Bar name",
          hintStyle: const TextStyle(
            color: Colors.black,
            fontSize: 15,
          ),
          prefixIcon: const Icon(
            Icons.local_bar_outlined,
            color: Colors.black,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.black,
              width: 1.4,
            ),
            borderRadius: BorderRadius.circular(0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.black,
              width: 1.8,
            ),
            borderRadius: BorderRadius.circular(0),
          ),
        ),
      ),
    );
  }
}

class CreateBarSearch extends StatelessWidget {
  final Function(String) onChanged;
  final FocusNode focusNode;

  const CreateBarSearch({
    super.key,
    required this.onChanged,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 1.3),
        ),
      ),
      child: TextField(
        focusNode: focusNode,
        cursorColor: Colors.black,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: "Search ingredients",
          hintStyle: const TextStyle(
            color: Colors.black,
            fontSize: 15,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.black,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.black,
              width: 1.4,
            ),
            borderRadius: BorderRadius.circular(0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.black,
              width: 1.8,
            ),
            borderRadius: BorderRadius.circular(0),
          ),
        ),
      ),
    );
  }
}

class CreateBarCategoryBar extends StatelessWidget {
  final String selectedCategory;
  final List<String> categories;
  final Function(String category) onCategorySelected;

  const CreateBarCategoryBar({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 1.3,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: CreateBarCategoryChip(
                text: category,
                selected: selectedCategory == category,
                onTap: () {
                  onCategorySelected(category);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class CreateBarCategoryChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const CreateBarCategoryChip({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          border: Border.all(
            color: Colors.black,
            width: 1.3,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class CreateBarIngredientCard extends StatelessWidget {
  final BarIngredient ingredient;
  final bool selected;
  final VoidCallback onTap;

  const CreateBarIngredientCard({
    super.key,
    required this.ingredient,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? Colors.black.withOpacity(0.05) : Colors.white,
            border: Border.all(
              color: selected ? Colors.black : Colors.black.withOpacity(0.6),
              width: selected ? 2.0 : 1.4,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ingredient.name,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      ingredient.category,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                selected ? Icons.check : Icons.add,
                color: Colors.black,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}