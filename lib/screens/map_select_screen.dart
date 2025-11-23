import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class MapaSeleccionScreen extends StatefulWidget {
  const MapaSeleccionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MapaSeleccionScreenState createState() => _MapaSeleccionScreenState();
}

class _MapaSeleccionScreenState extends State<MapaSeleccionScreen> {
  LatLng? selectedLatLng;
  GoogleMapController? mapController;

  String calle = "";
  String colonia = "";
  String comunidad = "";
  String ciudad = "";
  String direccionCompleta = "Toca en el mapa para seleccionar";

  Future<LatLng?> _getCurrentLocation() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return null;
    }

    Position pos = await Geolocator.getCurrentPosition();
    return LatLng(pos.latitude, pos.longitude);
  }

  Future<void> _getPlaceMarkFromCoordinates(LatLng pos) async {
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

          direccionCompleta = "$calle, $colonia, $comunidad, $ciudad";
        });
      }
    } catch (e) {
      setState(() {
        direccionCompleta = "No se pudo obtener la dirección";
      });
    }
  }

  void _centerActualLocation() async {
    LatLng? ubicacionActual = await _getCurrentLocation();
    if (ubicacionActual == null) return;

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(ubicacionActual, 17),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seleccionar ubicación")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(20.523, -100.815), // temporal, se moverá solo
              zoom: 14,
            ),
            onMapCreated: (controller) {
              mapController = controller;
              _centerActualLocation(); // <-- Mover cámara automáticamente
            },
            myLocationEnabled: true, // punto azul
            myLocationButtonEnabled: true,
            onTap: (pos) async {
              setState(() {
                selectedLatLng = pos;
              });

              await _getPlaceMarkFromCoordinates(pos);
            },
            markers: selectedLatLng == null
                ? {}
                : {
                    Marker(
                      markerId: const MarkerId("seleccion"),
                      position: selectedLatLng!,
                    )
                  },
          ),

          // Caja con la dirección
          Positioned(
            left: 0,
            right: 0,
            bottom: 90,
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                direccionCompleta,
                style: const TextStyle(color: Colors.white),
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
          child: const Text("Usar esta ubicación"),
        ),
      ),
    );
  }
}
