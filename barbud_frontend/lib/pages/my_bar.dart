import 'package:barbud_frontend/pages/bar_details.dart';
import 'package:flutter/material.dart';
import 'package:barbud_frontend/pages/home.dart';
import 'package:barbud_frontend/pages/create_bar.dart';
import 'package:barbud_frontend/services/bar_service.dart';
import 'package:barbud_frontend/services/auth_service.dart';

import '../models/bar.dart';

class MyBarPage extends StatefulWidget {
  const MyBarPage({super.key});

  @override
  State<MyBarPage> createState() => _MyBarPageState();
}

class _MyBarPageState extends State<MyBarPage> {

  late Future<List<UserBar>> barsFuture;

  @override
  void initState() {
    super.initState();
    barsFuture = loadBars();
  }

  Future<List<UserBar>> loadBars() async {
  await AuthService.debugStorage();

  final userIdString = await AuthService.getUserId();

  if (userIdString == null || userIdString.isEmpty) {
    throw Exception("User id was not found. Please log in again.");
  }

  final userIdint = int.parse(userIdString);

  return BarService.getMyBars(userId: userIdint);
  } 

  void reloadBars() {
    setState(() {
      barsFuture = loadBars();
    });
  }

  Future<void> openCreateBarPage() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateBarPage(),
      ),
    );

    if (created == true) {
      reloadBars();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('myBarPage'),
      backgroundColor: Colors.white,
      drawer: const UserDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const MyBarsHeader(),

            Expanded(
              child: FutureBuilder<List<UserBar>>(
                future: barsFuture,
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
                          "Could not load your bars:\n${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  }

                  final bars = snapshot.data ?? [];

                  if (bars.isEmpty) {
                    return EmptyBarsState(
                      key: const Key('createBarButton'),
                      onCreatePressed: openCreateBarPage,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    itemCount: bars.length,
                    itemBuilder: (context, index) {
                      final bar = bars[index];

                      return BarCard(
                        bar: bar,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BarDetailsPage(
                                barId: bar.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: openCreateBarPage,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: const MyBarPageBottomNavBar(),
      ),
    );
  }
}

class MyBarsHeader extends StatelessWidget {
  const MyBarsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 1.5),
        ),
      ),
      child: const Text(
        "My Bar",
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class EmptyBarsState extends StatelessWidget {
  final VoidCallback onCreatePressed;

  const EmptyBarsState({
    super.key,
    required this.onCreatePressed,
  });

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_bar_outlined,
              size: 78,
              color: Colors.black,
            ),

            const SizedBox(height: 22),

            const Text(
              "You have no bars yet",
              key: const Key('noBarsMessage'),
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Please create one to start adding your ingredients.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.35,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onCreatePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text(
                  "Create Bar",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BarCard extends StatelessWidget {
  final UserBar bar;
  final VoidCallback onTap;

  const BarCard({
    super.key,
    required this.bar,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black.withOpacity(0.6),
              width: 1.4,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.local_bar_outlined,
                color: Colors.black,
                size: 34,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bar.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "${bar.ingredientCount} ingredients",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Colors.black,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyBarPageBottomNavBar extends StatelessWidget {
  const MyBarPageBottomNavBar({super.key});

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
          MyBarPageBottomNavItem(
            icon: Icons.person_outline,
            label: "User",
            selected: false,
            hasRightBorder: true,
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
          ),

          MyBarPageBottomNavItem(
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

          MyBarPageBottomNavItem(
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

class MyBarPageBottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool hasRightBorder;
  final VoidCallback onTap;

  const MyBarPageBottomNavItem({
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