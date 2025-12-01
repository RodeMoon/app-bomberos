import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_integrador_bomberos/screens/map_select_screen.dart';

class EditReportScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const EditReportScreen({
    super.key,
    required this.docId,
    required this.data,
  });

  @override
  State<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime? fechaReporte;

  List<String> imagenesExistentes = [];
  List<File> nuevasImagenes = [];

  late TextEditingController destinoController;
  late TextEditingController coloniaController;
  late TextEditingController comunidadController;
  late TextEditingController ciudadController;
  late TextEditingController carreteraController;
  late TextEditingController kmController;
  late TextEditingController razonSocialController;
  late TextEditingController descripcionLugarController;
  late TextEditingController coordenadasNController;
  late TextEditingController coordenadasWController;

  late TextEditingController reportanteController;

  late TextEditingController kmSalidaController;
  late TextEditingController kmLlegadaController;
  late TextEditingController hrReporteController;
  late TextEditingController hrSalidaBaseController;
  late TextEditingController hrArriboController;
  late TextEditingController hrSalidaEscenaController;
  late TextEditingController hrUnidadDisponibleController;
  late TextEditingController hrLlegadaBaseController;

  late TextEditingController especificaController;
  late TextEditingController descripcionServicioController;

  late TextEditingController folioAnoController;
  late TextEditingController folioC4Controller;
  late TextEditingController elaboraController;

  late TextEditingController accionesController;
  late TextEditingController nombreAfectadoController;
  late TextEditingController funcionController;
  late TextEditingController direccionController;
  late TextEditingController telefonoController;
  late TextEditingController materialController;

  late TextEditingController observacionesController;

  String? guardia;
  String? solicitadoPor;
  String? medio;
  String? tipoLlamada;
  String? tipoServicio;
  String? unidad;
  String? operador;
  String? jefeServicio;

  bool falsaAlarma = false;
  bool cancelado = false;

  final List<String> ciudadOptions = [
    "Guanajuato",
    "Silao",
    "Irapuato",
    "León",
    "Salamanca",
    "Otros"
  ];

  final List<String> guardiaOptions = [
    "Guardia 'A'",
    "Guardia 'B'",
    "Guardia 'C'",
  ];

  final List<String> solicitadoPorOptions = [
    "C-4",
    "Protección Civil",
    "Base Alfa",
    "Ciudadano",
    "Anónimo"
  ];

  final List<String> medioOptions = ["Radio", "Teléfono", "Pie Tierra"];

  final List<String> tipoLlamadaOptions = [
    "Emergencia",
    "Administrativo",
    "Evento Especial"
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

  @override
  void initState() {
    super.initState();

    fechaReporte = widget.data['fecha_reporte'] != null
        ? DateTime.tryParse(widget.data['fecha_reporte'])
        : null;

    imagenesExistentes = List<String>.from(widget.data['imagenes'] ?? []);

    destinoController =
        TextEditingController(text: widget.data['destino'] ?? "");
    coloniaController =
        TextEditingController(text: widget.data['colonia'] ?? "");
    comunidadController =
        TextEditingController(text: widget.data['comunidad'] ?? "");
    ciudadController = TextEditingController(text: widget.data['ciudad'] ?? "");
    carreteraController =
        TextEditingController(text: widget.data['carretera'] ?? "");
    kmController = TextEditingController(text: widget.data['km'] ?? "");
    razonSocialController =
        TextEditingController(text: widget.data['razon_social'] ?? "");
    descripcionLugarController =
        TextEditingController(text: widget.data['descripcion_lugar'] ?? "");
    coordenadasNController =
        TextEditingController(text: widget.data['coordenadas_n'] ?? "");
    coordenadasWController =
        TextEditingController(text: widget.data['coordenadas_w'] ?? "");

    reportanteController =
        TextEditingController(text: widget.data['reportante'] ?? "");

    kmSalidaController =
        TextEditingController(text: widget.data['km_salida'] ?? "");
    kmLlegadaController =
        TextEditingController(text: widget.data['km_llegada'] ?? "");
    hrReporteController =
        TextEditingController(text: widget.data['hr_reporte'] ?? "");
    hrSalidaBaseController =
        TextEditingController(text: widget.data['hr_salida_base'] ?? "");
    hrArriboController =
        TextEditingController(text: widget.data['hr_arribo'] ?? "");
    hrSalidaEscenaController =
        TextEditingController(text: widget.data['hr_salida_escena'] ?? "");
    hrUnidadDisponibleController =
        TextEditingController(text: widget.data['hr_unidad_disponible'] ?? "");
    hrLlegadaBaseController =
        TextEditingController(text: widget.data['hr_llegada_base'] ?? "");

    especificaController =
        TextEditingController(text: widget.data['especifica'] ?? "");
    descripcionServicioController =
        TextEditingController(text: widget.data['descripcion_servicio'] ?? "");

    folioAnoController =
        TextEditingController(text: widget.data['folio_ano'] ?? "");
    folioC4Controller =
        TextEditingController(text: widget.data['folio_c4'] ?? "");
    elaboraController =
        TextEditingController(text: widget.data['elabora'] ?? "");

    accionesController =
        TextEditingController(text: widget.data['acciones'] ?? "");
    nombreAfectadoController =
        TextEditingController(text: widget.data['nombre_afectado'] ?? "");
    funcionController =
        TextEditingController(text: widget.data['funcion'] ?? "");
    direccionController =
        TextEditingController(text: widget.data['direccion'] ?? "");
    telefonoController =
        TextEditingController(text: widget.data['telefono'] ?? "");
    materialController =
        TextEditingController(text: widget.data['material'] ?? "");

    observacionesController =
        TextEditingController(text: widget.data['observaciones'] ?? "");

    guardia = widget.data['guardia'];
    solicitadoPor = widget.data['solicitado_por'];
    medio = widget.data['medio'];
    tipoLlamada = widget.data['tipo_llamada'];
    tipoServicio = widget.data['tipo_servicio'];
    unidad = widget.data['unidad'];
    operador = widget.data['operador'];
    jefeServicio = widget.data['jefe_servicio'];

    falsaAlarma = widget.data['falsa_alarma'] ?? false;
    cancelado = widget.data['cancelado'] ?? false;
  }

  Future<void> actualizarReporte() async {
    List<String> urlsFinales = List.from(imagenesExistentes);

    for (var img in nuevasImagenes) {
      final ref = FirebaseStorage.instance
          .ref()
          .child("reportes/${DateTime.now().millisecondsSinceEpoch}.jpg");

      await ref.putFile(img);
      final url = await ref.getDownloadURL();
      urlsFinales.add(url);
    }

    await FirebaseFirestore.instance
        .collection('reportes')
        .doc(widget.docId)
        .update({
      "fecha_reporte": fechaReporte?.toIso8601String(),
      "imagenes": urlsFinales,
      "destino": destinoController.text,
      "colonia": coloniaController.text,
      "comunidad": comunidadController.text,
      "ciudad": ciudadController.text,
      "carretera": carreteraController.text,
      "km": kmController.text,
      "razon_social": razonSocialController.text,
      "descripcion_lugar": descripcionLugarController.text,
      "coordenadas_n": coordenadasNController.text,
      "coordenadas_w": coordenadasWController.text,
      "reportante": reportanteController.text,
      "km_salida": kmSalidaController.text,
      "km_llegada": kmLlegadaController.text,
      "hr_reporte": hrReporteController.text,
      "hr_salida_base": hrSalidaBaseController.text,
      "hr_arribo": hrArriboController.text,
      "hr_salida_escena": hrSalidaEscenaController.text,
      "hr_unidad_disponible": hrUnidadDisponibleController.text,
      "hr_llegada_base": hrLlegadaBaseController.text,
      "especifica": especificaController.text,
      "descripcion_servicio": descripcionServicioController.text,
      "folio_ano": folioAnoController.text,
      "folio_c4": folioC4Controller.text,
      "elabora": elaboraController.text,
      "acciones": accionesController.text,
      "nombre_afectado": nombreAfectadoController.text,
      "funcion": funcionController.text,
      "direccion": direccionController.text,
      "telefono": telefonoController.text,
      "material": materialController.text,
      "guardia": guardia,
      "solicitado_por": solicitadoPor,
      "medio": medio,
      "tipo_llamada": tipoLlamada,
      "tipo_servicio": tipoServicio,
      "unidad": unidad,
      "operador": operador,
      "jefe_servicio": jefeServicio,
      "falsa_alarma": falsaAlarma,
      "cancelado": cancelado,
      "observaciones": observacionesController.text,
    });

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Editar reporte")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(15),
          children: [
            buildSection("Fecha", [
              ElevatedButton(
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2100),
                    initialDate: fechaReporte ?? DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => fechaReporte = picked);
                  }
                },
                child: Text(fechaReporte == null
                    ? "Seleccionar fecha"
                    : fechaReporte.toString().split(" ")[0]),
              ),
            ]),

            buildSection("Ubicación", [
              buildField(destinoController, "Destino"),
              buildField(coloniaController, "Colonia"),
              buildField(comunidadController, "Comunidad"),
              DropdownButtonFormField(
                value: ciudadController.text.isNotEmpty
                    ? ciudadController.text
                    : null,
                items: ciudadOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  ciudadController.text = val.toString();
                  setState(() {});
                },
                decoration: InputDecoration(label: Text("Ciudad")),
              ),
              buildField(carreteraController, "Carretera"),
              buildField(kmController, "KM"),
              buildField(razonSocialController, "Razón Social"),
              buildField(descripcionLugarController, "Descripción del lugar"),
              Row(
                children: [
                  Expanded(
                      child: buildField(coordenadasNController, "Latitud (N)")),
                  SizedBox(width: 10),
                  Expanded(
                      child:
                          buildField(coordenadasWController, "Longitud (W)")),
                ],
              ),
                  ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MapaSeleccionScreen(),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      destinoController.text = result['direccion'] ?? '';
                      coloniaController.text = result['colonia'] ?? '';
                      ciudadController.text = result['ciudad'] ?? '';
                      comunidadController.text = result['comunidad'] ?? '';
                      carreteraController.text = result['carretera'] ?? '';
                      kmController.text = result['km'] ?? '';
                      razonSocialController.text = result['razon_social'] ?? '';
                      descripcionLugarController.text =
                          result['descripcion_lugar'] ?? '';
                      coordenadasNController.text =
                          (result['lat'] ?? '').toString();
                      coordenadasWController.text =
                          (result['lng'] ?? '').toString();
                    });
                  }
                },
                icon: Icon(Icons.map),
                label: Text("Seleccionar en mapa"),
              )
            ]),

            buildSection("Datos del reporte", [
              buildField(reportanteController, "Reportante"),
            ]),

            buildSection("Horarios", [
              buildField(hrReporteController, "Hora del reporte"),
              buildField(hrSalidaBaseController, "Salida de base"),
              buildField(hrArriboController, "Arribo"),
              buildField(hrSalidaEscenaController, "Salida de escena"),
              buildField(hrUnidadDisponibleController, "Unidad disponible"),
              buildField(hrLlegadaBaseController, "Llegada a base"),
            ]),

            buildSection("Servicio", [
              DropdownButtonFormField(
                value: tipoServicio,
                items: tipoServicioOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => tipoServicio = val),
                decoration: InputDecoration(label: Text("Tipo de servicio")),
              ),
              buildField(especificaController, "Específica"),
              buildField(
                  descripcionServicioController, "Descripción del servicio"),
            ]),

            buildSection("Actividades", [
              buildField(folioAnoController, "Folio año"),
              buildField(folioC4Controller, "Folio C4"),
              buildField(elaboraController, "Elabora"),
            ]),

            buildSection("Información complementaria", [
              buildField(accionesController, "Acciones"),
              buildField(nombreAfectadoController, "Nombre afectado"),
              buildField(funcionController, "Función"),
              buildField(direccionController, "Dirección"),
              buildField(telefonoController, "Teléfono"),
              buildField(materialController, "Material"),
              buildField(observacionesController, "Observaciones"),
            ]),

            buildSection("Imágenes", [
              Wrap(
                spacing: 10,
                children: imagenesExistentes
                    .map((e) => Stack(
                          children: [
                            Image.network(e,
                                height: 120, width: 120, fit: BoxFit.cover),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    imagenesExistentes.remove(e);
                                  });
                                },
                                icon: Icon(Icons.delete, color: Colors.red),
                              ),
                            )
                          ],
                        ))
                    .toList(),
              ),
              ElevatedButton.icon(
                onPressed: pickImagen,
                icon: Icon(Icons.add_a_photo),
                label: Text("Agregar imagen"),
              ),
            ]),

            SizedBox(height: 25),

            ElevatedButton.icon(
              onPressed: actualizarReporte,
              icon: Icon(Icons.save),
              label: Text("Guardar cambios"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                textStyle: TextStyle(fontSize: 17),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildSection(String title, List<Widget> children) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey)),
          SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget buildField(TextEditingController controller, String label,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          label: Text(label),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> pickImagen() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        nuevasImagenes.add(File(image.path));
      });
    }
  }
}
