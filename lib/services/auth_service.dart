import 'dart:convert';
import 'package:proyecto_integrador_bomberos/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:proyecto_integrador_bomberos/screens/dashboard_screen.dart';
import 'package:proyecto_integrador_bomberos/screens/login_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:crypto/crypto.dart';

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final DatabaseService _dbService = DatabaseService(); // <----
  RegExp emailRegExp =
      RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

  //  REGISTER CON EMAIL Y PASS
  Future<void> signup(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      if (emailRegExp.hasMatch(email)) {
        print('Correo válido');
        if (password.length >= 6) {
          print("contraseña válida");

          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password);

          progressBar(context, "Iniciando sesión");

          await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);

          // Agregar usuario a Firestore
          // await _addUserToFirestore(user);

          // Cerrar el Progress Bar
          Navigator.of(context).pop();

          await Future.delayed(const Duration(seconds: 1));
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const DashboardScreen()));
        } else {
          Navigator.of(context, rootNavigator: true).pop();

          Fluttertoast.showToast(
            msg: "Ingrese una contraseña de al menos 6 carácteres",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.SNACKBAR,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 14.0,
          );
        }
      } else {
        Navigator.of(context, rootNavigator: true).pop();

        Fluttertoast.showToast(
          msg: "Ingrese un correo valido",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 14.0,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email';
      } else {
        message = 'Error: ${e.message}';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Ocurrió un error inesperado: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  progressBar(BuildContext context, String cadena) {
    showDialog(
      context: context,
      barrierDismissible: false,
      // No permite cerrar el diálogo tocando fuera de él
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text(cadena),
            ],
          ),
        );
      },
    );
  }

  String toMd5(String email) {
    print("email: ${md5.convert(utf8.encode(email)).toString()}");
    return md5.convert(utf8.encode(email)).toString();
  }

  checkIfExist(String email, BuildContext context) async {
    String emailMd5 = toMd5(email);
    bool exists = await _dbService.checkIfUserExists(emailMd5);

    if (!exists) {
      await _googleSignIn.signOut();
      Fluttertoast.showToast(
        msg: "Error, no tiene autorización de acceso",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

//  LOGIN CON GOOGLE
  signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      if (gUser == null) {
        print("Inicio de sesión cancelado");
        return; // Si el usuario cancela, simplemente salimos de la función
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      progressBar(context, "Iniciando sesión...");

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User user = userCredential.user!;

      // Cerrar el Progress Bar
      Navigator.of(context).pop();

      print("Email del usuario: ${user.email}");
      checkIfExist(user.email.toString(), context);
    } catch (e) {
      print("Error en Google Sign-In: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al iniciar sesión con Google: $e")),
      );
    }
  }

  Future<void> signout({required BuildContext context}) async {
    progressBar(context, "Cerrando sesión");
    try {
      await FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut();

      // Cerrar el Progress Bar
      Navigator.of(context).pop();

      // Opcional: Mostrar un mensaje indicando que la sesión se ha cerrado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Has cerrado sesión exitosamente")),
      );

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const LoginScreen()));
    } catch (e) {
      // Manejo de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cerrar sesión: $e")),
      );
    }
  }

  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      if (!emailRegExp.hasMatch(email)) {
        Fluttertoast.showToast(msg: "Ingrese un correo válido.");
        return;
      }

      if (password.length < 6) {
        Fluttertoast.showToast(
            msg: "Ingrese una contraseña de al menos 6 carácteres.");
        return;
      }

      progressBar(context, "Iniciando sesión...");

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      String emailMd5 = toMd5(email);
      bool exists =
          await DatabaseService().checkIfUserExists(emailMd5.toString());
      Navigator.of(context).pop(); // Cierra el progress bar

      if (exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        Fluttertoast.showToast(msg: "El usuario no tiene acceso autorizado.");
        await FirebaseAuth.instance.signOut();
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context)
          .pop(); // Asegúrate de cerrar el progress bar también aquí
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'No se encontró un usuario asociado al correo.';
      } else if (e.code == 'wrong-password') {
        message = 'Contraseña incorrecta.';
      } else {
        message = 'Ocurrió un error al iniciar sesión.';
      }

      Fluttertoast.showToast(msg: message);
    } catch (e) {
      Navigator.of(context).pop(); // En caso de error inesperado
      Fluttertoast.showToast(msg: "Error inesperado: $e");
    }
  }

  //  LOGIN CON EMAIL Y PASS
  /*Future<void> signin(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      if (emailRegExp.hasMatch(email)) {
        print('Correo válido');
        if (password.length >= 6) {
          print("contraseña válida");

          progressBar(context, "Iniciando sesión");

          UserCredential userCredential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);
          User user = userCredential.user!;

          bool exists = await DatabaseService().checkIfUserExists(user.uid);
          Navigator.of(context).pop(); // Cierra el progress bar

          if (exists) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          } else {
            Fluttertoast.showToast(
                msg: "El usuario no tiene acceso autorizado.");
            await FirebaseAuth.instance.signOut();
          }

          // Agregar usuario a Firestore
          // await _addUserToFirestore(user);

          // Cerrar el Progress Bar
          /*Navigator.of(context).pop();
          print("email: $email");
          checkIfExist(email, context);*/
/*
          await Future.delayed(const Duration(seconds: 1));
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const DashboardScreen()));*/
        } else {
          Fluttertoast.showToast(
            msg: "Ingrese una contraseña de al menos 6 carácteres.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.SNACKBAR,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 14.0,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Ingrese un correo válido.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 14.0,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'No se encontró un usuario asociado al correo.';
      } else if (e.code == 'wrong-password') {
        message = 'Contraseña incorrecta.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }*/
}
