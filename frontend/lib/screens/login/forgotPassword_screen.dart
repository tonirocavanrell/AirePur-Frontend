import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/providers/locale_provider.dart';
import 'package:frontend/providers/locale_translationProvider.dart';
import 'package:frontend/screens/login/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/utils/s3_image_loader.dart';



class ForgotPasswordScreen extends StatefulWidget {

  final String ip;

  const ForgotPasswordScreen({super.key, required this.ip});

  @override
  State<ForgotPasswordScreen> createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  bool obscurePassword = true;

  String ip = "http://localhost:8080";

  bool login = false;

  String errorMssg = "";
  String emailLabel = "";


  Future<String> _existeixUsuariEmailTelefon() async {

    String existeix = "";
    var requestBody = jsonEncode({
      'email': emailLabel,
    });

    await http.post(Uri.parse('$ip/usuaris/recover'), headers: {'Content-Type': 'application/json'}, body: requestBody).then((respuesta) {

      existeix = jsonDecode(utf8.decode(respuesta.bodyBytes));
      return existeix;
    }).catchError((error) {
      if (kDebugMode) {
        print('Error: $error');
      }
      return "error";
    });

    return existeix;
  }

  Future<String> errorMssgController() async {
    if (emailLabel == "") {
      return "Has d'introduïr un email.";
    }

    return await _existeixUsuariEmailTelefon().then((resultado) {
      if (resultado == "correo") {
        return "L'email introduït no existeix.";
      } else if (resultado == "error") {
        return "Error";
      } else {
        return "";
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
          Text(
            errorMssg,
            style: const TextStyle(
                fontSize: 15,
                color: Colors.red
            ),
          ),
        ],
      );
    }
  }

  MaterialApp _buildForgotPasswordContainer(BuildContext context, screenHeight, double screenWidth) {
    //var localizations = AppLocalizations.of(context)!;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 230, 250, 255),
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 40, 30, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            login = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      S3ImageLoader.loadImage(
                        'assets/alert_icon.png',  // Solo el nombre del archivo
                        width: screenWidth * 0.5,
                      ),

                      // recover pwd mssg
                      const SizedBox(height: 40),
                      Text(
                        textAlign: TextAlign.center,
                        TranslationService().translate('pswRecov'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30
                        ),
                      ),

                      // mssg intro email
                      const SizedBox(height: 10),
                      Text(
                        textAlign: TextAlign.center,
                        TranslationService().translate('sendPsw'),
                        style: const TextStyle(
                          fontSize: 15
                        ),
                      ),

                      // label email
                      const SizedBox(height: 40),
                      ClipRRect(
                        child: Container(
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
                              hintText: TranslationService().translate('enterEmail'),
                              labelText: 'Email',
                              border: InputBorder.none, // No mostrar el borde del TextField
                            ),
                          ),
                        ),
                      ),

                      // error mssg
                      const SizedBox(height: 20),
                      buildErrorMssg(),

                      // confirm
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            errorMssgController().then((resultado) {
                              setState(() {
                                errorMssg = resultado;
                              });

                              if (errorMssg == "") {
                                setState(() {
                                  login = true;
                                });
                              }
                            });
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                        ),
                        child: Text(
                          TranslationService().translate('confirm'), 
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // encara no tens compte
                      const SizedBox(height: 80),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                login = true;
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.zero,
                              child: Text(
                                TranslationService().translate('loginAgain'), 
                                style: const TextStyle(
                                    color: Colors.blue
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                )
              ],
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

    if (!login) {
      content = _buildForgotPasswordContainer(context, screenHeight, screenWidth);
    } else {
      content = LoginScreen(ip: ip);
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