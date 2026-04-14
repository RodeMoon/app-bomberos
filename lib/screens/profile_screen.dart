import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController badgeController = TextEditingController();

  String? selectedGuardia;
  String? selectedRango;
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  bool isLoading = false;

  final List<String> guardiaOptions = [
    'Guardia "A"',
    'Guardia "B"',
    'Guardia "C"',
  ];

  final List<String> rangoOptions = [
    'Bombero',
    'Cabo',
    'Sargento',
    'Teniente',
    'Capitán',
    'Comandante',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;

    nameController.text = user!.displayName ?? '';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          phoneController.text = data['telefono'] ?? '';
          badgeController.text = data['numero_placa'] ?? '';
          selectedGuardia = data['guardia'];
          selectedRango = data['rango'];
          notificationsEnabled = data['notificaciones'] ?? true;
          darkModeEnabled = data['modo_oscuro'] ?? false;
        });
      }
    } catch (_) {}
  }

  Future<void> _saveProfile() async {
    if (user == null) return;

    if (nameController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'El nombre no puede estar vacío');
      return;
    }

    setState(() => isLoading = true);

    try {
      await user!.updateDisplayName(nameController.text.trim());

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .set({
        'nombre': nameController.text.trim(),
        'email': user!.email,
        'telefono': phoneController.text.trim(),
        'numero_placa': badgeController.text.trim(),
        'guardia': selectedGuardia,
        'rango': selectedRango,
        'notificaciones': notificationsEnabled,
        'modo_oscuro': darkModeEnabled,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Fluttertoast.showToast(msg: 'Perfil actualizado correctamente');
      Navigator.pop(context, true);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error al guardar: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828),
        elevation: 4,
        title: Text(
          "Mi Perfil",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          isLoading
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.save_rounded),
                  tooltip: "Guardar cambios",
                  onPressed: _saveProfile,
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header con foto hardcodeada (asset local) ────────────────
            Container(
              width: double.infinity,
              color: const Color(0xFFC62828),
              padding: const EdgeInsets.only(bottom: 30, top: 10),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white24,
                    backgroundImage: AssetImage("assets/pfp.jpg"),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? '',
                    style: GoogleFonts.montserrat(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Información personal ─────────────────────────────
                  _buildSectionTitle("Información personal"),
                  _buildCard([
                    _buildTextField(
                      controller: nameController,
                      label: "Nombre completo",
                      icon: Icons.person_outline,
                    ),
                    const Divider(height: 1),
                    _buildTextField(
                      controller: phoneController,
                      label: "Teléfono",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const Divider(height: 1),
                    _buildTextField(
                      controller: badgeController,
                      label: "Número de placa",
                      icon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // ── Asignación ───────────────────────────────────────
                  _buildSectionTitle("Asignación"),
                  _buildCard([
                    _buildDropdown(
                      label: "Guardia",
                      icon: Icons.groups_outlined,
                      value: selectedGuardia,
                      items: guardiaOptions,
                      onChanged: (val) => setState(() => selectedGuardia = val),
                    ),
                    const Divider(height: 1),
                    _buildDropdown(
                      label: "Rango",
                      icon: Icons.military_tech_outlined,
                      value: selectedRango,
                      items: rangoOptions,
                      onChanged: (val) => setState(() => selectedRango = val),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // ── Preferencias ─────────────────────────────────────
                  _buildSectionTitle("Preferencias"),
                  _buildCard([
                    _buildSwitch(
                      label: "Notificaciones",
                      subtitle: "Recibir alertas de nuevos reportes",
                      icon: Icons.notifications_outlined,
                      value: notificationsEnabled,
                      onChanged: (val) =>
                          setState(() => notificationsEnabled = val),
                    ),
                    const Divider(height: 1),
                    _buildSwitch(
                      label: "Modo oscuro",
                      subtitle: "Cambiar tema de la aplicación",
                      icon: Icons.dark_mode_outlined,
                      value: darkModeEnabled,
                      onChanged: (val) =>
                          setState(() => darkModeEnabled = val),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // ── Cuenta ───────────────────────────────────────────
                  _buildSectionTitle("Cuenta"),
                  _buildCard([
                    ListTile(
                      leading: const Icon(Icons.lock_outline,
                          color: Color(0xFFC62828)),
                      title: Text("Cambiar contraseña",
                          style: GoogleFonts.montserrat(fontSize: 14)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: Colors.grey),
                      onTap: _sendPasswordReset,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.email_outlined,
                          color: Colors.grey),
                      title: Text("Correo electrónico",
                          style: GoogleFonts.montserrat(fontSize: 14)),
                      subtitle: Text(
                        user?.email ?? '',
                        style: GoogleFonts.montserrat(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 30),

                  // ── Botón guardar ────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _saveProfile,
                      icon: const Icon(Icons.save_rounded),
                      label: Text(
                        "Guardar cambios",
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers de UI ────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.montserrat(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.montserrat(
              fontSize: 13, color: Colors.grey.shade600),
          prefixIcon:
              Icon(icon, color: const Color(0xFFC62828), size: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.montserrat(
              fontSize: 13, color: Colors.grey.shade600),
          prefixIcon:
              Icon(icon, color: const Color(0xFFC62828), size: 20),
          border: InputBorder.none,
        ),
        style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black87),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSwitch({
    required String label,
    required String subtitle,
    required IconData icon,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: const Color(0xFFC62828)),
      title: Text(label, style: GoogleFonts.montserrat(fontSize: 14)),
      subtitle: Text(subtitle,
          style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey)),
      value: value,
      activeColor: const Color(0xFFC62828),
      onChanged: onChanged,
    );
  }

  Future<void> _sendPasswordReset() async {
    final email = user?.email;
    if (email == null) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Fluttertoast.showToast(
        msg: 'Se envió un correo a $email para restablecer la contraseña',
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error al enviar el correo');
    }
  }
}