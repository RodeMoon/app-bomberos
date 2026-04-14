import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _textFadeAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Logo: fade + scale
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Texto: aparece después del logo
    _textFadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();

    // Navegar al destino correcto tras la animación
    Future.delayed(const Duration(milliseconds: 2600), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC62828),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animado
            ScaleTransition(
              scale: _scaleAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Image.asset(
                  'assets/fireman_hat.png',
                  width: 140,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Nombre de la app
            FadeTransition(
              opacity: _textFadeAnim,
              child: Text(
                'App Bomberos',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Subtítulo
            FadeTransition(
              opacity: _textFadeAnim,
              child: Text(
                'Sistema de gestión de incidentes',
                style: GoogleFonts.montserrat(
                  color: Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Indicador de carga sutil
            FadeTransition(
              opacity: _textFadeAnim,
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: Colors.white38,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
