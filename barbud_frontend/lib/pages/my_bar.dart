import 'package:flutter/material.dart';
import 'package:barbud_frontend/pages/home.dart';
import 'package:barbud_frontend/services/bar_service.dart';

import '../models/ingredient.dart';

class MyBarPage extends StatefulWidget {
  const MyBarPage({super.key});

  @override
  State<MyBarPage> createState() => _MyBarPageState();
}

class _MyBarPageState extends State<MyBarPage> with WidgetsBindingObserver {
  String searchQuery = "";
  String selectedCategory = "All";

  final Set<int> selectedIngredients = {};
  late Future<List<BarIngredient>> ingredientsFuture;

  final FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    ingredientsFuture = BarService.getAllIngredients();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Optional: unfocus keyboard when app lifecycle changes
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
          .where((ingredient) =>
              ingredient.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      drawer: const UserDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const MyBarHeader(),
            MyBarSearch(
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
                    ...ingredients
                        .map((i) => i.category)
                        .toSet()
                        .toList()
                      ..sort(),
                  ];
                  final filteredIngredients = getFilteredIngredients(ingredients);

                  if (filteredIngredients.isEmpty) {
                    return const EmptyMyBarState();
                  }

                  return Column(
                    children: [
                      MyBarCategoryBar(
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
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                          itemCount: filteredIngredients.length,
                          itemBuilder: (context, index) {
                            final ingredient = filteredIngredients[index];
                            return IngredientCard(
                              ingredient: ingredient,
                              selected:
                                  selectedIngredients.contains(ingredient.id),
                              onTap: () {
                                setState(() {
                                  if (selectedIngredients
                                      .contains(ingredient.id)) {
                                    selectedIngredients.remove(ingredient.id);
                                  } else {
                                    selectedIngredients.add(ingredient.id);
                                  }
                                });
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
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: const MyBarBottomNavBar(),
      ),
    );
  }
}

class MyBarHeader extends StatelessWidget {
  const MyBarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 1.5)),
      ),
      child: const Text(
        "My Bar",
        style: TextStyle(fontSize: 34, fontWeight: FontWeight.w400),
      ),
    );
  }
}

class MyBarSearch extends StatelessWidget {
  final Function(String) onChanged;
  final FocusNode focusNode;

  const MyBarSearch({super.key, required this.onChanged, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 1.3)),
      ),
      child: TextField(
        focusNode: focusNode,
        cursorColor: Colors.black,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: "Search ingredients",
          hintStyle: const TextStyle(color: Colors.black, fontSize: 15),
          prefixIcon: const Icon(Icons.search, color: Colors.black),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 1.4),
            borderRadius: BorderRadius.circular(0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 1.8),
            borderRadius: BorderRadius.circular(0),
          ),
        ),
      ),
    );
  }
}

class MyBarCategoryBar extends StatelessWidget {
  final String selectedCategory;
  final List<String> categories;
  final Function(String category) onCategorySelected;

  const MyBarCategoryBar({
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
              child: CategoryChip(
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

class CategoryChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
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

class EmptyMyBarState extends StatelessWidget {
  const EmptyMyBarState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black,
            width: 1.5,
          ),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_bar_outlined,
              size: 78,
              color: Colors.black,
            ),

            SizedBox(height: 22),

            Text(
              "Your bar is empty",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 10),

            Text(
              "Later, your saved ingredients will show up here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.35,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IngredientCard extends StatelessWidget {
  final BarIngredient ingredient;
  final bool selected;
  final VoidCallback onTap;

  const IngredientCard({
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
                        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ingredient.category,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Icon(selected ? Icons.check : Icons.add, color: Colors.black, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class MyBarBottomNavBar extends StatelessWidget {
  const MyBarBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.black,
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          MyBarBottomNavItem(
            icon: Icons.person_outline,
            label: "User",
            selected: false,
            hasRightBorder: true,
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
          ),

          MyBarBottomNavItem(
            icon: Icons.home_outlined,
            label: "Home",
            selected: false,
            hasRightBorder: true,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
            },
          ),

          MyBarBottomNavItem(
            icon: Icons.local_bar_outlined,
            label: "My Bar",
            selected: true,
            hasRightBorder: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class MyBarBottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool hasRightBorder;
  final VoidCallback onTap;

  const MyBarBottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.hasRightBorder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.white,
            border: Border(
              right: hasRightBorder
                  ? const BorderSide(
                      color: Colors.black,
                      width: 1.2,
                    )
                  : BorderSide.none,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 25,
                color: selected ? Colors.white : Colors.black,
              ),

              const SizedBox(height: 2),

              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: selected ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}