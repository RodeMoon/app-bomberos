import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_integrador_bomberos/screens/form_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_integrador_bomberos/services/auth_service.dart';
import 'package:proyecto_integrador_bomberos/screens/profile_screen.dart';
import 'package:proyecto_integrador_bomberos/utils/role_helper.dart';
import 'detailReport_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  User? user;
  String? name;
  String? email;

  // ── Búsqueda y filtros ───────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _filterTipoServicio;
  String? _filterGuardia;
  DateTimeRange? _filterFechaRango;

  final List<String> _tipoServicioOptions = [
    "Contraincendio",
    "Rescate",
    "Fugas/Derrames",
    "Administrativo",
    "Especial",
    "Cables caídos/Corto circuito",
    "Falsa alarma/Cancelado",
    "Otro",
  ];

  final List<String> _guardiaOptions = [
    'Guardia "A"',
    'Guardia "B"',
    'Guardia "C"',
  ];

  bool get _hayFiltrosActivos =>
      _filterTipoServicio != null ||
      _filterGuardia != null ||
      _filterFechaRango != null ||
      _searchQuery.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _reloadUser();
    _searchController.addListener(() {
      setState(() =>
          _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reloadUser() async {
    await FirebaseAuth.instance.currentUser?.reload();
    user = FirebaseAuth.instance.currentUser;
    setState(() {
      name = user?.displayName ?? "Bombero";
      email = user?.email ?? "correo@institucional.com";
    });
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user!.uid)
            .get();
        if (doc.exists && mounted) {
          setState(() => name = doc.data()?['nombre'] ?? name);
        }
      } catch (_) {}
    }
  }

  // ── Filtrado local ───────────────────────────────────────────────────────
  List<QueryDocumentSnapshot> _applyFilters(
      List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;

      // Texto libre: descripción, fecha o destino
      if (_searchQuery.isNotEmpty) {
        final descripcion =
            (data['descripcion_servicio'] ?? '').toString().toLowerCase();
        final fecha =
            (data['fecha_reporte'] ?? '').toString().toLowerCase();
        final destino =
            (data['destino'] ?? '').toString().toLowerCase();
        if (!descripcion.contains(_searchQuery) &&
            !fecha.contains(_searchQuery) &&
            !destino.contains(_searchQuery)) {
          return false;
        }
      }

      // Tipo de servicio
      if (_filterTipoServicio != null &&
          data['tipo_servicio'] != _filterTipoServicio) return false;

      // Guardia
      if (_filterGuardia != null && data['guardia'] != _filterGuardia)
        return false;

      // Rango de fechas
      if (_filterFechaRango != null) {
        final fechaStr = data['fecha_reporte'];
        if (fechaStr == null) return false;
        try {
          final fecha = DateTime.parse(fechaStr);
          if (fecha.isBefore(_filterFechaRango!.start) ||
              fecha.isAfter(
                  _filterFechaRango!.end.add(const Duration(days: 1)))) {
            return false;
          }
        } catch (_) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _limpiarFiltros() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _filterTipoServicio = null;
      _filterGuardia = null;
      _filterFechaRango = null;
    });
  }

  Future<void> _mostrarPanelFiltros() async {
    String? tempTipo = _filterTipoServicio;
    String? tempGuardia = _filterGuardia;
    DateTimeRange? tempRango = _filterFechaRango;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle decorativo
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text("Filtrar reportes",
                  style: GoogleFonts.montserrat(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),

              // Tipo de servicio
              Text("Tipo de servicio",
                  style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: tempTipo,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  hintText: "Todos",
                ),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text("Todos")),
                  ..._tipoServicioOptions.map((e) =>
                      DropdownMenuItem(value: e, child: Text(e))),
                ],
                onChanged: (val) =>
                    setModalState(() => tempTipo = val),
              ),
              const SizedBox(height: 16),

              // Guardia
              Text("Guardia",
                  style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: tempGuardia,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  hintText: "Todas",
                ),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text("Todas")),
                  ..._guardiaOptions.map((e) =>
                      DropdownMenuItem(value: e, child: Text(e))),
                ],
                onChanged: (val) =>
                    setModalState(() => tempGuardia = val),
              ),
              const SizedBox(height: 16),

              // Rango de fechas
              Text("Rango de fechas",
                  style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.date_range),
                label: Text(
                  tempRango == null
                      ? "Seleccionar rango"
                      : "${_formatDate(tempRango!.start)}  →  ${_formatDate(tempRango!.end)}",
                  style: GoogleFonts.montserrat(fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: ctx,
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2100),
                    initialDateRange: tempRango,
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                            primary: Color(0xFFC62828)),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    setModalState(() => tempRango = picked);
                  }
                },
              ),
              if (tempRango != null)
                TextButton(
                  onPressed: () =>
                      setModalState(() => tempRango = null),
                  child: const Text("Quitar rango",
                      style: TextStyle(color: Colors.red)),
                ),

              const SizedBox(height: 24),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setModalState(() {
                        tempTipo = null;
                        tempGuardia = null;
                        tempRango = null;
                      }),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("Limpiar",
                          style: GoogleFonts.montserrat()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _filterTipoServicio = tempTipo;
                          _filterGuardia = tempGuardia;
                          _filterFechaRango = tempRango;
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("Aplicar",
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) => "${d.day}/${d.month}/${d.year}";

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = RoleHelper.isAdmin;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828),
        elevation: 4,
        title: Text(
          "Reportes de incidentes",
          style: GoogleFonts.montserrat(
              color: Colors.white, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          // Ícono de filtros con punto indicador cuando hay filtros activos
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune, color: Colors.white),
                tooltip: "Filtros",
                onPressed: _mostrarPanelFiltros,
              ),
              if (_hayFiltrosActivos)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          if (!isAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("Solo lectura",
                    style: GoogleFonts.montserrat(
                        color: Colors.white, fontSize: 11)),
              ),
            ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          // ── Barra de búsqueda ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    "Buscar por descripción, fecha o destino...",
                hintStyle: GoogleFonts.montserrat(
                    fontSize: 13, color: Colors.grey),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.grey),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Chips de filtros activos ─────────────────────────────────
          if (_hayFiltrosActivos)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.filter_list,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_filterTipoServicio != null)
                            _buildChip(_filterTipoServicio!, () {
                              setState(
                                  () => _filterTipoServicio = null);
                            }),
                          if (_filterGuardia != null)
                            _buildChip(_filterGuardia!, () {
                              setState(() => _filterGuardia = null);
                            }),
                          if (_filterFechaRango != null)
                            _buildChip(
                              "${_formatDate(_filterFechaRango!.start)} → ${_formatDate(_filterFechaRango!.end)}",
                              () => setState(
                                  () => _filterFechaRango = null),
                            ),
                          TextButton(
                            onPressed: _limpiarFiltros,
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero),
                            child: Text("Limpiar todo",
                                style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color:
                                        const Color(0xFFC62828))),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Lista de reportes ────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: StreamBuilder<QuerySnapshot>(
                // Ordenado por fecha descendente desde Firestore
                stream: FirebaseFirestore.instance
                    .collection('reportes')
                    .orderBy('fecha_reporte', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Colors.red));
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState(
                        "No hay reportes disponibles.");
                  }

                  final filtrados =
                      _applyFilters(snapshot.data!.docs);

                  if (filtrados.isEmpty) {
                    return _buildEmptyState(
                        "No hay reportes que coincidan\ncon los filtros aplicados.");
                  }

                  return ListView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: filtrados.length,
                    itemBuilder: (context, index) {
                      final doc = filtrados[index];
                      final data =
                          doc.data() as Map<String, dynamic>;

                      final descripcion =
                          data['descripcion_servicio'] ??
                              "Sin descripción";
                      final fechaStr = data['fecha_reporte'];
                      String fechaFormateada = "Sin fecha";
                      if (fechaStr != null) {
                        try {
                          final fecha = DateTime.parse(fechaStr);
                          fechaFormateada =
                              "${fecha.day}/${fecha.month}/${fecha.year}";
                        } catch (_) {}
                      }

                      return _buildIncidentCard(
                        context: context,
                        fecha: fechaFormateada,
                        descripcion: descripcion,
                        tipoServicio:
                            data['tipo_servicio'] ?? '',
                        docId: doc.id,
                        data: data,
                        isAdmin: isAdmin,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: const Color(0xFFC62828),
              child: const Icon(Icons.add,
                  size: 28, color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ReportFormScreen()),
              ),
            )
          : null,
    );
  }

  // ── Widgets auxiliares ───────────────────────────────────────────────────

  Widget _buildChip(String label, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Chip(
        label: Text(label,
            style: GoogleFonts.montserrat(fontSize: 11)),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: onDelete,
        backgroundColor: const Color(0xFFFFCDD2),
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildEmptyState(String mensaje) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fire_truck_outlined,
              size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
                fontSize: 15, color: Colors.grey.shade500),
          ),
          if (_hayFiltrosActivos) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: _limpiarFiltros,
              child: Text("Limpiar filtros",
                  style: GoogleFonts.montserrat(
                      color: const Color(0xFFC62828))),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIncidentCard({
    required BuildContext context,
    required String fecha,
    required String descripcion,
    required String tipoServicio,
    required String docId,
    required Map<String, dynamic> data,
    required bool isAdmin,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailReportScreen(
            data: data,
            docId: docId,
            isAdmin: isAdmin,
          ),
        ),
      ),
      child: Card(
        elevation: 3,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
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
                    Text(fecha,
                        style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    Text(
                      descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(fontSize: 14),
                    ),
                    // Chip de tipo de servicio en la tarjeta
                    if (tipoServicio.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFCDD2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tipoServicio,
                          style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: const Color(0xFFC62828),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context, docId),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFFF2F2F2),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ProfileScreen()),
              );
              if (updated == true) _reloadUser();
            },
            child: Container(
              color: const Color(0xFFC62828),
              padding:
                  const EdgeInsets.fromLTRB(24, 48, 24, 24),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white24,
                        backgroundImage:
                            AssetImage("assets/pfp.jpg"),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.edit,
                            color: Color(0xFFC62828), size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(name ?? "Bombero",
                      style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  Text(email ?? "",
                      style: GoogleFonts.montserrat(
                          color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      RoleHelper.isAdmin
                          ? "Administrador"
                          : "Solo lectura",
                      style: GoogleFonts.montserrat(
                          color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.person_outline,
                color: Color(0xFFC62828)),
            title: Text("Mi perfil",
                style: GoogleFonts.montserrat(fontSize: 14)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey),
            onTap: () async {
              Navigator.pop(context);
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ProfileScreen()),
              );
              if (updated == true) _reloadUser();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline,
                color: Color(0xFFC62828)),
            title: Text("Acerca de",
                style: GoogleFonts.montserrat(fontSize: 14)),
            subtitle: Text("Versión 1.0.2",
                style: GoogleFonts.montserrat(
                    fontSize: 12, color: Colors.grey)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'App Bomberos',
                applicationVersion: '2.0.1',
                applicationIcon: Image.asset(
                    'assets/fireman_hat.png',
                    width: 48),
                children: [
                  Text(
                    'Sistema de gestión de reportes de incidentes para el cuerpo de bomberos.',
                    style: GoogleFonts.montserrat(fontSize: 13),
                  ),
                ],
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text("Cerrar sesión",
                style: GoogleFonts.montserrat(
                    fontSize: 14, color: Colors.red)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey),
            onTap: () {
              Navigator.pop(context);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                AuthService().signout(context: context);
              });
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, String docId) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar reporte"),
        content: const Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance
                    .collection('reportes')
                    .doc(docId)
                    .delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Reporte eliminado correctamente')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Error al eliminar el reporte')),
                );
              }
            },
            child: const Text("Eliminar",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}