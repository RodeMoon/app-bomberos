import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'map_select_screen.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  _ReportFormScreenState createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? fechaReporte;
  bool _isLoading = false; // <- NUEVO: controla el estado de carga

  // Lista dinámica de imágenes
  List<File> imagenes = [];

  // Controladores ubicación e información del lugar
  final TextEditingController destinoController = TextEditingController();
  final TextEditingController coloniaController = TextEditingController();
  final TextEditingController comunidadController = TextEditingController();
  final TextEditingController ciudadController = TextEditingController();
  final TextEditingController carreteraController = TextEditingController();
  final TextEditingController kmController = TextEditingController();
  final TextEditingController razonSocialController = TextEditingController();
  final TextEditingController descripcionLugarController =
      TextEditingController();
  final TextEditingController coordenadasNController = TextEditingController();
  final TextEditingController coordenadasWController = TextEditingController();

  // Controladores datos del reporte
  final TextEditingController reportanteController = TextEditingController();

  // Controladores datos de unidad y horarios
  final TextEditingController unidadAtiendeController = TextEditingController();
  final TextEditingController kmSalidaController = TextEditingController();
  final TextEditingController kmLlegadaController = TextEditingController();
  final TextEditingController hrReporteController = TextEditingController();
  final TextEditingController hrSalidaBaseController = TextEditingController();
  final TextEditingController hrArriboController = TextEditingController();
  final TextEditingController hrSalidaEscenaController =
      TextEditingController();
  final TextEditingController hrUnidadDisponibleController =
      TextEditingController();
  final TextEditingController hrLlegadaBaseController = TextEditingController();

  // Controladores tipo de servicio y descripción
  final TextEditingController especificaController = TextEditingController();
  final TextEditingController descripcionServicioController =
      TextEditingController();

  // Controladores reporte de actividades
  final TextEditingController folioAnoController = TextEditingController();
  final TextEditingController folioC4Controller = TextEditingController();
  final TextEditingController elaboraController = TextEditingController();

  // Controladores información complementaria
  final TextEditingController accionesController = TextEditingController();
  final TextEditingController nombreAfectadoController =
      TextEditingController();
  final TextEditingController funcionController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController materialController = TextEditingController();

  // Controladores observaciones
  final TextEditingController observacionesController = TextEditingController();

  // ── Detecta si el usuario ya tocó algún campo ──────────────────────────
  bool get _formularioTocado =>
      fechaReporte != null ||
      destinoController.text.isNotEmpty ||
      coloniaController.text.isNotEmpty ||
      reportanteController.text.isNotEmpty ||
      descripcionServicioController.text.isNotEmpty ||
      imagenes.isNotEmpty;

  Future<bool> _onWillPop() async {
    // Si no se tocó nada, salir sin preguntar
    if (!_formularioTocado) return true;

    final salir = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Salir sin guardar?"),
        content: const Text(
          "Tienes información ingresada en el formulario. "
          "Si sales ahora perderás todos los datos.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Seguir editando"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Salir"),
          ),
        ],
      ),
    );

    return salir ?? false;
  }

  Future<void> seleccionarImagen() async {
    final picker = ImagePicker();

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Agregar imagen"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text("Cámara"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text("Galería"),
          ),
        ],
      ),
    );

    if (source == null) return;

    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        imagenes.add(File(pickedFile.path));
      });
    }
  }

  Future<List<String>> subirImagenes(String reporteId) async {
    final storage = FirebaseStorage.instanceFor(app: storageApp!);
    List<String> urls = [];

    for (int i = 0; i < imagenes.length; i++) {
      final file = imagenes[i];
      final ref = storage.ref().child("reportes/$reporteId/img_$i.jpg");
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      urls.add(url);
    }

    return urls;
  }

  @override
  void dispose() {
    destinoController.dispose();
    coloniaController.dispose();
    comunidadController.dispose();
    ciudadController.dispose();
    carreteraController.dispose();
    kmController.dispose();
    razonSocialController.dispose();
    descripcionLugarController.dispose();
    coordenadasNController.dispose();
    coordenadasWController.dispose();
    reportanteController.dispose();
    unidadAtiendeController.dispose();
    kmSalidaController.dispose();
    kmLlegadaController.dispose();
    hrReporteController.dispose();
    hrSalidaBaseController.dispose();
    hrArriboController.dispose();
    hrSalidaEscenaController.dispose();
    hrUnidadDisponibleController.dispose();
    hrLlegadaBaseController.dispose();
    especificaController.dispose();
    descripcionServicioController.dispose();
    folioAnoController.dispose();
    folioC4Controller.dispose();
    elaboraController.dispose();
    accionesController.dispose();
    nombreAfectadoController.dispose();
    funcionController.dispose();
    direccionController.dispose();
    telefonoController.dispose();
    materialController.dispose();
    observacionesController.dispose();
    super.dispose();
  }

  // Opciones Dropdowns
  final List<String> guardiaOptions = [
    "Guardia \"A\"",
    "Guardia \"B\"",
    "Guardia \"C\"",
  ];

  final List<String> solicitadoPorOptions = [
    "C-4",
    "Protección Civil",
    "Base Alfa",
    "Ciudadano",
    "Anónimo"
  ];

  final List<String> medioOptions = ["Radio", "Teléfono", "Pié Tierra"];

  final List<String> tipoLlamadaOptions = [
    "Emergencia",
    "Administrativo",
    "Evento Especial"
  ];

  final List<String> operadorOptions = [
    "Miguel Mejia",
    "Alfonso Peru",
    "Abraham Ariza",
    "Alejandro Mejia",
    "Rene Enriquez",
    "José Mejía",
    "Gabriel Trejo",
    "Manuel Peres",
    "Jazael Ruvalcaba",
    "Otro"
  ];

  final List<String> tipoServicioOptions = [
    "Contraincendio",
    "Rescate",
    "Fugas/Derrames",
    "Administrativo",
    "Especial",
    "Cables caídos/Corto circuito",
    "Falsa alarma/Cancelado",
    "Otro"
  ];

  final List<String> unidadOptions = [
    "M-1", "M-2", "M-7", "M-8", "M-10",
    "M-12", "M-14", "M-15", "M-16"
  ];

  final List<String> jefeServicioOptions = [
    "Miguel Mejía",
    "Alfonso Perú",
    "Abraham Ariza",
    "Alejandro Mejía",
    "Rene Enriquez",
    "José Mejía",
    "Gabriel Trejo",
    "Manuel Peres",
    "Jazael Ruvalcaba",
    "Miguel Lopez",
    "Aaron Gonzales",
    "Javier Conejo",
    "Manuel Conejo",
    "N/A",
    "Otro"
  ];

  String? solicitadoPor;
  String? jefeServicio;
  String? unidad;
  String? ciudad;
  String? medio;
  String? tipoLlamada;
  String? tipoServicio;
  String? guardia;
  String? operador;
  bool falsaAlarma = false;
  bool cancelado = false;

  int unidadesBomberos = 0;
  int unidadesInstituciones = 0;
  int asistentesCantidad = 1;

  Future<void> selectedTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (newTime != null) {
      final formattedTime =
          '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';
      controller.text = formattedTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope intercepta el botón atrás del sistema
    return WillPopScope(
      onWillPop: _isLoading ? () async => false : _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Nuevo reporte"),
          // Interceptar también el botón atrás del AppBar
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (_isLoading) return;
              final salir = await _onWillPop();
              if (salir && mounted) Navigator.pop(context);
            },
          ),
          actions: [
            // Indicador de carga en el AppBar mientras guarda
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                ),
              ),
          ],
        ),
        body: Stack(
          children: [
            // ── Formulario ─────────────────────────────────────────────
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selección de fecha
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2025),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                setState(() => fechaReporte = pickedDate);
                              }
                            },
                      child: Text(fechaReporte == null
                          ? "Selecciona la fecha del reporte"
                          : "Fecha: ${fechaReporte!.toLocal().toString().split(' ')[0]}"),
                    ),
                    const SizedBox(height: 40),

//████████████████████████████████████████████████████████████
                    Text("Ubicación",
                        style: Theme.of(context).textTheme.titleLarge),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.map),
                      label: const Text("Seleccionar ubicación en el mapa"),
                      onPressed: _isLoading
                          ? null
                          : () async {
                              final resultado = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const MapaSeleccionScreen()),
                              );
                              if (resultado != null) {
                                setState(() {
                                  destinoController.text =
                                      resultado["calle"];
                                  coloniaController.text =
                                      resultado["colonia"];
                                  comunidadController.text =
                                      resultado["comunidad"];
                                  ciudad = resultado["ciudad"];
                                  coordenadasNController.text =
                                      resultado["lat"].toString();
                                  coordenadasWController.text =
                                      resultado["lng"].toString();
                                });
                              }
                            },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: destinoController,
                      decoration: const InputDecoration(
                          labelText: "Destino / Calle"),
                      readOnly: true,
                      validator: (value) =>
                          value!.isEmpty ? "Selecciona una ubicación" : null,
                    ),
                    TextFormField(
                      controller: coloniaController,
                      decoration:
                          const InputDecoration(labelText: "Colonia"),
                      readOnly: true,
                      validator: (value) =>
                          value!.isEmpty ? "Selecciona una ubicación" : null,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: comunidadController,
                            decoration: const InputDecoration(
                                labelText: "Comunidad"),
                            readOnly: true,
                            validator: (value) => value!.isEmpty
                                ? "Selecciona una ubicación"
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller:
                                TextEditingController(text: ciudad),
                            decoration:
                                const InputDecoration(labelText: "Ciudad"),
                            readOnly: true,
                            validator: (value) => value!.isEmpty
                                ? "Selecciona una ubicación"
                                : null,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: carreteraController,
                            decoration: const InputDecoration(
                                labelText: "Carretera / Camino"),
                            validator: (value) =>
                                value!.isEmpty ? "Campo requerido" : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: kmController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: "Kilómetro"),
                            validator: (value) =>
                                value!.isEmpty ? "Campo requerido" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

//████████████████████████████████████████████████████████████
                    Text("Información del lugar",
                        style: Theme.of(context).textTheme.titleLarge),
                    TextFormField(
                      controller: razonSocialController,
                      decoration: const InputDecoration(
                          labelText: "Razón social/Giro comercial"),
                      validator: (value) =>
                          value!.isEmpty ? "Campo requerido" : null,
                    ),
                    TextFormField(
                      controller: descripcionLugarController,
                      decoration: const InputDecoration(
                          labelText: "Descripción del lugar"),
                      validator: (value) =>
                          value!.isEmpty ? "Campo requerido" : null,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: coordenadasNController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true, signed: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[-0-9.]')),
                            ],
                            decoration: const InputDecoration(
                                labelText: "Coordenadas N"),
                            validator: (value) =>
                                value == null || value.isEmpty
                                    ? "Selecciona una ubicación"
                                    : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: coordenadasWController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true, signed: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[-0-9.]')),
                            ],
                            decoration: const InputDecoration(
                                labelText: "Coordenadas W"),
                            validator: (value) =>
                                value == null || value.isEmpty
                                    ? "Selecciona una ubicación"
                                    : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

//████████████████████████████████████████████████████████████
                    Text("Datos del reporte",
                        style: Theme.of(context).textTheme.titleLarge),
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: "Guardia"),
                      items: guardiaOptions
                          .map((o) => DropdownMenuItem(
                              value: o, child: Text(o)))
                          .toList(),
                      onChanged: (v) => setState(() => guardia = v),
                      validator: (v) =>
                          v == null ? "Campo requerido" : null,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: "Solicitado por"),
                      items: solicitadoPorOptions
                          .map((o) => DropdownMenuItem(
                              value: o, child: Text(o)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => solicitadoPor = v),
                      validator: (v) =>
                          v == null ? "Campo requerido" : null,
                    ),
                    TextFormField(
                      controller: reportanteController,
                      decoration: const InputDecoration(
                          labelText: "Nombre del reportante"),
                      validator: (value) =>
                          value!.isEmpty ? "Campo requerido" : null,
                    ),
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: "Medio"),
                      items: medioOptions
                          .map((o) => DropdownMenuItem(
                              value: o, child: Text(o)))
                          .toList(),
                      onChanged: (v) => setState(() => medio = v),
                      validator: (v) =>
                          v == null ? "Campo requerido" : null,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: "Tipo de llamada"),
                      items: tipoLlamadaOptions
                          .map((o) => DropdownMenuItem(
                              value: o, child: Text(o)))
                          .toList(),
                      onChanged: (v) => setState(() => tipoLlamada = v),
                      validator: (v) =>
                          v == null ? "Campo requerido" : null,
                    ),
                    const SizedBox(height: 20),

//████████████████████████████████████████████████████████████
                    Text("Datos de unidad y horarios",
                        style: Theme.of(context).textTheme.titleLarge),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: "Unidad que atiende"),
                      items: unidadOptions
                          .map((o) => DropdownMenuItem(
                              value: o, child: Text(o)))
                          .toList(),
                      onChanged: (v) => setState(() => unidad = v),
                      validator: (v) =>
                          v == null ? "Campo requerido" : null,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: kmSalidaController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: const InputDecoration(
                                labelText: "Km de salida"),
                            validator: (v) =>
                                v!.isEmpty ? "Campo requerido" : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: kmLlegadaController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: const InputDecoration(
                                labelText: "Km de llegada"),
                            validator: (v) =>
                                v!.isEmpty ? "Campo requerido" : null,
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: hrReporteController,
                      readOnly: true,
                      onTap: () =>
                          selectedTime(context, hrReporteController),
                      decoration: const InputDecoration(
                          labelText: "Hora de reporte"),
                      validator: (v) =>
                          v!.isEmpty ? "Campo requerido" : null,
                    ),
                    TextFormField(
                      controller: hrSalidaBaseController,
                      readOnly: true,
                      onTap: () =>
                          selectedTime(context, hrSalidaBaseController),
                      decoration: const InputDecoration(
                          labelText: "Hora de salida base"),
                      validator: (v) =>
                          v!.isEmpty ? "Campo requerido" : null,
                    ),
                    TextFormField(
                      controller: hrArriboController,
                      readOnly: true,
                      onTap: () =>
                          selectedTime(context, hrArriboController),
                      decoration: const InputDecoration(
                          labelText: "Hora de arribo escena"),
                      validator: (v) =>
                          v!.isEmpty ? "Campo requerido" : null,
                    ),
                    TextFormField(
                      controller: hrSalidaEscenaController,
                      readOnly: true,
                      onTap: () =>
                          selectedTime(context, hrSalidaEscenaController),
                      decoration: const InputDecoration(
                          labelText: "Hora de salida escena"),
                      validator: (v) =>
                          v!.isEmpty ? "Campo requerido" : null,
                    ),
                    TextFormField(
                      controller: hrUnidadDisponibleController,
                      readOnly: true,
                      onTap: () => selectedTime(
                          context, hrUnidadDisponibleController),
                      decoration: const InputDecoration(
                          labelText: "Hora de unidad disponible"),
                      validator: (v) =>
                          v!.isEmpty ? "Campo requerido" : null,
                    ),
                    TextFormField(
                      controller: hrLlegadaBaseController,
                      readOnly: true,
                      onTap: () =>
                          selectedTime(context, hrLlegadaBaseController),
                      decoration: const InputDecoration(
                          labelText: "Hora de llegada base"),
                      validator: (v) =>
                          v!.isEmpty ? "Campo requerido" : null,
                    ),
                    const SizedBox(height: 20),

//████████████████████████████████████████████████████████████
                    Text("Tipo de servicio",
                        style: Theme.of(context).textTheme.titleLarge),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: "Tipo de servicio"),
                      items: tipoServicioOptions
                          .map((o) => DropdownMenuItem(
                              value: o, child: Text(o)))
                          .toList(),
                      onChanged: (v) => setState(() => tipoServicio = v),
                      validator: (v) =>
                          v == null ? "Campo requerido" : null,
                    ),
                    TextFormField(
                      controller: especificaController,
                      decoration: const InputDecoration(
                          labelText: "Especifique (en caso de 'Otro')"),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text("Falsa alarma"),
                            value: falsaAlarma,
                            onChanged: (v) =>
                                setState(() => falsaAlarma = v!),
                            controlAffinity:
                                ListTileControlAffinity.leading,
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text("Cancelado"),
                            value: cancelado,
                            onChanged: (v) =>
                                setState(() => cancelado = v!),
                            controlAffinity:
                                ListTileControlAffinity.leading,
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: descripcionServicioController,
                      decoration: const InputDecoration(
                          labelText: "Descripción del servicio"),
                      maxLines: 3,
                      validator: (v) =>
                          v!.isEmpty ? "Campo requerido" : null,
                    ),
                    const SizedBox(height: 20),

//████████████████████████████████████████████████████████████
                    Text("Reporte de actividades",
                        style: Theme.of(context).textTheme.titleLarge),
                    TextFormField(
                      controller: folioAnoController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration:
                          const InputDecoration(labelText: "Folio del año"),
                      validator: (v) =>
                          v!.isEmpty ? "Campo requerido" : null,
                    ),
                    TextFormField(
                      controller: folioC4Controller,
                      decoration: const InputDecoration(
                          labelText:
                              "Folio de C4 o NP (NP si no proporcionó Folio)"),
                      validator: (v) =>
                          v!.isEmpty ? "Campo requerido" : null,
                    ),
                    TextFormField(
                      controller: elaboraController,
                      decoration:
                          const InputDecoration(labelText: "Elabora"),
                      validator: (v) =>
                          v!.isEmpty ? "Campo requerido" : null,
                    ),
                    const SizedBox(height: 20),

//████████████████████████████████████████████████████████████
                    Text("Información Complementaria",
                        style: Theme.of(context).textTheme.titleLarge),
                    TextFormField(
                      controller: accionesController,
                      decoration: const InputDecoration(
                          labelText:
                              "Acciones en el servicio, material involucrado/área afectada"),
                    ),
                    TextFormField(
                      controller: nombreAfectadoController,
                      decoration: const InputDecoration(
                          labelText: "Nombre del afectado"),
                    ),
                    TextFormField(
                      controller: funcionController,
                      decoration: const InputDecoration(
                          labelText: "Función que desempeña"),
                    ),
                    TextFormField(
                      controller: direccionController,
                      decoration:
                          const InputDecoration(labelText: "Dirección"),
                    ),
                    TextFormField(
                      controller: telefonoController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration:
                          const InputDecoration(labelText: "Teléfono"),
                    ),
                    TextFormField(
                      controller: materialController,
                      decoration: const InputDecoration(
                          labelText:
                              "Material involucrado y daños ocasionados"),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),

//████████████████████████████████████████████████████████████
                    Text("Personal en servicio",
                        style: Theme.of(context).textTheme.titleLarge),
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: "Operador"),
                      items: operadorOptions
                          .map((o) => DropdownMenuItem(
                              value: o, child: Text(o)))
                          .toList(),
                      onChanged: (v) => setState(() => operador = v),
                      validator: (v) =>
                          v == null ? "Campo requerido" : null,
                    ),
                    TextFormField(
                      controller: especificaController,
                      decoration: const InputDecoration(
                          labelText:
                              "Especifique (en caso de 'Otro')"),
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: "Jefe de servicio"),
                      items: jefeServicioOptions
                          .map((o) => DropdownMenuItem(
                              value: o, child: Text(o)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => jefeServicio = v),
                      validator: (v) =>
                          v == null ? "Campo requerido" : null,
                    ),
                    TextFormField(
                      controller: especificaController,
                      decoration: const InputDecoration(
                          labelText:
                              "Especifique (en caso de 'Otro')"),
                    ),
                    const SizedBox(height: 20),
                    Text("Asistentes",
                        style: Theme.of(context).textTheme.titleMedium),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                          labelText: "Número de asistentes"),
                      value: asistentesCantidad,
                      items: [1, 2, 3]
                          .map((n) => DropdownMenuItem(
                              value: n, child: Text("$n")))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => asistentesCantidad = v!),
                    ),
                    for (int i = 1; i <= asistentesCantidad; i++)
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: "Asistente $i"),
                      ),
                    const SizedBox(height: 20),

//████████████████████████████████████████████████████████████
                    Text("Unidades de Bomberos J.R. de Apoyo",
                        style: Theme.of(context).textTheme.titleLarge),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                          labelText: "Número de unidades"),
                      value: unidadesBomberos == 0
                          ? null
                          : unidadesBomberos,
                      items: [1, 2, 3, 4]
                          .map((n) => DropdownMenuItem(
                              value: n, child: Text("$n")))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => unidadesBomberos = v!),
                    ),
                    if (unidadesBomberos > 0)
                      for (int i = 1; i <= unidadesBomberos; i++) ...[
                        const SizedBox(height: 10),
                        Text("Unidad $i",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: "Unidad"),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                              labelText: "Encargado"),
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                              labelText: "No. de elementos"),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ],
                    const SizedBox(height: 20),

                    Text("Unidades de otras instituciones",
                        style: Theme.of(context).textTheme.titleLarge),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                          labelText: "Número de instituciones"),
                      value: unidadesInstituciones == 0
                          ? null
                          : unidadesInstituciones,
                      items: [1, 2, 3]
                          .map((n) => DropdownMenuItem(
                              value: n, child: Text("$n")))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => unidadesInstituciones = v!),
                    ),
                    if (unidadesInstituciones > 0)
                      for (int i = 1;
                          i <= unidadesInstituciones;
                          i++) ...[
                        const SizedBox(height: 10),
                        Text("Institución $i",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        TextFormField(
                          decoration: const InputDecoration(
                              labelText: "Institución"),
                        ),
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: "Unidad"),
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                              labelText: "Encargado"),
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                              labelText: "No. de elementos"),
                        ),
                      ],
                    const SizedBox(height: 20),

//████████████████████████████████████████████████████████████
                    Text("Observaciones",
                        style: Theme.of(context).textTheme.titleLarge),
                    TextFormField(
                      controller: observacionesController,
                      decoration: const InputDecoration(
                          labelText: "Observaciones"),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    Text("Imágenes",
                        style: Theme.of(context).textTheme.titleLarge),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ...imagenes.map((img) {
                          return Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(img,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover),
                              ),
                              GestureDetector(
                                onTap: () => setState(
                                    () => imagenes.remove(img)),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black54,
                                  ),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        GestureDetector(
                          onTap: _isLoading ? null : seleccionarImagen,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add_a_photo,
                                size: 40),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ── Botón guardar con estado de carga ───────────────
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _guardarReporte,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          _isLoading
                              ? "Guardando reporte..."
                              : "Guardar reporte",
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // ── Overlay semitransparente mientras guarda ───────────────
            if (_isLoading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 32, vertical: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Color(0xFFC62828)),
                          SizedBox(height: 16),
                          Text(
                            "Guardando reporte...",
                            style: TextStyle(fontSize: 15),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Subiendo imágenes y datos",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Lógica de guardado extraída a método separado ──────────────────────
  Future<void> _guardarReporte() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> reporteData = {
        'fecha_reporte': fechaReporte?.toIso8601String(),
        'destino': destinoController.text,
        'colonia': coloniaController.text,
        'comunidad': comunidadController.text,
        'ciudad': ciudad,
        'carretera': carreteraController.text,
        'km': kmController.text,
        'razon_social': razonSocialController.text,
        'descripcion_lugar': descripcionLugarController.text,
        'coordenadas_n': coordenadasNController.text,
        'coordenadas_w': coordenadasWController.text,
        'guardia': guardia,
        'solicitado_por': solicitadoPor,
        'reportante': reportanteController.text,
        'medio': medio,
        'tipo_llamada': tipoLlamada,
        'unidad': unidad,
        'km_salida': kmSalidaController.text,
        'km_llegada': kmLlegadaController.text,
        'hr_reporte': hrReporteController.text,
        'hr_salida_base': hrSalidaBaseController.text,
        'hr_arribo': hrArriboController.text,
        'hr_salida_escena': hrSalidaEscenaController.text,
        'hr_unidad_disponible': hrUnidadDisponibleController.text,
        'hr_llegada_base': hrLlegadaBaseController.text,
        'tipo_servicio': tipoServicio,
        'especifica': especificaController.text,
        'falsa_alarma': falsaAlarma,
        'cancelado': cancelado,
        'descripcion_servicio': descripcionServicioController.text,
        'folio_ano': folioAnoController.text,
        'folio_c4': folioC4Controller.text,
        'elabora': elaboraController.text,
        'acciones': accionesController.text,
        'nombre_afectado': nombreAfectadoController.text,
        'funcion': funcionController.text,
        'direccion': direccionController.text,
        'telefono': telefonoController.text,
        'material': materialController.text,
        'operador': operador,
        'jefe_servicio': jefeServicio,
        'observaciones': observacionesController.text,
        'created_at': FieldValue.serverTimestamp(),
      };

      final docRef =
          FirebaseFirestore.instance.collection('reportes').doc();
      final reporteId = docRef.id;
      final imagenesUrls = await subirImagenes(reporteId);
      reporteData['imagenes'] = imagenesUrls;
      await docRef.set(reporteData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Reporte guardado con éxito"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}