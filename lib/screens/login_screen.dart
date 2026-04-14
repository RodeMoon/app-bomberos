import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_integrador_bomberos/components/my_button.dart';
import 'package:proyecto_integrador_bomberos/components/my_textfield.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:proyecto_integrador_bomberos/services/auth_service.dart';
import '../components/square_tile.dart';
import 'package:google_fonts/google_fonts.dart';

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
        msg: 'Por favor, complete todos los campos',
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
        msg: 'Por favor, ingrese un correo válido',
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

  Future<void> forgotPassword() async {
    final email = txtUserController.text.trim();

    // Si el campo de correo está vacío, pedir que lo ingrese primero
    if (email.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Ingrese su correo en el campo de arriba y vuelva a intentarlo',
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
        msg: 'Por favor, ingrese un correo válido',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    }

    // Mostrar diálogo de confirmación antes de enviar
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restablecer contraseña'),
        content: Text(
          'Se enviará un correo de restablecimiento a:\n\n$email',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Fluttertoast.showToast(
        msg: 'Correo enviado. Revise su bandeja de entrada.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'user-not-found':
          msg = 'No existe una cuenta con ese correo.';
          break;
        case 'invalid-email':
          msg = 'El correo ingresado no es válido.';
          break;
        default:
          msg = 'Error al enviar el correo. Intente de nuevo.';
      }
      Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  @override
  void dispose() {
    txtUserController.dispose();
    txtpWDController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Image.asset(
            'assets/background.gif',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Image.asset(
                        "assets/fireman_hat.png",
                        width: 200,
                      ),
                      const SizedBox(height: 50),
                      Text(
                        '¡Bienvenido!',
                        style: GoogleFonts.interTight(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 32,
                        ),
                      ),
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
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: forgotPassword,
                              child: Text(
                                '¿Olvidó su contraseña?',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 15,
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 75),
                      MyButton(onTap: signupUser),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey,
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              'O continuar con',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SquareTile(
                            onTap: () =>
                                AuthService().signInWithGoogle(context),
                            imagePath: 'assets/gmail.png',
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}