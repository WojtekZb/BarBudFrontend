import 'package:flutter/material.dart';
import 'package:barbud_frontend/services/auth_service.dart';

bool hasMinLength(String password) => password.length >= 8;
bool hasUppercase(String password) => RegExp(r'[A-Z]').hasMatch(password);
bool hasLowercase(String password) => RegExp(r'[a-z]').hasMatch(password);
bool hasNumber(String password) => RegExp(r'[0-9]').hasMatch(password);
bool hasSpecialChar(String password) =>
    RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]').hasMatch(password);

bool isStrongPassword(String password) {
  return hasMinLength(password) &&
      hasUppercase(password) &&
      hasLowercase(password) &&
      hasNumber(password) &&
      hasSpecialChar(password);
}

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
      confirmPasswordController.clear();
    });
  }

  Future<void> submit() async {
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty ||
        password.isEmpty ||
        (isRegister && username.isEmpty) ||
        (isRegister && confirmPassword.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all required fields."),
        ),
      );
      return;
    }

    if (isRegister && !isStrongPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password does not meet all requirements."),
        ),
      );
      return;
    }

    if (isRegister && password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match."),
        ),
      );
      return;
    }

    try {

      if (isRegister) {
        await AuthService.register(
          email: email,
          username: username,
          password: password,
        );
      } else {
        await AuthService.login(
          email: email,
          password: password,
        );
      }

      print("AUTH OK:");

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      print("AUTH FAILED:");
      print(e);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Login/Register failed: $e",
            key: const Key('loginErrorMessage'),
          ),
        ),
      );
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
                const SizedBox(height: 67),

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

class AuthCard extends StatefulWidget {
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
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  @override
  void initState() {
    super.initState();
    widget.passwordController.addListener(_update);
    widget.confirmPasswordController.addListener(_update);
  }

  @override
  void dispose() {
    widget.passwordController.removeListener(_update);
    widget.confirmPasswordController.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final password = widget.passwordController.text;
    final confirmPassword = widget.confirmPasswordController.text;

    final passwordsMatch =
        password.isNotEmpty && confirmPassword.isNotEmpty && password == confirmPassword;

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
          HeaderSection(isRegister: widget.isRegister),

          const SizedBox(height: 34),

          AuthTextField(
            fieldKey: const Key('emailField'),
            label: "Email",
            controller: widget.emailController,
          ),

          if (widget.isRegister) ...[
            const SizedBox(height: 24),
            AuthTextField(
              label: "Username",
              controller: widget.usernameController,
            ),
          ],

          const SizedBox(height: 24),

          AuthTextField(
            fieldKey: const Key('passwordField'),
            label: "Password",
            controller: widget.passwordController,
            obscureText: true,
          ),

          if (widget.isRegister) ...[
            const SizedBox(height: 14),

            PasswordRequirements(
              password: password,
            ),

            const SizedBox(height: 24),

            AuthTextField(
              label: "Confirm password",
              controller: widget.confirmPasswordController,
              obscureText: true,
            ),

            const SizedBox(height: 10),

            RequirementRow(
              text: "Passwords match",
              passed: passwordsMatch,
            ),
          ],

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 58,
            child: OutlinedButton(
              key: const Key('loginButton'),
              onPressed: widget.onSubmit,
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
                widget.isRegister ? "Create account" : "Login",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            )
          ),
        ],
      ),
    );
  }
}

class PasswordRequirements extends StatelessWidget {
  final String password;

  const PasswordRequirements({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Password requirements",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          RequirementRow(
            text: "At least 8 characters",
            passed: hasMinLength(password),
          ),
          RequirementRow(
            text: "At least 1 uppercase letter",
            passed: hasUppercase(password),
          ),
          RequirementRow(
            text: "At least 1 lowercase letter",
            passed: hasLowercase(password),
          ),
          RequirementRow(
            text: "At least 1 number",
            passed: hasNumber(password),
          ),
          RequirementRow(
            text: "At least 1 special character",
            passed: hasSpecialChar(password),
          ),
        ],
      ),
    );
  }
}

class RequirementRow extends StatelessWidget {
  final String text;
  final bool passed;

  const RequirementRow({
    super.key,
    required this.text,
    required this.passed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: Colors.black,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: passed ? FontWeight.w600 : FontWeight.w400,
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
  final Key? fieldKey;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.fieldKey,
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
            key: fieldKey,
            controller: controller,
            obscureText: obscureText,
            cursorColor: Colors.black,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 1.8,
                ),
                borderRadius: BorderRadius.zero,
              ),
              focusedBorder: OutlineInputBorder(
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