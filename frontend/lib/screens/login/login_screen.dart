import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/providers/locale_provider.dart';
import 'package:frontend/providers/locale_translationProvider.dart';
import 'package:frontend/screens/login/forgotPassword_screen.dart';
import 'package:frontend/utils/s3_image_loader.dart';
import 'package:frontend/utils/auth_service.dart';
import 'package:frontend/widgets/navigation_bar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../signup/signup_screen.dart';
import 'package:crypto/crypto.dart';
import 'dart:async';

import 'package:frontend/utils/load_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {

  final String ip;

  const LoginScreen({super.key, required this.ip});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {

  bool obscurePassword = true;

  String ip = "";

  bool login = false;
  bool signup = false;
  bool forgotPwd = false;

  String errorMssg = "";
  String usernameLabel = "";
  String passwordLabel = "";
  String passwordHashed = "";
  String emailLabel = "";

  bool isButtonEnabled = true;

  LoadData ld = LoadData();
  
  bool bloquejat = false;

  Future<String> loginGoogle(BuildContext context) async {
    
    GoogleSignInAccount? user = await AuthService.logInGoogle();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in failed')));
      return "Error: Google sign in failed.";
    }

    usernameLabel = user.displayName!;
    emailLabel = user.email;
    passwordHashed = "google";
    return await _existeixUsuariContrasenya().then((resultado) {
      if (resultado) {
        ld.usernameLabel = usernameLabel;
        return "";
      } else {
        return 'GoogleSignIn Error';
      }
    });
  }

  Future<bool> _existeixUsuariContrasenya() async {

    bool existeix = false;
    var requestBody = jsonEncode({
      'username': usernameLabel,
      'password': passwordHashed,
      'email': emailLabel,
    });
    await http.post(Uri.parse('$ip/usuaris/login'), headers: {'Content-Type': 'application/json'}, body: requestBody).then((respuesta) {
      Map<String, dynamic> jsonObject = jsonDecode(respuesta.body);
      ld.nomUser = jsonObject['nom'];
      ld.usernameLabel = jsonObject['username'];
      ld.edat = jsonObject['edat'].toString();
      if (jsonObject['tlf'] is String) {
        ld.tlf = jsonObject['tlf'].toString();
      } else {
        ld.tlf = "0";
      }
      ld.email = jsonObject['email'];
      ld.isAdmin = jsonObject['administrador'];
      ld.isBlocked = jsonObject['isBlocked'];
      
      isButtonEnabled = true;
      existeix = true;
    }).catchError((error) {
      isButtonEnabled = true;
      if (kDebugMode) {
        print('ErrorLogin: $error');
      }
      existeix = false;
    });

    isButtonEnabled = true;

    if (ld.isBlocked) {
      bloquejat = true;
      existeix = false;
    }

    if (ld.isAdmin) 
    {
      Map<String, String> requestBodyAdmin = {
        'username': usernameLabel,
        'password': passwordHashed,
      };

      try {
        final response = await http.post(Uri.parse('$ip/usuaris/adminToken'), headers: {'Content-Type': 'application/json'}, body: json.encode(requestBodyAdmin));
        if (response.statusCode == 200) {
          ld.token = response.body;
        } else {
          if (kDebugMode) {
            print('Failed to fetch token: ${response.statusCode}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error occurred while fetching token: $e');
        }
      }
    } 
    return existeix;
  }


  Future<String> errorMssgController(BuildContext context) async {
    
    //var localizations = AppLocalizations.of(context);
    if (usernameLabel == "") {
      isButtonEnabled = true;
      return TranslationService().translate('enterUsername');  // Traducción
    } else if (passwordLabel == "") {
      isButtonEnabled = true;
      return TranslationService().translate('enterPassword');  // Traducción
    }

    return await _existeixUsuariContrasenya().then((resultado) {
      if (resultado) {
        return "";
      } else if (bloquejat){
        return TranslationService().translate('cuentaBloq');
      } else {
        return TranslationService().translate('incorrectUserOrPassword');
      }
    });
  }

  Widget buildErrorMssg() {

    if (errorMssg == "") {
      return const Row();
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              errorMssg,
              style: const TextStyle(
                  fontSize: 15,
                  color: Colors.red
              ),
            ),
          ),
        ],
      );
    }
  }

  MaterialApp _buildLoginContainer(BuildContext context, double screenHeight, double screenWidth) {
    //var localizations = AppLocalizations.of(context)!;

    Color iconCol;
    if (obscurePassword) {
      iconCol = Colors.black87;
    } else {
      iconCol = Colors.black54;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 230, 250, 255),
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 40),
                  SizedBox(
                      height: 180,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          S3ImageLoader.loadImage(
                            'assets/logo.png',
                            width: screenWidth * 0.6,
                          ),
                        ],
                      )
                  ),

                  // label username
                  const SizedBox(height: 30),
                  // error mssg
                  buildErrorMssg(),
                  ClipRRect(
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.black)), // Bordes solo en la parte inferior
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            usernameLabel = value;
                            ld.usernameLabel = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: TranslationService().translate('usernameHint'),  // Traducción
                          labelText: TranslationService().translate('usernameLabel'),  // Traducción
                          border: InputBorder.none, // No mostrar el borde del TextField
                        ),
                      ),
                    ),
                  ),

                  // label pwd
                  const SizedBox(height: 20),
                  ClipRRect(
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.black)),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            passwordLabel = value;
                            passwordHashed = sha256.convert(utf8.encode(value)).toString();
                            value = '*' * value.length;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: TranslationService().translate('passwordHint'),  // Traducción
                          labelText: TranslationService().translate('passwordLabel'),  // Traducción
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(
                                Icons.visibility,
                                size: 25,
                                color: iconCol
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: obscurePassword,
                        enableSuggestions: false,
                        autocorrect: false,
                      ),
                    ),
                  ),

                  // has oblidat contrasenya
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            forgotPwd = true;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.zero,
                          child: Text(
                            TranslationService().translate('forgotPassword'),
                            style: const TextStyle(
                                color: Colors.blue
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // iniciar sessio
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: isButtonEnabled
                      ? () {
                          setState(() {
                            isButtonEnabled = false;
                          });

                          // Ejecutar la función original
                          errorMssgController(context).then((resultado) {
                            setState(() {
                              errorMssg = resultado;
                            });

                            if (errorMssg == "") {
                              setState(() {
                                login = true;
                              });
                            }
                          });
                        }
                      : null, // Si el botón está deshabilitado, onPressed debe ser null
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    child: Text(
                      TranslationService().translate('loginButton'),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // inicia sessio amb
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Divider(
                          color: Colors.black,
                          thickness: 1.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          TranslationService().translate('loginWith'),
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: Colors.black, // Color de la línea
                          thickness: 1.0, // Grosor de la línea
                        ),
                      ),
                    ],
                  ),

                  // botons google raco etc
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: S3ImageLoader.loadImage('assets/google_icon.png', width: 40, height: 40),
                        onPressed: isButtonEnabled
                          ? () {
                              /*setState(() {
                                isButtonEnabled = true;
                              })*/

                              loginGoogle(context).then((resultado) {
                                setState(() {
                                  errorMssg = resultado;
                                });

                                if (errorMssg == "") {
                                  setState(() {
                                    login = true;
                                  });
                                }
                              });
                            }
                          : null,
                      )
                    ],
                  ),

                  // encara no tens compte
                  const SizedBox(height: 60),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          TranslationService().translate('noAccount'),
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  signup = true;
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.zero,
                                child: Text(
                                  TranslationService().translate('joinNow'),
                                  style: const TextStyle(
                                      color: Colors.blue
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    ip = widget.ip;

    Widget content;

    if (!login & !signup & !forgotPwd) {
      content = _buildLoginContainer(context, screenHeight, screenWidth);
    } else if (signup) {
      content = SignupScreen(ip: ip);
    } else if (forgotPwd) {
      content = ForgotPasswordScreen(ip: ip);
    } else {
      content = MyNavigationBar(ld: ld, actual: ld.actualPage);
    }

    return MaterialApp(
      locale: Provider.of<LocaleProvider>(context).locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: content,
    );
  }
}