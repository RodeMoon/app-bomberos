import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditReportScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const EditReportScreen({super.key, required this.docId, required this.data});

  @override
  State<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  late TextEditingController descripcionController;
  late TextEditingController reportanteController;
  late TextEditingController tipoServicioController;


  // Controladores ubicación e información del lugar
  late TextEditingController destinoController;
  late TextEditingController coloniaController ;
  late TextEditingController comunidadController;
  late TextEditingController ciudadController;
  late TextEditingController carreteraController;
  late TextEditingController kmController;
  late TextEditingController razonSocialController;
  late TextEditingController descripcionLugarController;
  late TextEditingController coordenadasNController;
  late TextEditingController coordenadasWController;

  // Controladores datos del reporte

  // Controladores datos de unidad y horarios
  late TextEditingController unidadAtiendeController;
  late TextEditingController kmSalidaController;
  late TextEditingController kmLlegadaController;
  late TextEditingController hrReporteController;
  late TextEditingController hrSalidaBaseController;
  late TextEditingController hrArriboController;
  late TextEditingController hrSalidaEscenaController;
  late TextEditingController hrUnidadDisponibleControlle;
  late TextEditingController hrLlegadaBaseController;

  // Controladores tipo de servicio y descripción
  late TextEditingController especificaController;
  late TextEditingController descripcionServicioController;

  // Controladores reporte de actividades
  late TextEditingController folioAnoController;
  late TextEditingController folioC4Controller;
  late TextEditingController elaboraController;

  // Controladores información complementaria
  late TextEditingController accionesController;
  late TextEditingController nombreAfectadoController;
  late TextEditingController funcionController;
  late TextEditingController direccionController;
  late TextEditingController telefonoController;
  late TextEditingController materialController;

  // Controladores observaciones
  late TextEditingController observacionesController;


  @override
  void initState() {
    super.initState();
    descripcionController = TextEditingController(text: widget.data['descripcion_servicio']);
    reportanteController = TextEditingController(text: widget.data['reportante']);
    tipoServicioController = TextEditingController(text: widget.data['tipo_servicio']);

    destinoController = TextEditingController(text: widget.data['destino']);
    coloniaController = TextEditingController(text: widget.data['colonia']);
    comunidadController = TextEditingController(text: widget.data['comunidad']);
    ciudadController = TextEditingController(text: widget.data['ciudad']);
    carreteraController = TextEditingController(text: widget.data['carretera']);
    kmController = TextEditingController(text: widget.data['km']);
    razonSocialController = TextEditingController(text: widget.data['razon_social']);
    descripcionLugarController = TextEditingController(text: widget.data['descripcion_lugar']);
    coordenadasNController = TextEditingController(text: widget.data['coordenadas_n']);
    coordenadasWController = TextEditingController(text: widget.data['coordenadas_w']);
    reportanteController = TextEditingController(text: widget.data['reportante']);
    unidadAtiendeController = TextEditingController(text: widget.data['unidad']);
    kmSalidaController = TextEditingController(text: widget.data['km_salida']);
    kmLlegadaController = TextEditingController(text: widget.data['km_llegada']);
    hrReporteController = TextEditingController(text: widget.data['hr_reporte']);
    hrSalidaBaseController = TextEditingController(text: widget.data['hr_salida_base']);
    hrArriboController = TextEditingController(text: widget.data['hr_arribo']);
    hrSalidaEscenaController = TextEditingController(text: widget.data['hr_salida_escena']);
    hrUnidadDisponibleControlle = TextEditingController(text: widget.data['hr_unidad_disponible']);
    hrLlegadaBaseController = TextEditingController(text: widget.data['hr_llegada_base']);
    especificaController = TextEditingController(text: widget.data['especifica']);
    descripcionServicioController = TextEditingController(text: widget.data['descripcion_servicio']);
    folioAnoController = TextEditingController(text: widget.data['folio_ano']);
    folioC4Controller = TextEditingController(text: widget.data['folio_c4']);
    elaboraController = TextEditingController(text: widget.data['elabora']);
    accionesController = TextEditingController(text: widget.data['acciones']);
    nombreAfectadoController = TextEditingController(text: widget.data['nombre_afectado']);
    funcionController = TextEditingController(text: widget.data['funcion']);
    direccionController = TextEditingController(text: widget.data['direccion']);
    telefonoController = TextEditingController(text: widget.data['telefono']);
    materialController = TextEditingController(text: widget.data['material']);
    observacionesController = TextEditingController(text: widget.data['observaciones']);
  }

  @override
  void dispose() {
    descripcionController.dispose();
    reportanteController.dispose();
    tipoServicioController.dispose();
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
    unidadAtiendeController.dispose();
    kmSalidaController.dispose();
    kmLlegadaController.dispose();
    hrReporteController.dispose();
    hrSalidaBaseController.dispose();
    hrArriboController.dispose();
    hrSalidaEscenaController.dispose();
    hrUnidadDisponibleControlle.dispose();
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

  Future<void> actualizarReporte() async {
    await FirebaseFirestore.instance.collection('reportes').doc(widget.docId).update({
      'descripcion_servicio': descripcionController.text,
      'reportante': reportanteController.text,
      'tipo_servicio': tipoServicioController.text,
      'destino': destinoController.text,
      'colonia': coloniaController.text,
      'comunidad': comunidadController.text,
      'ciudad': ciudadController.text,
      'carretera': carreteraController.text,
      'km': kmController.text,
      'razon_social': razonSocialController.text,
      'descripcion_lugar': descripcionLugarController.text,
      'coordenadas_n': coordenadasNController.text,
      'coordenadas_w': coordenadasWController.text,

      // Unidad y horarios
      'unidad': unidadAtiendeController.text,
      'km_salida': kmSalidaController.text,
      'km_llegada': kmLlegadaController.text,
      'hr_reporte': hrReporteController.text,
      'hr_salida_base': hrSalidaBaseController.text,
      'hr_arribo': hrArriboController.text,
      'hr_salida_escena': hrSalidaEscenaController.text,
      'hr_unidad_disponible': hrUnidadDisponibleControlle.text,
      'hr_llegada_base': hrLlegadaBaseController.text,

      // Tipo de servicio y descripción
      'especifica': especificaController.text,

      // Reporte de actividades
      'folio_ano': folioAnoController.text,
      'folio_c4': folioC4Controller.text,
      'elabora': elaboraController.text,

      // Información complementaria
      'acciones': accionesController.text,
      'nombre_afectado': nombreAfectadoController.text,
      'funcion': funcionController.text,
      'direccion': direccionController.text,
      'telefono': telefonoController.text,
      'material': materialController.text,
      'observaciones': observacionesController.text,
    });

    Navigator.pop(context, true); // Regresa a la pantalla anterior
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reporte actualizado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar reporte')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            buildSectionTitle('Ubicación'),
            buildTextField(destinoController, 'Destino'),
            buildTextField(coloniaController, 'Colonia'),
            buildTextField(comunidadController, 'Comunidad'),
            buildTextField(ciudadController, 'Ciudad'),
            buildTextField(carreteraController, 'Carretera'),
            buildTextField(kmController, 'KM'),
            buildTextField(razonSocialController, 'Razón social'),
            buildTextField(descripcionLugarController, 'Descripción del lugar'),
            buildTextField(coordenadasNController, 'Coordenadas N'),
            buildTextField(coordenadasWController, 'Coordenadas W'),

            buildSectionTitle('Detalles del servicio'),
            buildTextField(descripcionController, 'Descripción del servicio'),
            buildTextField(reportanteController, 'Reportante'),
            buildTextField(tipoServicioController, 'Tipo de servicio'),
            buildTextField(especificaController, 'Específica'),
            buildTextField(descripcionServicioController, 'Descripción ampliada'),

            buildSectionTitle('Datos de unidad y horarios'),
            buildTextField(unidadAtiendeController, 'Unidad que atiende'),
            buildTextField(kmSalidaController, 'KM salida'),
            buildTextField(kmLlegadaController, 'KM llegada'),
            buildTextField(hrReporteController, 'Hora del reporte'),
            buildTextField(hrSalidaBaseController, 'Hora salida de base'),
            buildTextField(hrArriboController, 'Hora de arribo'),
            buildTextField(hrSalidaEscenaController, 'Hora salida de escena'),
            buildTextField(hrUnidadDisponibleControlle, 'Hora unidad disponible'),
            buildTextField(hrLlegadaBaseController, 'Hora llegada a base'),

            buildSectionTitle('Reporte de actividades'),
            buildTextField(folioAnoController, 'Folio año'),
            buildTextField(folioC4Controller, 'Folio C4'),
            buildTextField(elaboraController, 'Elabora'),

            buildSectionTitle('Información adicional'),
            buildTextField(accionesController, 'Acciones'),
            buildTextField(nombreAfectadoController, 'Nombre del afectado'),
            buildTextField(funcionController, 'Función'),
            buildTextField(direccionController, 'Dirección'),
            buildTextField(telefonoController, 'Teléfono'),
            buildTextField(materialController, 'Material'),
            buildTextField(observacionesController, 'Observaciones'),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: actualizarReporte,
              icon: const Icon(Icons.save),
              label: const Text('Guardar cambios'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }


}