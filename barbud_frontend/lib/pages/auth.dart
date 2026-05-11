import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isRegister = false;

  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void toggleAuthMode() {
    setState(() {
      isRegister = !isRegister;
    });
  }

  void submit() {
    if (isRegister) {
      print("Register pressed");
      print("Email: ${emailController.text}");
      print("Username: ${usernameController.text}");
      print("Password: ${passwordController.text}");
      print("Confirm password: ${confirmPasswordController.text}");
    } else {
      print("Login pressed");
      print("Email: ${emailController.text}");
      print("Password: ${passwordController.text}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 55),

                const Text(
                  "BarBud",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 45),

                AuthCard(
                  isRegister: isRegister,
                  emailController: emailController,
                  usernameController: usernameController,
                  passwordController: passwordController,
                  confirmPasswordController: confirmPasswordController,
                  onSubmit: submit,
                ),

                const SizedBox(height: 38),

                const OrDivider(),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: OutlinedButton(
                    onPressed: toggleAuthMode,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.black,
                        width: 1.8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      foregroundColor: Colors.black,
                    ),
                    child: Text(
                      isRegister ? "Back to login" : "Create account",
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  final bool isRegister;

  final TextEditingController emailController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  final VoidCallback onSubmit;

  const AuthCard({
    super.key,
    required this.isRegister,
    required this.emailController,
    required this.usernameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black,
          width: 1.8,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderSection(isRegister: isRegister),

          const SizedBox(height: 34),

          AuthTextField(
            label: "Email",
            controller: emailController,
          ),

          if (isRegister) ...[
            const SizedBox(height: 24),
            AuthTextField(
              label: "Username",
              controller: usernameController,
            ),
          ],

          const SizedBox(height: 24),

          AuthTextField(
            label: "Password",
            controller: passwordController,
            obscureText: true,
          ),

          if (isRegister) ...[
            const SizedBox(height: 24),
            AuthTextField(
              label: "Confirm password",
              controller: confirmPasswordController,
              obscureText: true,
            ),
          ],

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 58,
            child: OutlinedButton(
              onPressed: onSubmit,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Colors.black,
                  width: 1.8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                foregroundColor: Colors.black,
              ),
              child: Text(
                isRegister ? "Create account" : "Login",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  final bool isRegister;

  const HeaderSection({
    super.key,
    required this.isRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const MartiniIcon(size: 72),

        const SizedBox(width: 24),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isRegister ? "Create account" : "Welcome back",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                isRegister ? "Start building your bar" : "Log in to your bar",
                style: const TextStyle(
                  fontSize: 19,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AuthTextField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final TextEditingController controller;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 21,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 8),

        SizedBox(
          height: 52,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 1.8,
                ),
                borderRadius: BorderRadius.zero,
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 2.2,
                ),
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.black,
            thickness: 1.4,
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            "or",
            style: TextStyle(
              fontSize: 22,
              color: Colors.black,
            ),
          ),
        ),

        Expanded(
          child: Divider(
            color: Colors.black,
            thickness: 1.4,
          ),
        ),
      ],
    );
  }
}

class MartiniIcon extends StatelessWidget {
  final double size;

  const MartiniIcon({
    super.key,
    this.size = 64,
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
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    final bowl = Path()
      ..moveTo(w * 0.15, h * 0.22)
      ..lineTo(w * 0.85, h * 0.22)
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
      Offset(w * 0.30, h * 0.36),
      Offset(w * 0.70, h * 0.36),
      paint,
    );

    canvas.drawLine(
      Offset(w * 0.48, h * 0.42),
      Offset(w * 0.82, h * 0.10),
      paint,
    );

    canvas.drawCircle(
      Offset(w * 0.78, h * 0.15),
      w * 0.08,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}