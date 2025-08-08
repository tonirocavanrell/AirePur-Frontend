import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/providers/locale_translationProvider.dart';
import 'package:frontend/screens/activitats/activitats_screen.dart';
import 'package:frontend/screens/forum/forum.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'package:frontend/screens/login/login_screen.dart';
import 'package:frontend/screens/lung/lung_screen.dart';
import 'package:frontend/screens/map/map_screen.dart';
import 'package:frontend/screens/notifications/notifications_screen.dart';
import 'package:frontend/screens/plant/plant_screen.dart';
import 'package:frontend/screens/web_app/gestiona_reports_screen.dart';
import 'package:frontend/utils/load_data.dart';
import 'package:frontend/utils/s3_image_loader.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyNavigationBar extends StatefulWidget {
  final LoadData ld;
  final actual;

  const MyNavigationBar({super.key, required this.ld, required this.actual});

  @override
  State<MyNavigationBar> createState() => MyNavigationBarState();
}

class MyNavigationBarState extends State<MyNavigationBar> {
  late int actual_page;
  double icon_size = 25;
  late String selectedLanguage; // Added for language selection

  double curvaturaWidgets = 18.0;

  late String ciutat;
  late double ICAEstacioPropera;
  late Map<String, double> contaminants;
  late Map<String, int> suggestedplaces;

  List<Widget> pages = [];

  List<String> ultimaSetmanaDies = [];
  List<String> ultimaSetmanaUbs = [];
  List<int> ultimaSetmanaICAs = [];

  String ip = "";
  late LatLng? mypos;

  late String username;

  late LoadData ld;

  List<Message> messages = [];
  
  bool carregat = false;

  bool isButtonEnabled = true;
  String errorMssg = "";
  String nomLabel = "";
  String edatLabel = "";
  String tlfLabel = "";
  String emailLabel = "";
  String pwdLabel = "";
  String pwdConfLabel = "";
  String deleteLabel = "";
  int ageLabel = 0;
  String urlPerfil = "";

  S3ImageUploader s3ImageUploader = S3ImageUploader();

  bool _telefonCorrecte() {
    if (tlfLabel.toString().length == 9 || (tlfLabel.toString().length == 1 && tlfLabel == 0)) {
      return true;
    }
    return false;
  }

  bool _emailCorrecte(String email) {
  // Expresión regular para validar el formato del email
  String pattern = r'^[^@]+@[^@]+\.[^@]+$';
  RegExp regExp = RegExp(pattern);
  return regExp.hasMatch(email);
  }

  Future<bool> _updateFoto() async {

    bool existeix = false;
    var requestBody = jsonEncode({
      'username': ld.usernameLabel,
      'url': ld.urlPerfil
    });
    await http.post(Uri.parse('$ip/usuaris/${ld.usernameLabel}/urlPerfil'), headers: {'Content-Type': 'application/json'}, body: requestBody).then((respuesta) {
      
      if (respuesta.body == "ok") existeix = true;
    }).catchError((error) {
      if (kDebugMode) {
        print('Error: $error');
      }
      existeix = false;
    });

    isButtonEnabled = true;
    return existeix;
  }

  Future<bool> _updateNom() async {

    bool existeix = false;
    var requestBody = jsonEncode({
      'username': ld.usernameLabel,
      'name': nomLabel
    });
    
    await http.post(Uri.parse('$ip/usuaris/updateNom'), headers: {'Content-Type': 'application/json'}, body: requestBody).then((respuesta) {
      
      if (respuesta.body == "ok") existeix = true;
    }).catchError((error) {
      if (kDebugMode) {
        print('Error: $error');
      }
      existeix = false;
    });

    isButtonEnabled = true;
    return existeix;
  }

  Future<bool> _updatePwd() async {

    bool existeix = false;
    var requestBody = jsonEncode({
      'username': ld.usernameLabel,
      'pass': sha256.convert(utf8.encode(pwdLabel)).toString()
    });
    
    await http.post(Uri.parse('$ip/usuaris/updatePass'), headers: {'Content-Type': 'application/json'}, body: requestBody).then((respuesta) {
      
      if (respuesta.body == "ok") existeix = true;
    }).catchError((error) {
      if (kDebugMode) {
        print('Error: $error');
      }
      existeix = false;
    });

    isButtonEnabled = true;
    return existeix;
  }

  Future<bool> _updateTel() async {

    bool existeix = false;
    var requestBody = jsonEncode({
      'username': ld.usernameLabel,
      'tel': tlfLabel
    });
    
    await http.post(Uri.parse('$ip/usuaris/updateTel'), headers: {'Content-Type': 'application/json'}, body: requestBody).then((respuesta) {
      
      if (respuesta.body == "ok") existeix = true;
    }).catchError((error) {
      if (kDebugMode) {
        print('Error: $error');
      }
      existeix = false;
    });

    isButtonEnabled = true;
    return existeix;
  }

  Future<bool> _updateEmail() async {

    bool existeix = false;
    var requestBody = jsonEncode({
      'username': ld.usernameLabel,
      'email': emailLabel
    });
    
    await http.post(Uri.parse('$ip/usuaris/updateEmail'), headers: {'Content-Type': 'application/json'}, body: requestBody).then((respuesta) {
      
      if (respuesta.body == "ok") existeix = true;
    }).catchError((error) {
      if (kDebugMode) {
        print('Error: $error');
      }
      existeix = false;
    });

    isButtonEnabled = true;
    return existeix;
  }

  Future<String> errorMssgController(String op, BuildContext context) async {
    
    if (op == "nom") {
      if (nomLabel == "") {
        _showEmptyAlert(TranslationService().translate('emptyName'), context);
        return TranslationService().translate('emptyName');
      } 

      if (await _updateNom()) {
        return "";
      }
      return TranslationService().translate('errorNom');
      
    } else if (op == "pwd") {
      if (pwdLabel == "" || pwdConfLabel == "") {
        _showEmptyAlert(TranslationService().translate('emptyPwd'), context);
        return TranslationService().translate('emptyPwd');
      } else if (pwdLabel != pwdConfLabel) {
        _showEmptyAlert(TranslationService().translate('passwordsDoNotMatch'), context);
        return TranslationService().translate('passwordsDoNotMatch');
      }

      if (await _updatePwd()) {
        return "";
      }
      return "error pwd";
    } else if (op == "tlf") {
      if (!_telefonCorrecte()) {
        _showEmptyAlert(TranslationService().translate('enterValidPhone'), context);
        return TranslationService().translate('enterValidPhone');
      }
      if (await _updateTel()) {
        return "";
      } else {
        _showEmptyAlert(TranslationService().translate('phoneExists'), context);
      }
      return TranslationService().translate('errorTlf');
    } else if (op == "email") {
      if (!_emailCorrecte(emailLabel)) {
        _showEmptyAlert(TranslationService().translate('incorrectEmail'), context);
        return TranslationService().translate('incorrectEmail');
      }
      if (await _updateEmail()) {
        return "";
      } else {
        _showEmptyAlert(TranslationService().translate('emailExists'), context);
      }
      return "error email";
    } else if (op == "delete") {
      if (deleteLabel != "CONFIRMAR" && deleteLabel != "CONFIRM") {
        _showEmptyAlert(TranslationService().translate('cannotDeleteAccount'), context);
        return TranslationService().translate('deleteIncorrect');
      }

      if (await _esborrarCompte()) {
        return "";
      } else {
        _showEmptyAlert(TranslationService().translate('accountnotDeleted'), context);
      }
      return "error delete";
    }

    return "error";
  }

  Future<bool> _esborrarCompte() async {

    bool existeix = false;
    var requestBody = jsonEncode({
      'username': username,
    });

    await http.post(Uri.parse('$ip/usuaris/remove'), headers: {'Content-Type': 'application/json'}, body: requestBody).then((respuesta) {

      if (jsonDecode(respuesta.body)) {
        existeix = true;
        if (kDebugMode) {
          print("Account with username $username, has been erased.");
        }
      }
    }).catchError((error) {
      existeix = false;
      if (kDebugMode) {
        print('Error: $error');
      }
    });

    isButtonEnabled = true;
    return existeix;
  }

  void _showEmptyAlert(String title, BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
          title: Text(title),
          backgroundColor: Colors.white, // Cambia el color de fondo
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(curvaturaWidgets),
            side: const BorderSide(color: Colors.black87, width: 3), // Añade un borde
          ),
          elevation: 8,
          actions: [
            TextButton(
              onPressed: () {
                isButtonEnabled = true;
                Navigator.of(context).pop(); // Cerrar el AlertDialog
              },
              child: Text(TranslationService().translate('close')),
            ),
          ],
          )
        );
      },
    );
  }
  
  void _updateDeletePerfil(String title, BuildContext context) {
    deleteLabel = "";

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
          title: Text(title),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(curvaturaWidgets),
            side: const BorderSide(color: Colors.black87, width: 3),
          ),
          elevation: 8,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          content: ClipRRect(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black)), // Bordes solo en la parte inferior
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        deleteLabel = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: TranslationService().translate('writeCONFIRM'),  // Traducción
                      labelText: TranslationService().translate('writeCONFIRM'),  // Traducción
                      border: InputBorder.none, // No mostrar el borde del TextField
                    ),
                  ),
                ),
              ]
          )
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: isButtonEnabled
                    ? () {
                      setState(() {
                        isButtonEnabled = false;
                      });

                      // Ejecutar la función original
                      errorMssgController("delete", context).then((resultado) {
                        setState(() {
                          errorMssg = resultado;
                        });

                        if (errorMssg == "") {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          _tancarSessio();
                        }

                        setState(() {
                          isButtonEnabled = true;
                        });
                      });
                    }
                  : null,
                  child: Text(
                    TranslationService().translate('deleteAccount'),
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(TranslationService().translate('close')),
                )
              ],
            )
          ],
          )
        );
      },
    );
  }

  void _updatePwdPerfil(String title, BuildContext context) {
    pwdLabel = "";
    pwdConfLabel = "";

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
          title: Text(title),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(curvaturaWidgets),
            side: const BorderSide(color: Colors.black87, width: 3),
          ),
          elevation: 8,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          content: ClipRRect(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black)), // Bordes solo en la parte inferior
                  ),
                  child: Column(children: [
                    TextField(
                    onChanged: (value) {
                      setState(() {
                        pwdLabel = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: TranslationService().translate('password'),  // Traducción
                      labelText: TranslationService().translate('password'),  // Traducción
                      border: InputBorder.none, // No mostrar el borde del TextField
                    ),
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        pwdConfLabel = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: TranslationService().translate('confirmPasswordHint'),  // Traducción
                      labelText: TranslationService().translate('confirmPasswordHint'),  // Traducción
                      border: InputBorder.none, // No mostrar el borde del TextField
                    ),
                  ),
                  ],) 
                ),
              ]
          )
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: isButtonEnabled
                    ? () {
                      setState(() {
                        isButtonEnabled = false;
                      });

                      // Ejecutar la función original
                      errorMssgController("pwd", context).then((resultado) {
                        setState(() {
                          errorMssg = resultado;
                        });

                        if (errorMssg == "") {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        }

                        setState(() {
                          isButtonEnabled = true;
                        });
                      });
                    }
                  : null,
                  child: Text(
                    TranslationService().translate('update'),
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(TranslationService().translate('close')),
                )
              ],
            )
          ],
          )
        );
      },
    );
  }

  void _updateNomPerfil(String title, BuildContext context) {
    nomLabel = "";

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
          title: Text(title),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(curvaturaWidgets),
            side: const BorderSide(color: Colors.black87, width: 3),
          ),
          elevation: 8,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          content: ClipRRect(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black)), // Bordes solo en la parte inferior
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        nomLabel = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: TranslationService().translate('name'),  // Traducción
                      labelText: TranslationService().translate('firstNameHint'),  // Traducción
                      border: InputBorder.none, // No mostrar el borde del TextField
                    ),
                  ),
                ),
              ]
          )
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: isButtonEnabled
                    ? () {
                      setState(() {
                        isButtonEnabled = false;
                      });

                      // Ejecutar la función original
                      errorMssgController("nom", context).then((resultado) {
                        setState(() {
                          errorMssg = resultado;
                        });

                        if (errorMssg == "") {
                          setState(() {
                            ld.nomUser = nomLabel;
                          });
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        }

                        setState(() {
                          isButtonEnabled = true;
                        });
                      });
                    }
                  : null,
                  child: Text(
                    TranslationService().translate('update'),
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(TranslationService().translate('close')),
                )
              ],
            )
          ],
          )
        );
      },
    );
  }

  void _updateTlfPerfil(String title, BuildContext context) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          // ignore: deprecated_member_use
          return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(title),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(curvaturaWidgets),
              side: const BorderSide(color: Colors.black87, width: 3),
            ),
            elevation: 8,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            content: ClipRRect(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.black)), // Bordes solo en la parte inferior
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          tlfLabel = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: TranslationService().translate('tlfLabel'),  // Traducción
                        labelText: TranslationService().translate('tlfHint'),  // Traducción
                        border: InputBorder.none, // No mostrar el borde del TextField
                      ),
                    ),
                  ),
                ]
            )
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: isButtonEnabled
                      ? () {
                        setState(() {
                          isButtonEnabled = false;
                        });

                        // Ejecutar la función original
                        errorMssgController("tlf", context).then((resultado) {
                          setState(() {
                            errorMssg = resultado;
                          });

                          if (errorMssg == "") {
                            setState(() {
                              ld.tlf = tlfLabel;
                            });
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          }
                        });
                      }
                    : null,
                    child: Text(
                      TranslationService().translate('update'),
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(TranslationService().translate('close')),
                  )
                ],
              )
            ],
          )
          );
        },
      );
    }

  void _updateEmailPerfil(String title, BuildContext context) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          // ignore: deprecated_member_use
          return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(title),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(curvaturaWidgets),
              side: const BorderSide(color: Colors.black87, width: 3),
            ),
            elevation: 8,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            content: ClipRRect(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.black)), // Bordes solo en la parte inferior
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          emailLabel = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: TranslationService().translate('email'),  // Traducción
                        labelText: TranslationService().translate('emailHint'),  // Traducción
                        border: InputBorder.none, // No mostrar el borde del TextField
                      ),
                    ),
                  ),
                ]
            )
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: isButtonEnabled
                      ? () {
                        setState(() {
                          isButtonEnabled = false;
                        });

                        // Ejecutar la función original
                        errorMssgController("email", context).then((resultado) {
                          setState(() {
                            errorMssg = resultado;
                          });

                          if (errorMssg == "") {
                            setState(() {
                              ld.email = emailLabel;
                            });
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          }
                        });
                      }
                    : null,
                    child: Text(
                      TranslationService().translate('update'),
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(TranslationService().translate('close')),
                  )
                ],
              )
            ],
          )
          );
        },
      );
    }

  void _tancarSessio() async {
    await widget.ld.clearNotificationReadStatus(); // Borrar el estado de lectura de la notificación
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(ip: ip)),
    );
  }

  @override
  void initState() {
    super.initState();
    actual_page = widget.actual;
    loadLanguagePreference();
    ld = widget.ld;
    ld.determinePosition().then((_) {
      // Después de que la función termine, actualizas el estado para reflejar que ya no está cargando
      setState(() {
        carregat = true;
      });
    });
    initializeNotifications();
     startICAMonitoring();
  }

  Future<void> loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    selectedLanguage = prefs.getString('language') ?? 'ca';
    TranslationService().loadTranslations(ld.languageActual);
  }

  Future<void> initializeNotifications() async {
    await widget.ld.initializeNotificationReadStatus();
  }

  Future<void> saveLanguage(String newLanguage) async {
    ld.saveLanguage(newLanguage);
  }

  void startICAMonitoring() {
    ld.startMonitoringICA(() {
      setState(() {
        ld.resetNotifications();
      });
    });
  }

  BuildNavBar() {
    ClipOval c;
    if (ld.tlf == "0" || ld.tlf == "") {
      ld.tlf = "-";
    }
    if (ld.edat == "0"|| ld.edat == "") {
      ld.edat = "-";
    }
    if (ld.urlPerfil == "") {
      c = ClipOval(
        child: SizedBox(
          width: icon_size * 2,
          height: icon_size * 2,
          child: S3ImageLoader.loadImage(
            'assets/default.png',
          ),
        ),
      );
    } else {
      c = ClipOval(
        child: SizedBox(
          width: icon_size * 2,
          height: icon_size * 2,
          child: S3ImageLoader.loadImage(
            ld.urlPerfil,
          ),
        ),
      );
    }
    bool navBarTrans = false;
    Color colNavBar = const Color.fromRGBO(115, 198, 252, 100);
    if (actual_page != 3) {
    navBarTrans = false;
    colNavBar = const Color.fromRGBO(115, 198, 252, 100);
    } else {
    navBarTrans = true;
    colNavBar = Colors.transparent;
    }
    return Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: navBarTrans,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            const SizedBox(width: 10),
            Row(
              children: [
                IconButton(
                  icon: S3ImageLoader.loadImage('assets/newspaper_icon.png', width: icon_size, height: icon_size),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ActivitatsScreen(ld: widget.ld)),
                    );
                  },
                ),
                if (ld.isAdmin) IconButton(
                  icon: const Icon(Icons.report),
                  color: Colors.black,
                  iconSize: 30,
                  onPressed: () {
                    ld.getReports();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LlistaReportsScreen(ld: widget.ld)),
                    );
                  },
                ),
              ],
            ),
            const Spacer(), // Espaciador flexible para empujar los siguientes íconos a la derecha
            ValueListenableBuilder(
              valueListenable: widget.ld.notificationReadStatus,
              builder: (context, bool hasUnreadNotifications, child) {
                return Stack(
                  children: [
                    IconButton(
                        icon: S3ImageLoader.loadImage('assets/notifications_icon.png', width: icon_size, height: icon_size),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NotificationsScreen(ica: ICAEstacioPropera, ld: widget.ld)),
                          );
                        },
                    ),
                    if (!hasUnreadNotifications)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: S3ImageLoader.loadImage('assets/profile_icon.png', width: icon_size, height: icon_size),
              onPressed: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    // ignore: deprecated_member_use
                    return  WillPopScope(
                      onWillPop: () async => false,
                      child: AlertDialog(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              ld.usernameLabel,
                              textAlign: TextAlign.left,
                            ),
                          ),
                          const SizedBox(width: 8),
                          c
                        ],
                      ),
                      backgroundColor: Colors.white, // Cambia el color de fondo
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(curvaturaWidgets),
                        side: const BorderSide(color: Colors.black87, width: 3), // Añade un borde
                      ),
                      elevation: 8,
                      content: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded (
                                        child: RichText(
                                            text: TextSpan(
                                              text: '${TranslationService().translate('name')}: ',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black, // Color del texto en negro
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: ld.nomUser,
                                                  style: const TextStyle(fontWeight: FontWeight.normal),
                                                ),
                                              ],
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit), // Icono de editar
                                        iconSize: 20, // Tamaño del icono
                                        onPressed: () {
                                          _updateNomPerfil(TranslationService().translate('modifyYourName'), context);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: '${TranslationService().translate('password')}: ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black, // Color del texto en negro
                                          ),
                                          children: const <TextSpan>[
                                            TextSpan(
                                              text: '********',
                                              style: TextStyle(fontWeight: FontWeight.normal),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit), // Icono de editar
                                        iconSize: 20, // Tamaño del icono
                                        onPressed: () {
                                          _updatePwdPerfil(TranslationService().translate('modifyYourPassword'), context);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: '${TranslationService().translate('yearBorn')}: ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black, // Color del texto en negro
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: ld.edat,
                                              style: const TextStyle(fontWeight: FontWeight.normal),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.left,
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: '${TranslationService().translate('tlfLabel')}: ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black, // Color del texto en negro
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: ld.tlf,
                                              style: const TextStyle(fontWeight: FontWeight.normal),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit), // Icono de editar
                                        iconSize: 20, // Tamaño del icono
                                        onPressed: () {
                                          _updateTlfPerfil(TranslationService().translate('modifyYourPhone'), context);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            text: '${TranslationService().translate('email')}: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black, // Color del texto en negro
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: ld.email,
                                                style: const TextStyle(fontWeight: FontWeight.normal),
                                              ),
                                            ],
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit), // Icono de editar
                                        iconSize: 20, // Tamaño del icono
                                        onPressed: () {
                                          _updateEmailPerfil(TranslationService().translate('modifyYourEmail'), context);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Column(
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      String? imageUrl = await s3ImageUploader.uploadProfileImage(ld.usernameLabel);
                                      setState(() {
                                        ld.urlPerfil = imageUrl!; 
                                      });
                                      _updateFoto();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(TranslationService().translate('editafotoPerfil')),
                                  ),
                                  const SizedBox(height: 10),
                                  TextButton(
                                    onPressed: () {
                                      _updateDeletePerfil(TranslationService().translate('deleteAccount'), context);
                                    },
                                    child: Text(
                                      TranslationService().translate('deleteAccount'), // Cambiar el texto del botón
                                      style: const TextStyle(color: Colors.black), // Color del texto en negro
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  DropdownButton<String>(
                                    value: ld.languageActual,
                                    onChanged: (String? newLanguage) {
                                      if (newLanguage != null) {
                                        setState(() {
                                          TranslationService().loadTranslations(newLanguage);
                                          selectedLanguage = newLanguage;
                                          saveLanguage(newLanguage);  // Guardar el idioma seleccionado en SharedPreferences
                                        });
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: 'en',
                                        child: Text(TranslationService().translate('english')),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'es',
                                        child: Text(TranslationService().translate('spanish')),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'ca',
                                        child: Text(TranslationService().translate('catalan')),
                                      ),
                                    ],
                                  ),
                                ],
                              )

                            ],
                          ),
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                  _tancarSessio();
                                },
                                child: Text(TranslationService().translate('logout'), overflow: TextOverflow.ellipsis),
                              ),
                            ),                  
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the AlertDialog
                                },
                                child: Text(TranslationService().translate('close'), overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ],
                        )
                      ],
                      )
                    );
                  },
                );
              },
            ),
            const SizedBox(width: 10)
          ],
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: S3ImageLoader.loadImageAsImageProvider('assets/background_image.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            pages[actual_page],
          ]
        ),
        bottomNavigationBar: SizedBox(
          child: BottomNavigationBar(
            backgroundColor: colNavBar,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              if (index != actual_page) {
                setState(() {
                  actual_page = index;
                  ld.actualPage = index;
                });
              }
            },
            currentIndex: actual_page,
            selectedFontSize: 0.0, // Establece el tamaño de fuente seleccionado como 0 para que no se muestre texto
            unselectedFontSize: 0.0, // Establece el tamaño de fuente no seleccionado como 0 para que no se muestre texto
            items: [
              BottomNavigationBarItem(
                  icon: S3ImageLoader.loadImage('assets/location_icon.png', width: icon_size, height: icon_size),
            activeIcon: S3ImageLoader.loadImage('assets/green_location_icon.png', width: icon_size, height: icon_size),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: S3ImageLoader.loadImage('assets/lung_icon.png', width: icon_size, height: icon_size),
                activeIcon: S3ImageLoader.loadImage('assets/green_lung_icon.png', width: icon_size, height: icon_size),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: S3ImageLoader.loadImage('assets/home_icon.png', width: icon_size, height: icon_size),
                activeIcon: S3ImageLoader.loadImage('assets/green_home_icon.png', width: icon_size, height: icon_size),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: S3ImageLoader.loadImage('assets/plant_icon.png', width: icon_size, height: icon_size),
                activeIcon: S3ImageLoader.loadImage('assets/green_plant_icon.png', width: icon_size, height: icon_size),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: S3ImageLoader.loadImage('assets/forum_icon.png', width: icon_size, height: icon_size),
                activeIcon: S3ImageLoader.loadImage('assets/green_forum_icon.png', width: icon_size, height: icon_size),
                label: "",
              ),
            ],
          ),
        ),
      );
    }

  @override
  Widget build(BuildContext context) {

    ciutat = widget.ld.ciutat;
    ICAEstacioPropera = widget.ld.ICAEstacioPropera;
    contaminants = widget.ld.contaminantsMap;
    suggestedplaces = widget.ld.placesMap;

    ultimaSetmanaDies = widget.ld.ultimaSetmanaDies;
    ultimaSetmanaUbs = widget.ld.ultimaSetmanaUbs;
    ultimaSetmanaICAs = widget.ld.ultimaSetmanaICAs;

    ip = widget.ld.ip;
    mypos = widget.ld.mypos;

    username = widget.ld.usernameLabel;

    selectedLanguage = ld.languageActual;

    messages = widget.ld.messages;

    pages = [
      MapScreen(ip: ip, mypos: mypos, ld: ld),
      LungScreen(ld: ld),
      HomeScreen(ciutat: ciutat, ica: ICAEstacioPropera.toInt(), contaminants: contaminants, suggestedplaces: suggestedplaces),
      PlantScreen(ld: ld, mypos: mypos),
      ForumPage(ld: ld)
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(

        body: !carregat
            ? const Center(child: CircularProgressIndicator())
            : BuildNavBar(), // Muestra el contenido después de que la carga haya terminado
      ),
    );
  }
}