import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapaSeleccionScreen extends StatefulWidget {
  @override
  _MapaSeleccionScreenState createState() => _MapaSeleccionScreenState();
}

class _MapaSeleccionScreenState extends State<MapaSeleccionScreen> {
  LatLng? selectedLatLng;

  String calle = "";
  String colonia = "";
  String comunidad = "";
  String ciudad = "";
  String direccionCompleta = "Toca en el mapa para seleccionar";

  // Método para obtener la dirección al tocar el mapa
  Future<void> _obtenerDireccionDesdeCoordenadas(LatLng pos) async {
    try {
      List<Placemark> places =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);

      if (places.isNotEmpty) {
        Placemark p = places.first;

        setState(() {
          calle = p.street ?? "";
          colonia = p.subLocality ?? "";
          comunidad = p.locality ?? "";
          ciudad = p.administrativeArea ?? "";

          direccionCompleta =
              "$calle, $colonia, $comunidad, $ciudad"; // texto mostrado abajo
        });
      }
    } catch (e) {
      print("Error obteniendo dirección: $e");
      setState(() {
        direccionCompleta = "No se pudo obtener la dirección";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Seleccionar ubicación")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(20.523, -100.815),
              zoom: 14,
            ),
            onTap: (pos) async {
              setState(() {
                selectedLatLng = pos;
              });

              await _obtenerDireccionDesdeCoordenadas(pos);
            },
            markers: selectedLatLng == null
                ? {}
                : {
                    Marker(
                      markerId: MarkerId("seleccion"),
                      position: selectedLatLng!,
                    )
                  },
          ),

          // Dirección mostrada arriba del botón
          Positioned(
            left: 0,
            right: 0,
            bottom: 90,
            child: Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                direccionCompleta,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          onPressed: selectedLatLng == null
              ? null
              : () {
                  Navigator.pop(
                    context,
                    {
                      "lat": selectedLatLng!.latitude,
                      "lng": selectedLatLng!.longitude,
                      "calle": calle,
                      "colonia": colonia,
                      "comunidad": comunidad,
                      "ciudad": ciudad,
                    },
                  );
                },
          child: Text("Usar esta ubicación"),
        ),
      ),
    );
  }
}
