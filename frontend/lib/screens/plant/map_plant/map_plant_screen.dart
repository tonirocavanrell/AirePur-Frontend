import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/Config.dart';
import 'package:frontend/utils/load_data.dart';
import 'package:frontend/utils/s3_image_loader.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart' as http;

class MapScreenPlant extends StatefulWidget {

  final LatLng? mypos;
  final LoadData ld;

  const MapScreenPlant({super.key, required this.mypos, required this.ld});

  @override
  State<MapScreenPlant> createState() => _MapScreenPlantState();
}

class _MapScreenPlantState extends State<MapScreenPlant> {

  GoogleMapController? mapController;

  late LatLng? mypos;
  String ip = Config.ip;

  bool estacionsCarregades = false;

  final Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _fetchStationsFromBackend() async {

    String backendUrl = '$ip/ranking/infoComunitat'; // Utiliza tu URL real
    try {
      final response = await http.get(Uri.parse(backendUrl));
      if (response.statusCode == 200) {
        
        List<dynamic> stations = jsonDecode(utf8.decode(response.bodyBytes));

        BitmapDescriptor icon;

        for (var station in stations) {
          icon = await S3ImageLoader.loadMarkerIcon('assets/plant_level${station['avgNivell'].toString()}.png');
          // Para cada estación, creamos una solicitud para obtener el "ica"
          _markers.add(
            Marker(
              icon: icon,
              markerId: MarkerId(station['codi'].toString()),
              position: LatLng(station['latitud'].toDouble(), station['longitud'].toDouble()),
              infoWindow: InfoWindow(
                title: "Nivell: ${station['avgNivell'].toString()}",
                snippet: station['municipi'],
              ),
            )
          );
        }

        estacionsCarregades = true;
        setState(() {});

      } else {
        // Maneja errores de respuesta no exitosos
        if (kDebugMode) {
          print("Error al obtener estaciones desde el backend: ${response.statusCode}");
        }
      }
    } catch (e) {
      // Maneja cualquier error que ocurra durante la llamada al backend
      if (kDebugMode) {
        print("Error al comunicarse con el backend: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStationsFromBackend();
  }

  @override
  Widget build(BuildContext context) {

    mypos = widget.mypos;


    return Scaffold(
      body: Stack(
        children: <Widget>[
          mypos == null || !estacionsCarregades ?  const Center(child: CircularProgressIndicator()) : GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: mypos!,
              zoom: 13.0,
            ),
            markers: _markers, // Usar la lista de marcadores aquí
          ),
          mypos == null || !estacionsCarregades ? const SizedBox() : Column(
            children: [
              const SizedBox(height: 60,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      color: Colors.white
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back)
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      )
    );
  }
}