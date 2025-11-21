import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({super.key, required this.onTap});

  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final defaultColorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          //color: const Color(0x91FF4444),
          color: defaultColorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Iniciar sesión',
            style: TextStyle(
              fontFamily: 'NexaTextDemo',
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
