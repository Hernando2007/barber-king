import 'package:flutter/material.dart';

import '../login/login_screen.dart';

class PasswordChangedScreen extends StatelessWidget {
  const PasswordChangedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 120),

              const SizedBox(height: 25),

              const Text(
                "Contraseña actualizada",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              const Text(
                "Ahora puedes iniciar sesión nuevamente.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,

                    MaterialPageRoute(builder: (_) => const LoginScreen()),

                    (_) => false,
                  );
                },

                child: const Text("Ir al Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
