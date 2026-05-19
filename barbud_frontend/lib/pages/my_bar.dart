import 'package:flutter/material.dart';
import 'package:barbud_frontend/pages/home.dart';
import 'package:barbud_frontend/services/bar_service.dart';

import '../models/ingredient.dart';

class MyBarPage extends StatefulWidget {
  const MyBarPage({super.key});

  @override
  State<MyBarPage> createState() => _MyBarPageState();
}

class _MyBarPageState extends State<MyBarPage> {
  String selectedCategory = "All";

  final Set<int> selectedIngredients = {};

  late Future<List<BarIngredient>> ingredientsFuture;

  @override
  void initState() {
    super.initState();
    ingredientsFuture = BarService.getAllIngredients();
  }

  List<BarIngredient> getFilteredIngredients(List<BarIngredient> ingredients) {
    if (selectedCategory == "All") {
      return ingredients;
    }

    return ingredients
        .where((ingredient) => ingredient.category == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const UserDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const MyBarHeader(),

            const MyBarSearch(),

            Expanded(
              child: FutureBuilder<List<BarIngredient>>(
                future: ingredientsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                      ),
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
                        .map((ingredient) => ingredient.category)
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
                              selected: selectedIngredients.contains(ingredient.id),
                              onTap: () {
                                setState(() {
                                  if (selectedIngredients.contains(ingredient.id)) {
                                    selectedIngredients.remove(ingredient.id);
                                  } else {
                                    selectedIngredients.add(ingredient.id);
                                  }
                                });

                                print("Selected ingredient IDs: $selectedIngredients");
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

            const MyBarBottomNavBar(),
          ],
        ),
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
        border: Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 1.5,
          ),
        ),
      ),
      child: const Text(
        "My Bar",
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
    );
  }
}

class MyBarSearch extends StatelessWidget {
  const MyBarSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 1.3,
          ),
        ),
      ),
      child: TextField(
        cursorColor: Colors.black,
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
            color: selected ? Colors.black : Colors.white,
            border: Border.all(
              color: Colors.black,
              width: 1.4,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.check_circle_outline
                    : Icons.radio_button_unchecked,
                size: 38,
                color: selected ? Colors.white : Colors.black,
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ingredient.name,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                        color: selected ? Colors.white : Colors.black,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      ingredient.category,
                      style: TextStyle(
                        fontSize: 13,
                        color: selected ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                selected ? Icons.check : Icons.add,
                color: selected ? Colors.white : Colors.black,
                size: 30,
              ),
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