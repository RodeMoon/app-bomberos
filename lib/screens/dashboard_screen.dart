import 'package:flutter/material.dart';
import 'package:proyecto_integrador_bomberos/screens/form_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'detailReport_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Clave para el Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int index = 0;

  final FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  String? name;
  String? email;

  @override
  void initState() {
    super.initState();
    // Initialize user and email here
    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      name = user!.displayName ?? 'Usuario sin nombre';
      email = user!.email ?? 'Correo no disponible';
    } else {
      name = 'Invitado';
      email = 'Sin sesión';
    }
  }

  @override
  Widget build(BuildContext context) {
    //  TEMA PRINCIPAL
    final defaultColorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: defaultColorScheme.surfaceDim,
      key: _scaffoldKey,
      // Asigna la clave al Scaffold
      appBar: AppBar(
        backgroundColor: defaultColorScheme.secondary,
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer(); // Abre el drawer
          },
          icon: Icon(
            Icons.menu,
            color: defaultColorScheme.onPrimary,
          ),
        ),
        title: Text(
          "Reportes de incendios",
          style: TextStyle(
              fontFamily: 'NexaDemo',
              fontWeight: FontWeight.bold,
              color: defaultColorScheme.onPrimary),
        ),
        actions: const [
          /*GestureDetector(
            onTap: () {},
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.ads_click_sharp,
                  //color: defaultColorScheme.onPrimary,
                ),
              ),
            ),
          ),*/
        ],
      ),
      drawer: myDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reportes')
            //.orderBy('fecha', descending: true) // opcional: orden por fecha
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay reportes disponibles.'));
          }

          final reportes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reportes.length,
            itemBuilder: (context, index) {
              final data = reportes[index].data() as Map<String, dynamic>;

              final fechaStr = data['fecha_reporte'];
              final descripcion = data['descripcion_servicio'];

              String fechaFormateada = 'Sin título';

              if (fechaStr != null && fechaStr is String) {
                try {
                  final fecha = DateTime.parse(fechaStr);
                  fechaFormateada = '${fecha.day}/${fecha.month}/${fecha.year}';
                } catch (e) {
                  fechaFormateada = fechaStr; // Por si acaso ya está formateado
                }
              }

              return Column(
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailReportScreen(
                            data: snapshot.data!.docs[index].data()
                                as Map<String, dynamic>,
                            docId: snapshot.data!.docs[index].id,
                          ),
                        ),
                      );
                    },
                    leading: const Icon(Icons.file_copy),
                    title: Text(fechaFormateada.toString()),
                    subtitle: Text(descripcion ?? 'Sin descripción'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final docId = snapshot.data!.docs[index].id;

                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('¿Eliminar reporte?'),
                            content:
                                const Text('Esta acción no se puede deshacer.'),
                            actions: [
                              TextButton(
                                child: const Text('Cancelar'),
                                onPressed: () => Navigator.pop(context, false),
                              ),
                              TextButton(
                                child: const Text('Eliminar'),
                                onPressed: () => Navigator.pop(context, true),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await FirebaseFirestore.instance
                              .collection('reportes')
                              .doc(docId)
                              .delete();
                        }
                      },
                    ),
                  ),
                  const Divider(thickness: 0.5, endIndent: 25, indent: 25),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: defaultColorScheme.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReportFormScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget myDrawer() {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                //child: selectedImage != null ? Image.file(selectedImage!) : const Image(image: AssetImage("assets/pfp.jpg"))),
                child: const Image(image: AssetImage("assets/pfp.jpg"))),
            accountName: Text(name ?? "nouser"),
            accountEmail: Text(email ?? "noemail"),
          ),
          ListTile(
            onTap: () {
              //Navigator.pushNamed(context, "/movies");
            },
            title: const Text("Perfil"),
            //subtitle: const Text("lorem ipsum"),
            leading: const Icon(Icons.person),
            trailing: const Icon(Icons.arrow_forward_ios_sharp),
          ),
          ListTile(
            onTap: () {
              //Navigator.pushNamed(context, "/preferences_drawer");
            },
            title: const Text("Preferencias"),
            subtitle: const Text("Tema / Fuente"),
            leading: const Icon(Icons.room_preferences),
            trailing: const Icon(Icons.arrow_forward_ios_sharp),
          ),
          ListTile(
            onTap: () {
              //Navigator.pushNamed(context, "/settings_drawer");
            },
            title: const Text("Acerca de"),
            subtitle: const Text("Versión 1.0.1"),
            leading: const Icon(Icons.info),
            trailing: const Icon(Icons.arrow_forward_ios_sharp),
          ),
          const Padding(
              padding: EdgeInsets.all(8),
              child: Divider(
                height: 2,
              )),
          ListTile(
            onTap: () {
              //AuthService().signout(context: context);
            },
            title: const Text("Cerrar sesión"),
            //subtitle: const Text("Tema / Fuente"),
            leading: const Icon(Icons.logout),
            trailing: const Icon(Icons.arrow_forward_ios_sharp),
          ),
        ],
      ),
    );
  }
}
