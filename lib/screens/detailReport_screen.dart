import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'editReport_screen.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class DetailReportScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String docId;

  const DetailReportScreen({
    super.key,
    required this.data,
    required this.docId,
  });

  @override
  State<DetailReportScreen> createState() => _DetailReportScreenState();
}

class _DetailReportScreenState extends State<DetailReportScreen> {
  late Map<String, dynamic> data;

  @override
  void initState() {
    super.initState();
    data = widget.data;
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    final baseColor = PdfColor.fromHex('#1565C0');
    final titleStyle = pw.TextStyle(
        fontSize: 22, fontWeight: pw.FontWeight.bold, color: baseColor);
    final sectionStyle = pw.TextStyle(
        fontSize: 16, fontWeight: pw.FontWeight.bold, color: baseColor);
    final labelStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold);

    pw.Widget buildRow(String label, dynamic value) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(flex: 3, child: pw.Text(label, style: labelStyle)),
            pw.Expanded(flex: 5, child: pw.Text(value?.toString() ?? "—")),
          ],
        ),
      );
    }

    pw.Widget buildSection(String title, List<pw.Widget> children) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 16, bottom: 8),
            child: pw.Text(title, style: sectionStyle),
          ),
          pw.Container(height: 2, color: baseColor),
          pw.SizedBox(height: 8),
          ...children,
        ],
      );
    }

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Center(
            child: pw.Text("Reporte de Incendio", style: titleStyle),
          ),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text(
              "Folio: ${data['folio_ano'] ?? 'N/D'}     Fecha: ${data['fecha_reporte'] ?? 'N/D'}",
              style: const pw.TextStyle(fontSize: 12),
            ),
          ),
          pw.SizedBox(height: 20),

          // 🔹 Información general
          buildSection("Información General", [
            buildRow("Tipo de servicio", data['tipo_servicio']),
            buildRow("Descripción del servicio", data['descripcion_servicio']),
            buildRow("Tipo de llamada", data['tipo_llamada']),
            buildRow("Medio", data['medio']),
          ]),

          // 🔹 Ubicación
          buildSection("Ubicación", [
            buildRow("Ciudad", data['ciudad']),
            buildRow("Colonia", data['colonia']),
            buildRow("Comunidad", data['comunidad']),
            buildRow("Carretera", data['carretera']),
            buildRow("Dirección", data['direccion']),
            buildRow("Descripción del lugar", data['descripcion_lugar']),
            buildRow("Coordenadas N", data['coordenadas_n']),
            buildRow("Coordenadas W", data['coordenadas_w']),
          ]),

          // 🔹 Horarios
          buildSection("Horarios del Servicio", [
            buildRow("Hora del reporte", data['hr_reporte']),
            buildRow("Salida base", data['hr_salida_base']),
            buildRow("Llegada a escena", data['hr_arribo']),
            buildRow("Salida de escena", data['hr_salida_escena']),
            buildRow("Llegada a base", data['hr_llegada_base']),
            buildRow("Unidad disponible", data['hr_unidad_disponible']),
          ]),

          // 🔹 Unidad y personal
          buildSection("Unidad y Personal", [
            buildRow("Unidad", data['unidad']),
            buildRow("Operador", data['operador']),
            buildRow("Elabora", data['elabora']),
            buildRow("Jefe de servicio", data['jefe_servicio']),
            buildRow("Guardia", data['guardia']),
            buildRow("Función", data['funcion']),
          ]),

          // 🔹 Reportante
          buildSection("Datos del Reportante", [
            buildRow("Reportante", data['reportante']),
            buildRow("Teléfono", data['telefono']),
            buildRow("Solicitado por", data['solicitado_por']),
            buildRow("Nombre del afectado", data['nombre_afectado']),
            buildRow("Destino", data['destino']),
            buildRow("Razón social", data['razon_social']),
          ]),

          // 🔹 Detalles adicionales
          buildSection("Detalles Adicionales", [
            buildRow("Acciones", data['acciones']),
            buildRow("Material", data['material']),
            buildRow("Especificaciones", data['especifica']),
            buildRow("Observaciones", data['observaciones']),
            buildRow("Km Salida", data['km_salida']),
            buildRow("Km Llegada", data['km_llegada']),
            buildRow("Total Km", data['km']),
          ]),

          // 🔹 Estado del reporte
          buildSection("Estado del Reporte", [
            buildRow("Cancelado", data['cancelado'] == true ? "Sí" : "No"),
            buildRow(
                "Falsa alarma", data['falsa_alarma'] == true ? "Sí" : "No"),
          ]),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
    );
  }

  Widget buildInfoTile(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value.isNotEmpty ? value : 'Sin información'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fecha = data['fecha_reporte']?.toString().split('T').first ?? 'Sin fecha';

    return Scaffold(
      appBar: AppBar(
        title: Text('Reporte del $fecha'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _generatePdf(),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditReportScreen(
                    docId: widget.docId,
                    data: data,
                  ),
                ),
              );

              if (result == true) {
                // Recargar los datos desde Firestore después de editar
                final updatedDoc = await FirebaseFirestore.instance
                    .collection('reportes')
                    .doc(widget.docId)
                    .get();

                setState(() {
                  data = updatedDoc.data() ?? {};
                });
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Información general', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          buildInfoTile(Icons.local_activity, 'Tipo de servicio', data['tipo_servicio']),
          buildInfoTile(Icons.description, 'Descripción del servicio', data['descripcion_servicio']),
          buildInfoTile(Icons.phone, 'Tipo de llamada', data['tipo_llamada']),
          buildInfoTile(Icons.cast, 'Medio', data['medio']),

          const SizedBox(height: 10),
          const Text('Ubicación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          buildInfoTile(Icons.location_city, 'Ciudad', data['ciudad']),
          buildInfoTile(Icons.house, 'Colonia', data['colonia']),
          buildInfoTile(Icons.villa, 'Comunidad', data['comunidad']),
          buildInfoTile(Icons.aod, 'Carretera', data['carretera']),
          buildInfoTile(Icons.map, 'Dirección', data['direccion']),
          buildInfoTile(Icons.place, 'Descripción del lugar', data['descripcion_lugar']),
          buildInfoTile(Icons.navigation, 'Coordenadas N', data['coordenadas_n']),
          buildInfoTile(Icons.navigation, 'Coordenadas W', data['coordenadas_w']),

          const SizedBox(height: 10),
          const Text('Horarios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          buildInfoTile(Icons.access_time, 'Hora del reporte', data['hr_reporte']),
          buildInfoTile(Icons.access_time, 'Hora salida base', data['hr_salida_base']),
          buildInfoTile(Icons.access_time, 'Hora llegada a escena', data['hr_arribo']),
          buildInfoTile(Icons.access_time, 'Hora salida de escena', data['hr_salida_escena']),
          buildInfoTile(Icons.access_time, 'Hora llegada a base', data['hr_llegada_base']),
          buildInfoTile(Icons.access_time, 'Hora unidad disponible', data['hr_unidad_disponible']),

          const SizedBox(height: 10),
          const Text('Unidad y personal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          buildInfoTile(Icons.directions_car, 'Unidad', data['unidad']),
          buildInfoTile(Icons.directions_car, 'Operador', data['operador']),
          buildInfoTile(Icons.directions_car, 'Elabora', data['elabora']),
          buildInfoTile(Icons.directions_car, 'Jefe de servicio', data['jefe_servicio']),
          buildInfoTile(Icons.directions_car, 'Guardia', data['guardia']),
          buildInfoTile(Icons.directions_car, 'Función', data['funcion']),

          const SizedBox(height: 10),
          const Text('Reportante', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          buildInfoTile(Icons.account_circle_rounded, 'Reportante', data['reportante']),
          buildInfoTile(Icons.account_circle_rounded, 'Teléfono', data['telefono']),
          buildInfoTile(Icons.account_circle_rounded, 'Solicitado por', data['solicitado_por']),
          buildInfoTile(Icons.account_circle_rounded, 'Nombre del afectado', data['nombre_afectado']),
          buildInfoTile(Icons.account_circle_rounded, 'Destino', data['destino']),
          buildInfoTile(Icons.account_circle_rounded, 'Razón social', data['razon_social']),

          const SizedBox(height: 10),
          const Text('Detalles adicionales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          buildInfoTile(Icons.account_circle_rounded, 'Acciones', data['acciones']),
          buildInfoTile(Icons.account_circle_rounded, 'Material', data['material']),
          buildInfoTile(Icons.account_circle_rounded, 'Especificaciones', data['especifica']),
          buildInfoTile(Icons.account_circle_rounded, 'Observaciones', data['observaciones']),
          buildInfoTile(Icons.account_circle_rounded, 'Kilometraje', 'Salida: ${data['km_salida']}, Llegada: ${data['km_llegada']}, Total: ${data['km']}'),

          const SizedBox(height: 10),
          const Text('Datos administrativos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          buildInfoTile(Icons.account_circle_rounded, 'Folio año', data['folio_ano']),
          buildInfoTile(Icons.account_circle_rounded, 'Folio C4', data['folio_c4']),
          buildInfoTile(Icons.local_activity, 'Tipo de servicio', data['tipo_servicio']?.toString() ?? ''),

          const SizedBox(height: 10),
          const Text('Estado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          buildInfoTile(Icons.cancel, 'Cancelado', data['cancelado'] == true ? 'Sí' : 'No'),
          buildInfoTile(Icons.warning_amber, 'Falsa alarma', data['falsa_alarma'] == true ? 'Sí' : 'No'),
        ],
      ),
    );
  }
}