import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:fundamentals/screens/profile_screens.dart';
import 'package:fundamentals/screens/signup_screens.dart';
import 'package:provider/provider.dart';
import '../providers/auth_providers.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool rememberMe = false;
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff6A11CB), Color(0xff2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.08,
              vertical: size.height * 0.12,
            ),
            child: Column(
              children: [
                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Login to your account",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 40),

                /// LOGIN CARD
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _customTextField(
                          controller: emailController,
                          label: "Email",
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 18),

                        _customTextField(
                          controller: passwordController,
                          label: "Password",
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              activeColor: const Color(0xff2575FC),
                              onChanged: (value) {
                                setState(() {
                                  rememberMe = value!;
                                });
                              },
                            ),
                            const Text("Remember Me"),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                      const ForgotPasswordScreen()),
                                );
                              },
                              child: const Text("Forgot Password?"),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        /// LOGIN BUTTON
                        auth.isLoading
                            ? const CircularProgressIndicator()
                            : CustomButton(
                          text: "Login",
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;

                            String? error = await auth.login(
                              email: emailController.text.trim(),
                              password:
                              passwordController.text.trim(),
                            );

                            if (error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error)),
                              );
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const ProfileScreen(),
                                ),
                              );
                            }
                          },
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: const [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text("OR"),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 20),

                        CustomButton(
                          text: "Continue with Google",
                          icon: Image.network(
                            "https://cdn-icons-png.flaticon.com/512/281/281764.png",
                            height: 20,
                          ),
                          onPressed: () async {
                            try {
                              await auth.loginWithGoogle();
                              if (FirebaseAuth.instance.currentUser != null) {
                                // Push to ProfileScreen after successful login
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Google Sign-In failed: $e")),
                              );
                            }
                          },
                        ),


                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don’t have an account? ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 16
                              ),

                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                    const SignUpScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Color(0xff2575FC),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _customTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? obscurePassword : false,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label is required";
        }
        if (label == "Email" && !value.contains("@")) {
          return "Enter a valid email";
        }
        if (label == "Password" && value.length < 6) {
          return "Password must be at least 6 characters";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            obscurePassword
                ? Icons.visibility_off
                : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },
        )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.blueGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          const BorderSide(color: Color(0xff2575FC), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}

/// Custom Button
class CustomButton extends StatelessWidget {
  final String text;           // the text of the button
  final VoidCallback onPressed; // the function when button is pressed
  final Widget? icon;          // NEW: optional icon widget

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon, // optional, can leave empty
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff2575FC),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[ // if icon exists, show it
              icon!,
              const SizedBox(width: 10), // space between icon and text
            ],
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

