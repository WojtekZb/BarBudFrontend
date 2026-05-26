import 'package:barbud_frontend/models/barDetails.dart';
import 'package:barbud_frontend/models/ingredient.dart';
import 'package:flutter/material.dart';
import 'package:barbud_frontend/pages/home.dart';
import 'package:barbud_frontend/pages/my_bar.dart';
import 'package:barbud_frontend/services/auth_service.dart';
import 'package:barbud_frontend/services/bar_service.dart';

class BarDetailsPage extends StatefulWidget {
  final int barId;

  const BarDetailsPage({
    super.key,
    required this.barId,
  });

  @override
  State<BarDetailsPage> createState() => _BarDetailsPageState();
}

class _BarDetailsPageState extends State<BarDetailsPage> {
  late Future<BarDetails> barDetailsFuture;

  @override
  void initState() {
    super.initState();
    barDetailsFuture = loadBarDetails();
  }

  Future<BarDetails> loadBarDetails() async {
    final userIdString = await AuthService.getUserId();

    if (userIdString == null || userIdString.isEmpty) {
      throw Exception("User id was not found. Please log in again.");
    }

    final userId = int.parse(userIdString);

    return BarService.getBarDetails(
      userId: userId,
      barId: widget.barId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const UserDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const BarDetailsHeader(),

            Expanded(
              child: FutureBuilder<BarDetails>(
                future: barDetailsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Text(
                          "Could not load bar details:\n${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  }

                  final bar = snapshot.data!;

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bar.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "${bar.ingredientCount} ${bar.ingredientCount == 1 ? "ingredient" : "ingredients"}",
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      const Text(
                        "Ingredients",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (bar.ingredients.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black.withOpacity(0.6),
                              width: 1.3,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "This bar has no ingredients yet.",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      else
                        ...bar.ingredients.map(
                          (ingredient) => IngredientCard(
                            ingredient: ingredient,
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
        child: const BarDetailsBottomNavBar(),
      ),
    );
  }
}

class BarDetailsHeader extends StatelessWidget {
  const BarDetailsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 18, 18, 14),
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

          const Text(
            "Bar Details",
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class IngredientCard extends StatelessWidget {
  final BarIngredient ingredient;

  const IngredientCard({
    super.key,
    required this.ingredient,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black.withOpacity(0.6),
            width: 1.3,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.liquor_outlined,
              color: Colors.black,
              size: 30,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 4),

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
          ],
        ),
      ),
    );
  }
}

class BarDetailsBottomNavBar extends StatelessWidget {
  const BarDetailsBottomNavBar({super.key});

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
          BarDetailsBottomNavItem(
            icon: Icons.person_outline,
            label: "User",
            selected: false,
            hasRightBorder: true,
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
          ),

          BarDetailsBottomNavItem(
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

          BarDetailsBottomNavItem(
            icon: Icons.local_bar_outlined,
            label: "My Bar",
            selected: true,
            hasRightBorder: false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyBarPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class BarDetailsBottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool hasRightBorder;
  final VoidCallback onTap;

  const BarDetailsBottomNavItem({
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