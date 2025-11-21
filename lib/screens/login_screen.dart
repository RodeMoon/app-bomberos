import 'package:flutter/material.dart';
import 'package:proyecto_integrador_bomberos/components/my_button.dart';
import 'package:proyecto_integrador_bomberos/components/my_textfield.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:proyecto_integrador_bomberos/services/auth_service.dart';
import '../components/square_tile.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final txtUserController = TextEditingController();
  final txtpWDController = TextEditingController();

  void signupUser() {
    final email = txtUserController.text.trim();
    final password = txtpWDController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Por favor, complete todos los campos.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    }

    if (!isValidEmail(email)) {
      Fluttertoast.showToast(
        msg: 'Por favor, ingrese un correo válido.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    }

    AuthService().signin(email: email, password: password, context: context);
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con GIF
          Image.asset(
            'assets/background.gif', // GIF
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Image.asset(
                    "assets/fireman_hat.png",
                    width: 200,
                  ),
                  const SizedBox(height: 50),
                  const Text('¡Bienvenido!',
                      style: TextStyle(
                        fontFamily: 'NexaDemo',
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 32,
                      )),
                  const SizedBox(height: 25),
                  MyTextField(
                    controller: txtUserController,
                    obscureText: false,
                    hintText: 'Correo electrónico',
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: txtpWDController,
                    hintText: 'Contraseña',
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '¿Olvidó su contraseña?',
                          style: TextStyle(
                            fontFamily: 'NexaDemo',
                            fontWeight: FontWeight.w300,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 75),
                  MyButton(onTap: signupUser),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'O continuar con',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),                
                  // google sign in
                 Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // google button
                      SquareTile(
                          onTap: () => AuthService().signInWithGoogle(context),
                          imagePath: 'assets/google.png'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
