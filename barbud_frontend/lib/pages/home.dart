import 'package:flutter/material.dart';
import 'package:barbud_frontend/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:barbud_frontend/pages/auth.dart';
import 'package:barbud_frontend/pages/my_bar.dart';

class Drink {
  final String name;
  final String difficulty;
  final int ingredientsCount;
  final int stepsCount;

  const Drink({
    required this.name,
    required this.difficulty,
    required this.ingredientsCount,
    required this.stepsCount,
  });
}

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final List<Drink> drinks = const [
  Drink(
    name: "Pornstar Martini",
    difficulty: "Easy",
    ingredientsCount: 11,
    stepsCount: 4,
  ),
  Drink(
    name: "Margarita",
    difficulty: "Easy",
    ingredientsCount: 5,
    stepsCount: 3,
  ),
  Drink(
    name: "Mojito",
    difficulty: "Medium",
    ingredientsCount: 8,
    stepsCount: 7,
  ),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('homePage'),
      backgroundColor: Colors.white,

      drawer: const UserDrawer(),

      body: SafeArea(
        child: Column(
          children: [
            const HomeHeader(),

            const FilterBar(),

            Expanded(
              child: drinks.isEmpty
                  ? const EmptyDrinkState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      itemCount: drinks.length,
                      itemBuilder: (context, index) {
                        final drink = drinks[index];

                        return DrinkCard(
                          drink: drink,
                          onTap: () {
                            print("Clicked drink: ${drink.name}");
                          },
                        );
                      },
                    ),
            ),

            const BottomNavBar(),
          ],
        ),
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

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
        "BarBud",
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
    );
  }
}

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

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
      child: const Row(
        children: [
          FilterButton(
            text: "Bar based",
            selected: true,
          ),
          SizedBox(width: 10),
          FilterButton(
            text: "Missing",
            selected: false,
          ),
          SizedBox(width: 10),
          FilterButton(
            text: "All",
            selected: false,
          ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String text;
  final bool selected;

  const FilterButton({
    super.key,
    required this.text,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class EmptyDrinkState extends StatelessWidget {
  const EmptyDrinkState({super.key});

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
            MartiniIcon(size: 74),

            SizedBox(height: 22),

            Text(
              "No drinks yet",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 10),

            Text(
              "Later, drinks from your backend will show up here as cards.",
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

class DrinkCard extends StatelessWidget {
  final Drink drink;
  final VoidCallback onTap;

  const DrinkCard({
    super.key,
    required this.drink,
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
            color: Colors.white,
            border: Border.all(
              color: Colors.black,
              width: 1.4,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MartiniIcon(size: 42),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drink.name,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Text(
                          "Difficulty: ",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                        DifficultyBadge(text: drink.difficulty),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Ingredients: ${drink.ingredientsCount}",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Steps: ${drink.stepsCount}",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
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

class DifficultyBadge extends StatelessWidget {
  final String text;

  const DifficultyBadge({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

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
          BottomNavItem(
            itemKey: const Key('profileButton'),
            icon: Icons.person_outline,
            label: "Profile",
            selected: false,
            hasRightBorder: true,
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
          ),

          BottomNavItem(
            icon: Icons.home_outlined,
            label: "Home",
            selected: true,
            hasRightBorder: true,
            onTap: () {},
          ),

          BottomNavItem(
            itemKey: const Key('myBarsButton'),
            icon: Icons.countertops_outlined,
            label: "My Bar",
            selected: false,
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

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool hasRightBorder;
  final VoidCallback onTap;
  final Key? itemKey;

  const BottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.hasRightBorder,
    required this.onTap,
    this.itemKey,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        key: itemKey,
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

class MartiniIcon extends StatelessWidget {
  final double size;

  const MartiniIcon({
    super.key,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: MartiniIconPainter(),
    );
  }
}

class MartiniIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    final bowl = Path()
      ..moveTo(w * 0.14, h * 0.20)
      ..lineTo(w * 0.86, h * 0.20)
      ..lineTo(w * 0.50, h * 0.58)
      ..close();

    canvas.drawPath(bowl, paint);

    canvas.drawLine(
      Offset(w * 0.50, h * 0.58),
      Offset(w * 0.50, h * 0.86),
      paint,
    );

    canvas.drawLine(
      Offset(w * 0.32, h * 0.86),
      Offset(w * 0.68, h * 0.86),
      paint,
    );

    canvas.drawLine(
      Offset(w * 0.48, h * 0.42),
      Offset(w * 0.82, h * 0.10),
      paint,
    );

    canvas.drawCircle(
      Offset(w * 0.78, h * 0.14),
      w * 0.07,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class UserDrawer extends StatelessWidget {

  const UserDrawer({super.key});

  static const storage = FlutterSecureStorage();

  Future<void> logout(BuildContext context) async {
    await AuthService.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.black,
          width: 1.5,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black,
                    width: 1.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 58,
                    color: Colors.black,
                  ),

                  SizedBox(height: 14),

                  Text(
                    "Your Bar",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: 6),

                  FutureBuilder<String?>(
                    future: storage.read(key: "username"),
                    builder: (context, snapshot) {
                      final username = snapshot.data ?? "Unknown user";

                      return Text(
                        username,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(18),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  key: const Key('logoutButton'),
                  onPressed: () => logout(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.black,
                      width: 1.6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
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

class DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const DrawerMenuItem({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),

          Icon(
            icon,
            size: 27,
            color: Colors.black,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),

          const Icon(
            Icons.chevron_right,
            color: Colors.black,
            size: 28,
          ),

          const SizedBox(width: 12),
        ],
      ),
    );
  }
}