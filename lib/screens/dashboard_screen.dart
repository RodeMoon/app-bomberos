import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_integrador_bomberos/screens/form_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_integrador_bomberos/services/auth_service.dart';
import 'detailReport_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  String? name;
  String? email;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;

    name = user?.displayName ?? "Bombero";
    email = user?.email ?? "correo@institucional.com";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828),
        elevation: 4,
        title: Text(
          "Reportes de incidentes",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: buildInstitutionalDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {}); // reconstruye la interfaz
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('reportes').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.red));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No hay reportes disponibles.',
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
              );
            }

            final reportes = snapshot.data!.docs;

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: reportes.length,
              itemBuilder: (context, index) {
                final doc = reportes[index];
                final data = doc.data() as Map<String, dynamic>;

                final descripcion =
                    data['descripcion_servicio'] ?? "Sin descripción";
                final fechaStr = data['fecha_reporte'];
                String fechaFormateada = "Sin fecha";

                if (fechaStr != null) {
                  try {
                    final fecha = DateTime.parse(fechaStr);
                    fechaFormateada =
                        "${fecha.day}/${fecha.month}/${fecha.year}";
                  } catch (_) {}
                }

                return buildIncidentCard(
                  context: context,
                  fecha: fechaFormateada,
                  descripcion: descripcion,
                  docId: doc.id,
                  data: data,
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFC62828),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReportFormScreen()),
        ),
      ),
    );
  }

  Widget buildIncidentCard({
    required BuildContext context,
    required String fecha,
    required String descripcion,
    required String docId,
    required Map<String, dynamic> data,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailReportScreen(data: data, docId: docId),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.only(bottom: 14),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCDD2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fire_truck,
                    color: Color(0xFFC62828), size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fecha,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(fontSize: 14),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => confirmDelete(context, docId),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInstitutionalDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFFF2F2F2),
      child: ListView(
        children: [
          Container(
            color: const Color(0xFFC62828),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundImage: const AssetImage("assets/pfp.jpg"),
                ),
                const SizedBox(height: 12),
                Text(
                  name ?? "",
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  email ?? "",
                  style: GoogleFonts.montserrat(
                      color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Perfil"),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("Acerca de"),
            subtitle: const Text("Versión 1.0.2"),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Cerrar sesión"),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () {
              Navigator.pop(context);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                AuthService().signout(context: context);
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> confirmDelete(BuildContext context, String docId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar reporte"),
        content: const Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context, false);
              try {
                await FirebaseFirestore.instance
                    .collection('reportes')
                    .doc(docId)
                    .delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Reporte eliminado correctamente')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al eliminar el reporte')),
                );
              }
            },
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await FirebaseFirestore.instance
          .collection('reportes')
          .doc(docId)
          .delete();
    }
  }
}
