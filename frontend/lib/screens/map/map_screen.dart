import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/providers/locale_translationProvider.dart';
import 'package:frontend/screens/map/alert_dialog_contaminants.dart';
import 'package:frontend/screens/map/search_location_screen.dart';
import 'package:frontend/utils/Config.dart';
import 'package:frontend/utils/load_data.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para procesar la respuesta JSON

const MAPBOX_ACCESS = 'MAPBOX_ACCESS_TOKEN';


class MapScreen extends StatefulWidget {

  final String ip;
  final LatLng? mypos;
  final LoadData ld;

  const MapScreen({ super.key, required this.ip, required this.mypos, required this.ld});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {

  static const Map<int, double> colorMapICA = {
    50: 122.53,
    100: 53.81,
    150: 35.85,
    200: 4.07,
    300: 291.16,
    500: 15.69
  };

  //Datos para el grafico
  double? quantity;
  String? selectedPollutant;
  TextEditingController quantityController = TextEditingController();
  List<DateTime> dates = [];

  GoogleMapController? mapController;

  late double longitud;
  late double latitud;

  String ip = Config.ip;
  late LatLng? mypos;
  LatLng _center = const LatLng(0.0, 0.0);

  bool estacionsCarregades = false;

  late LoadData ld;

  String _lastMarkerIdClicked = '';
  DateTime _lastClickTime = DateTime.now();

  final Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _centerView() {
    mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: _center, // Ubicación que quieres centrar
        zoom: 13.0, // Nivel de zoom
      ),
    ));
  }

  void _updateCurrentLocationMarker() async{
    BitmapDescriptor myPosIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/current_location_icon.png'
    );

    // Añadir o actualizar el marcador de la posición actual en _markers
    _markers.removeWhere((m) => m.markerId == const MarkerId('currentLocation'));
    _markers.add(
      Marker(

        markerId: const MarkerId('currentLocation'), // ID único para el marcador de la posición actual
        position: mypos!,
        icon: myPosIcon,
        infoWindow: InfoWindow(title: TranslationService().translate('yourLocalization')),
      ),
    );
    
    setState(() {});
}

  Future<List<dynamic>> fetchContaminantsData(String codiEstacio) async {

    final String url = '$ip/dadesestacio/$codiEstacio';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception(TranslationService().translate('contaminantsError'));
    }
}

  Future<void> getEstacioProperaCoordenades(double lo, double la) async { 


    await http.get(Uri.parse('$ip/localitzacionsestacio/$lo/$la')).then((respuesta) async {

      Map<String, dynamic> jsonObject = jsonDecode(utf8.decode(respuesta.bodyBytes));

      longitud = jsonObject["longitud"];
      latitud = jsonObject["latitud"];

    }).catchError((error) {
      if (kDebugMode) {
        print('Error: $error');
      }
    });
  }

//Construeixo el pop up per demanar a l'usuari si es vol l'estació més propera
  Widget buildSearchDialog (BuildContext context, LatLng pos) {
    getEstacioProperaCoordenades(pos.longitude, pos.latitude);
    return AlertDialog(
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Colors.black87, width: 3), // Añade un borde
      ),
      elevation: 8,
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(5, 20, 5, 0),
          child: Column(
            children: [
              Text(
                TranslationService().translate('closeStation?')
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: Text(
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      TranslationService().translate('ok')
                    ),
                    onPressed: () {
                      //Ho centro amb la variable global utilitzada per centrar el mapa
                      _center = LatLng(latitud, longitud);
                      //Crido el controlador del centrador del mapa
                      _centerView();
                      //Elimino el pop up
                      Navigator.of(context).pop();
                    }
                  ),
                  TextButton(
                    onPressed: () {
                      //Elimino el pop up
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      "No"
                    ),
                  )
                ],
              )
            ]
          ),
        )
      ],
    );
  }

  void onTapMarker(String markerId, dynamic station, String icaResult) {
    final DateTime now = DateTime.now();
    if (_lastMarkerIdClicked == markerId && now.difference(_lastClickTime) < const Duration(seconds: 30)) {
      showDialog(
        context: context,
        builder: (BuildContext context) => ContaminantsDialog(codiEstacio: markerId, municipi: station['municipi'].toString(), comarca: station['comarca'].toString(), valorICA: icaResult,),
      );
    } else {
      _lastMarkerIdClicked = markerId;
      _lastClickTime = now;
    }
  }

  Future<void> _fetchStationsFromBackend() async {

    String backendUrl = '$ip/localitzacionsestacio'; // Utiliza tu URL real
    try {
      final response = await http.get(Uri.parse(backendUrl));
      if (response.statusCode == 200) {
        
        List<dynamic> stations = jsonDecode(utf8.decode(response.bodyBytes));
        List<Future> requests = []; // Lista para guardar las futuras solicitudes
        for (var station in stations) {
          // Para cada estación, creamos una solicitud para obtener el "ica"
          requests.add(_fetchStationIca(station['codiEstacio'].toString()));
        }

        // Esperamos a que todas las solicitudes se completen
        List results = await Future.wait(requests);
        estacionsCarregades = true;

        setState(() {
          for (int i = 0; i < stations.length; i++) {
            var station = stations[i];
            var icaResult = results[i]; // Resultado de la solicitud de "ica"
            station['codiEstacio'].toString();

            final Marker marker = Marker(
              icon: BitmapDescriptor.defaultMarkerWithHue(colorMapICA.entries
                .firstWhere((entry) => double.tryParse(icaResult)! <= entry.key)
                .value),
              markerId: MarkerId(station['codiEstacio'].toString()),
              position: LatLng(station['latitud'], station['longitud']),
              infoWindow: InfoWindow(
                title: "ICA: ${results[i]}",
                snippet: station['municipi'],
              ),
              onTap: () {
                onTapMarker(station['codiEstacio'].toString(), station, icaResult);
              },
            );
            _markers.add(marker);
          }
        });
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

  // Método para obtener el "ica" de una estación específica
  Future<String> _fetchStationIca(String codiEstacio) async {

    String icaUrl = '$ip/dadesestacio/ICA/$codiEstacio';
    var response = await http.get(Uri.parse(icaUrl));
    while (response.statusCode != 200) {
      response = await http.get(Uri.parse(icaUrl));
    }
    if (response.statusCode == 200) return response.body;
    throw Exception("Failed to load ICA for station $codiEstacio");
}

  @override
  void initState() {
    _fetchStationsFromBackend();
    _updateCurrentLocationMarker();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    ip = widget.ip;
    mypos = widget.mypos;
    ld = widget.ld;

    _center = mypos!;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          mypos == null || !estacionsCarregades ?  const Center(child: CircularProgressIndicator()) : GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 13.0,
            ),
            markers: _markers, // Usar la lista de marcadores aquí
          ),
           Column(
             children: [
               const SizedBox(height: 90,),
               ClipRRect(
                 child: Container(
                   margin: const EdgeInsets.all(20),
                   decoration: const BoxDecoration(
                     borderRadius: BorderRadius.all(Radius.circular(50)),
                     border: Border.fromBorderSide(BorderSide(color: Colors.black, width: 0.5)),
                     color: Colors.white
                   ),
                   child: TextField(
                     decoration: InputDecoration(
                       border: InputBorder.none,
                       hintText: TranslationService().translate('search...'),
                       contentPadding: const EdgeInsets.all(10)
                     ),
                     onTap: () {
                         Navigator.push(
                         context,
                         MaterialPageRoute(builder: (context) => const SearchLocationScreen()),
                       ).then((pos) {
                         _center = pos;
                         _markers.add(
                           Marker(
                             markerId: const MarkerId('searchedLocation'), // ID único para el marcador de la posición actual
                             position: pos,
                             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), // Asegúrate de que locationIcon está definido y cargado correctamente
                             infoWindow: InfoWindow(
                               title: TranslationService().translate('yourSearch'),
                               snippet: TranslationService().translate('clickAgain')
                             ),
                             onTap: () {
                               showDialog(
                                 context: context,
                                 builder: (BuildContext context) => buildSearchDialog(context, pos),
                               );
                             },
                           )
                         );
                         setState(() {});
                         _centerView();
                       });
                     },
                   ),
                 )
               ),
             ]
           ),
        ],
      )
    );
  }
}