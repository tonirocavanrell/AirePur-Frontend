import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:frontend/screens/forum/forum.dart';
import 'package:frontend/utils/Config.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import 'Config.dart';

class LoadData extends ChangeNotifier{

  String errorMssg = "";
  String usernameLabel = "";
  String passwordLabel = "";
  String passwordHashed = "";
  String nomUser = "";
  String edat = "";
  String tlf = "";
  String email = "";
  bool isAdmin = false;
  String token = "";
  String urlPerfil = "";
  bool isBlocked = false;

  String estacioPropera = "";
  String ciutat = "";
  double ICAEstacioPropera = 0;
  String fecha = "";
  String hora = "";
  double longitud = 0;
  double latitud = 0;

  Map<String, double> contaminantsMap = {};
  Map<String, int> placesMap = {};

  List<String> ultimaSetmanaDies = [];
  List<String> ultimaSetmanaUbs = [];
  List<int> ultimaSetmanaICAs = [];

  Position position = Position(longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 0, altitude: 0, altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0);
  LatLng? mypos;


  bool connected = false;
  bool _isLoadedPulmo = false;
  bool get isLoadedPulmo => _isLoadedPulmo;
  bool _isLoadedForum = false;
  bool get isLoadedForum => _isLoadedForum;

  String lastAnswer = "";
  int puntuacioAlNivell = 0;
  int puntuacioTotal = 0;
  int nivell = 0;
  int puntuacioNivell = 0;

  late Message message;
  List<Message> messages = [];
  late Message publicacio;

  String ip = Config.ip;

  String languageActual = "ca";

  int actualPage = 2;

  List<int> achivements = [];

  List<dynamic> activitats = [];

  List<dynamic> reports = [];
  
  String userCodi = "0";
  String userComunitat = "0";

  List<Map<String, dynamic>> rankingsUsers = [];
  List<Map<String, dynamic>> rankingsCommunity = [];



  Future<void> saveLanguage(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    languageActual = languageCode;
  }

  bool hasReadNotification = false; // Variable para almacenar el estado de la notificación
  DateTime notificationTime = DateTime.now(); // Variable para almacenar la hora de la notificación
  ValueNotifier<bool> notificationReadStatus = ValueNotifier<bool>(true); // Notificador del estado de lectura de la notificación
  double previousICA = 0; // Guardar el valor anterior del ICA
  Timer? icaMonitorTimer;

  Future<void> saveNotificationReadStatus(bool hasRead) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasReadNotification', hasRead);
    hasReadNotification = hasRead;
    notificationReadStatus.value = hasRead; // Actualizar el notificador
  }

  Future<void> loadNotificationReadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    hasReadNotification = prefs.getBool('hasReadNotification') ?? false;
    notificationTime = DateTime.parse(prefs.getString('notificationTime') ?? DateTime.now().toIso8601String());
    notificationReadStatus.value = hasReadNotification; // Actualizar el notificador
  }

  Future<void> clearNotificationReadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hasReadNotification');
    await prefs.remove('notificationTime');
    hasReadNotification = false;
    notificationReadStatus.value = false; // Actualizar el notificador
  }

  Future<void> initializeNotificationReadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasReadNotification', false);
    notificationTime = DateTime.now();
    await prefs.setString('notificationTime', notificationTime.toIso8601String());
    hasReadNotification = false;
    notificationReadStatus.value = hasReadNotification; // Actualizar el notificador
  }

  // Método para resetear las notificaciones
  void resetNotifications() {
    hasReadNotification = false;
    notificationReadStatus.value = false;
    saveNotificationReadStatus(false);
  }


// Método para iniciar el monitoreo del ICA
  void startMonitoringICA(void Function() onICACheck) {
    icaMonitorTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      await determinePosition();
      if (ICAEstacioPropera != previousICA) {
        previousICA = ICAEstacioPropera;
        onICACheck();
      }
    });
  }

  // Método para detener el monitoreo del ICA
  void stopMonitoringICA() {
    icaMonitorTimer?.cancel();
  }

  // HOME
  Future<void> _getUltimsSetDies(String username) async {
    await http.get(Uri.parse('$ip/dadesubicacio/historic/$username')).then((respuesta) {

      List<dynamic> ultimaSetmana = jsonDecode(utf8.decode(respuesta.bodyBytes));

      ultimaSetmanaDies = [];
      ultimaSetmanaUbs = [];
      ultimaSetmanaICAs = [];

      for (var ultima in ultimaSetmana) {
        String fecha = ultima['fecha'];
        String ciutat = ultima['municipi'];
        int ica = ultima['qualitatAire'];
        ultimaSetmanaDies.add(fecha);
        ultimaSetmanaUbs.add(ciutat);
        ultimaSetmanaICAs.add(ica);
      }

    }).catchError((error) {
      if (kDebugMode) {
        print('Error1: $error');
      }
    });
    _isLoadedPulmo = true;
    notifyListeners(); 
  }

  Future<void> _saveDadaUbicacio(double longitud, double latitud, String ciutat, String username, String fecha, String hora) async {

    var requestBody = jsonEncode({
      'longitud': longitud.toString(),
      'latitud': latitud.toString(),
      'municipi': ciutat,
      'username': username,
      'fecha': fecha,
      'hora': hora
    });

    await http.post(Uri.parse('$ip/dadesubicacio/postdadesubicacio'), headers: {'Content-Type': 'application/json'}, body: requestBody).then((respuesta) {

    }).catchError((error) {
      if (kDebugMode) {
        print('Error2: $error');
      }
    });
  }

  Future<void> _getSuggestedPlaces(double longitud, double latitud) async {

    await http.get(Uri.parse('$ip/dadesestacio/suggestedplaces/$longitud/$latitud')).then((respuesta) {

      List<dynamic> places = jsonDecode(utf8.decode(respuesta.bodyBytes));

      placesMap = {};
      for (var place in places) {
        String name = place['municipi'];
        int icaValue = place['ica'];
        placesMap[name] = icaValue;
      }
      if (kDebugMode) {
        print('SUG: $placesMap');
      }

    }).catchError((error) {
      if (kDebugMode) {
        print('Error3: $error');
      }
    });
  }

  Future<void> _getContaminantsEstacio(String codi, String fecha) async {

    await http.get(Uri.parse('$ip/dadesestacio/$codi')).then((respuesta) {

      List<dynamic> contaminants = jsonDecode(utf8.decode(respuesta.bodyBytes));

      contaminantsMap = {};

      for (var contaminant in contaminants) {
        if (contaminant['quantitat'] != "NaN") {
          String name = contaminant['contaminant'];
          double value = contaminant['quantitat'];
          contaminantsMap[name] = value;
        }
      }

      if (kDebugMode) {
        print('CON: $contaminantsMap');
      }

    }).catchError((error) {
      if (kDebugMode) {
        print('Error4: $error');
      }
    });
  }

  Future<void> _getICAEstacioPropera(String codi) async {

    await http.get(Uri.parse('$ip/dadesestacio/ICA/$codi')).then((respuesta) {

      int x = jsonDecode(utf8.decode(respuesta.bodyBytes));
      ICAEstacioPropera = x.toDouble();

      if (kDebugMode) {
        print('ICA: $ICAEstacioPropera');
      }

    }).catchError((error) {
      if (kDebugMode) {
        print('Error5: $error');
      }
    });
  }

  Future<void> _getEstacioPropera(double longitud, double latitud) async {

    await http.get(Uri.parse('$ip/localitzacionsestacio/$longitud/$latitud')).then((respuesta) async {
      
      Map<String, dynamic> jsonObject = jsonDecode(utf8.decode(respuesta.bodyBytes));
      estacioPropera = jsonObject["codiEstacio"];

      if (kDebugMode) {
        print('ESTACIO: $estacioPropera');
        print('CIUTAT: $ciutat');
      } 
      if (ciutat != "Desconegut" && ciutat != "Accepta els permisos d'ubicació" && ciutat != "No es poden sol·licitar permisos") {
        await _saveDadaUbicacio(longitud, latitud, ciutat, usernameLabel, fecha, hora);
      }
      

    }).catchError((error) {
      if (kDebugMode) {
        print('Error6: $error');
      }
    });
    _getICAEstacioPropera(estacioPropera);
    _getContaminantsEstacio(estacioPropera, fecha);
    await _getSuggestedPlaces(longitud, latitud);
    _getUltimsSetDies(usernameLabel);
    
  }

  Future<void> getLocationPermits() async {

    //bool serviceEnabled;
    LocationPermission permission;
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ciutat = 'Accepta els permisos d\'ubicació';
        exit(0);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ciutat = 'No es poden sol·licitar permisos';
      exit(0);
    }
  }

  Future<void> determinePosition() async {
    if (connected) return;

    getDiaActual();
    if (kDebugMode) {
      print('DIA: ${fecha}T$hora');
    }

    if (ciutat == 'Accepta els permisos d\'ubicació' || ciutat == 'No es poden sol·licitar permisos') return;

    // Cuando tenemos permisos, obtenemos la ubicación actual
    position = await Geolocator.getCurrentPosition();
    mypos = LatLng(position.latitude, position.longitude);

    try {
      if (kDebugMode) {
        print('LON: ${position.longitude}');
        print('LAT: ${position.latitude}');
      }
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      ciutat = place.locality.toString();

    } catch (e) {
      try {
        List<Placemark> nearestPlacemarks = await placemarkFromCoordinates(position.latitude, position.longitude, localeIdentifier: "es_ES");
        Placemark? nearestPlace = nearestPlacemarks.isNotEmpty ? nearestPlacemarks[0] : null;
        if (nearestPlace != null && nearestPlace.name != null) {
          ciutat = nearestPlace.name!.toString();
        }
      } catch (e) {
        ciutat = "Desconegut";
      }
    }

    await _getEstacioPropera(position.longitude, position.latitude);
    getMessages();
    getActivitats();
    await getUser(usernameLabel);
    connected = true;
    
  }

  void getDiaActual() {
    
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    fecha = DateFormat('yyyy-MM-dd').format(today);
    hora = DateFormat('HH:mm:ss').format(now);
  }

  // USER
  Future<void> getUser(String username) async {

    await http.get(Uri.parse('$ip/usuaris/$username')).then((respuesta) async {
            
      userCodi = "0";
      Map<String, dynamic> jsonObject = jsonDecode(utf8.decode(respuesta.bodyBytes));
      
      if (jsonObject["fotoPerfil"] is String) {
        urlPerfil = jsonObject["fotoPerfil"].toString();
      } else {
        urlPerfil = "";
      }

      if (jsonObject["localitzacio"] is String) {
        userCodi = jsonObject["localitzacio"].toString();
      } else {
        userCodi = "0";
      }

      isBlocked = jsonObject["isBlocked"];

      if (kDebugMode) {
        print('CODI.U: $userCodi');
      }
    }).catchError((error) {
      userCodi = "0";
      urlPerfil = "";
      isBlocked = false;
      if (kDebugMode) {
        print('CODI.U: Null $error');
      }
    });

    await _getComunitatUsuari(userCodi);
    if (kDebugMode) {
      print("COMUNITAT USER: $userComunitat");
    }
  }
  
  Future<void> _getComunitatUsuari(String codiestacio) async {
      await http.get(Uri.parse('$ip/localitzacionsestacio/$codiestacio')).then((respuesta) async {
        Map<String, dynamic> jsonObject = jsonDecode(utf8.decode(respuesta.bodyBytes));

        if (jsonObject["municipi"] is String) {
          userComunitat = jsonObject["municipi"].toString();
        } else {
          userComunitat = "0";
        }

      }).catchError((error) {
        userComunitat = "0";
        if (kDebugMode) {
          print('COMUNITAT.U: Null $error');
        }
      });
  }  

  // QUEST
  List<Map<String, dynamic>> questionsMap = [];

  Future<void> getPreguntes() async {
    
    questionsMap = [];
    await http.get(Uri.parse('$ip/preguntes/random/$languageActual')).then((respuesta) {
      
      List<dynamic> preguntes = jsonDecode(utf8.decode(respuesta.bodyBytes));

      for (var pregunta in preguntes) {
        Map<String, dynamic> aux = {};
        aux["nump"] = pregunta['numP'];
        aux["question"] = pregunta['contingut'];
        aux["answers"] = [pregunta['opcioA'], pregunta['opcioB'], pregunta['opcioC'], pregunta['opcioD']];
        questionsMap.add(aux);
      }

      if (kDebugMode) {
        print('Q: $questionsMap');
      }

    }).catchError((error) {
      if (kDebugMode) {
        print('Error8: $error');
      }
    });
  }

  Future<bool> esRespostaCorrecta(int nump, int selected) async {
    
    bool opcio = false;
    await http.get(Uri.parse('$ip/preguntes/$nump/$selected')).then((respuesta) {

      opcio = jsonDecode(utf8.decode(respuesta.bodyBytes));

      if (kDebugMode) {
        print('ANS: $selected -> $opcio');
      }

    }).catchError((error) {
      if (kDebugMode) {
        print('Error9: $error');
      }
    });
    return opcio;
  }

  // PLANT
  Future<void> updatePlant(int puntuacio) async {
    
    var requestBody = jsonEncode({
      'puntuacio': puntuacio,
    });

    await http.patch(Uri.parse('$ip/plantes/update/$usernameLabel'), headers: {'Content-Type': 'application/json'}, body: requestBody).then((respuesta) {

    }).catchError((error) {
      if (kDebugMode) {
        print('Error10: $error');
      }
    });
  }

  Future<void> toPlant() async {
    
    var requestBody = jsonEncode({
      'username': usernameLabel,
    });

    await http.post(Uri.parse('$ip/plantes/toplant'), headers: {'Content-Type': 'application/json'}, body: requestBody).then((respuesta) {
      
      if (kDebugMode) {
        print('PLA: ${respuesta.body}');
      }
      puntuacioAlNivell = 0;
      puntuacioTotal = 0;
      nivell = 1;
      puntuacioNivell = 15;
      lastAnswer = "never";
    }).catchError((error) {
      if (kDebugMode) {
        print('Error11: $error');
      }
    });
  }

  Future<void> getPlanta() async {
    
    await http.get(Uri.parse('$ip/plantes/$usernameLabel')).then((respuesta) {
      
      Map<String, dynamic> dadesPlanta = jsonDecode(utf8.decode(respuesta.bodyBytes));

      puntuacioAlNivell = dadesPlanta['puntuacioAlNivell'];
      puntuacioTotal = dadesPlanta['puntuacioTotal'];
      nivell = dadesPlanta['nivell']['nivell'];
      lastAnswer = dadesPlanta['lastAnswer'];
      puntuacioNivell = dadesPlanta['nivell']['puntuacioNivell'];

      if (kDebugMode) {
        print('PLA: $nivell $lastAnswer $puntuacioTotal $puntuacioAlNivell');
      }

    }).catchError((error) async {

      await toPlant();
      if (kDebugMode) {
        print('NEWP: Nova planta -> $usernameLabel');
      }
    });

    await getAchivements();
  }

  Future<void> getMessages() async {
    String idanswered = "";
    messages = [];
    try {
      final response = await http.get(Uri.parse('$ip/publicacions'));

      if (response.statusCode == 200) {
        
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        
        for (var message in data) {
          if (message['answered']['idPublicacio'] != null) {
            idanswered = message['answered']['idPublicacio'];
          } else {
            idanswered = "";
          }

          Message aux = Message(
            userName: message['usuari']['username'],
            messageText: message['contingut'],
            fecha: message['fecha'],
            hora: message['hora'],
            idPublicacio: message['idPublicacio'],
            idAnswered: idanswered,
            urlAvatar: message['urlAvatar'],
            image: message['imatge']
          );

      
          messages.add(aux);

        }
        if (kDebugMode) {
          print('MES: $messages');
        }
      } else {
        if (kDebugMode) {
          print('Error al obtener los mensajes: ${response.statusCode}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('ErrorForum: $error');
      }
    }
    _isLoadedForum = true;
    notifyListeners();
  }

  Future<void> getAchivements() async {
    
    await http.get(Uri.parse('$ip/assolimentsaconseguits/assolimentslist/$usernameLabel')).then((respuesta) {
      
      achivements = [];
      List<dynamic> dadesAchivements = jsonDecode(utf8.decode(respuesta.bodyBytes));

      for (int i = 0; i < dadesAchivements.length; ++i) {
        achivements.add(dadesAchivements[i]);
      }

      if (kDebugMode) {
        print('LOG: $achivements');
      }

    }).catchError((error) async {
      if (kDebugMode) {
        print('Error15: $error, achivements');
      }
    });
  }

  Future<void> getActivitats() async {
    final response = await http.get(
      Uri.parse('https://culturapp-back.onrender.com/activitats/mediambient'),
      headers: {
        'Authorization': 'Bearer ${Config.tokenAPI}',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      activitats = data.map((item) => {
        'denominaci': item['denominaci'],
        'descripcio': item['descripcio'],
        'data_inici': item['data_inici'],
        'enlla_os': item['enlla_os'],
        'imatges': item['imatges'],
      }).toList();
    } else {
      throw Exception('Error al cargar las actividades');
    }
  }

  Future<void> getReports() async {
    final response = await http.get(
      Uri.parse('$ip/reports'),
      headers: {'Authorization': 'Bearer $token',}
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      print("PAWPAWPAW $data");
      reports = data.map((item) => {
        'idReport': item['idReport'],
        'missatge': item['missatge'],
        'fechaReport': item['fechaReport'],
        'horaReport': item['horaReport'],
        'usuariReportat': item['usuariReportat'],
        'usuariReportador': item['usuariReportador'],
        'idpublicacio': item['idPublicacio'],
      }).toList();
    } else {
      throw Exception('Error al carregar els reports');
    }
  }

  Future<void> sendRankingUsuaris() async {
    final url = Uri.parse('$ip/ranking/usuaris');
    String user = nomUser;
    var requestData = jsonEncode({'username': user});
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestData,
      );

      if (response.statusCode == 200) {
        List<dynamic> responseBody = jsonDecode(utf8.decode(response.bodyBytes));

        Set<String> seenUsernames = {};
        rankingsUsers = responseBody.where((item) {
          // Verificar si el nombre de usuario ya ha sido visto
          if (seenUsernames.contains(item['username'])) {
            return false; // Si ya fue visto, no incluirlo en la lista
          } else {
            seenUsernames.add(item['username']); // Si no fue visto, añadirlo al conjunto
            return true; // Incluirlo en la lista
          }
        }).map((item) => {
          'username': item['username'],
          'posicion': item['posicion'],
          'puntuacionTotal': item['puntuacionTotal']
        }).toList();
      } else {
        if (kDebugMode) {
          print('Error18: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error17: $e');
      }
    }
  }

  Future<void> fetchRankings() async {
    
    final response = await http.get(Uri.parse('$ip/ranking/comunitats'));
    
    await _getComunitatUsuari(userCodi);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      rankingsCommunity = data.map((item) => {
        'municipi': item['municipi'],
        'puntuacion': item['puntuacion']
      }).toList();
    } else {
      throw Exception('Failed to load rankings');
    }
  }

  Future<void> toggleUserBlock(String username, bool isBlocked) async {
    String uri = '$ip/usuaris/toggleBlock';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    Map<String, dynamic> body = {
      'username': username,
      'isBlocked': isBlocked,
    };

    try {
      final response = await http.post(
        Uri.parse(uri),
        headers: headers,
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('User block status updated');
        }
      } else {
        if (kDebugMode) {
          print('Error: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: ${e.toString()}');
      }
    }
  }

  Future<void> getPostById (String postId) async {

    await http.get(Uri.parse('$ip/publicacions/$postId')).then((respuesta) async {
        Map<String, dynamic> message = jsonDecode(utf8.decode(respuesta.bodyBytes));

        String idanswered;

        if (message['answered']['idPublicacio'] != null) {
            idanswered = message['answered']['idPublicacio'];
          } else {
            idanswered = "";
          }

           publicacio = Message(
            userName: message['usuari']['username'],
            messageText: message['contingut'],
            fecha: message['fecha'],
            hora: message['hora'],
            idPublicacio: message['idPublicacio'],
            idAnswered: idanswered,
            urlAvatar: message['urlAvatar'],
            image: message['imatge']
          );
      }).catchError((error) {
        userComunitat = "0";
        if (kDebugMode) {
          print('COMUNITAT.U: Null $error');
        }
      });
  }
}