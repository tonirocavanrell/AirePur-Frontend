import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/providers/locale_provider.dart';
import 'package:frontend/providers/locale_translationProvider.dart';
import 'package:frontend/utils/load_data.dart';
import 'package:frontend/utils/s3_image_loader.dart'; // Importa tu clase S3ImageUploader aquí
import 'package:frontend/widgets/navigation_bar.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../login/login_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignupScreen extends StatefulWidget {
  final String ip;

  const SignupScreen({super.key, required this.ip});

  @override
  State<SignupScreen> createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  bool obscurePassword = true;
  String ip = "";
  bool signup = false;
  bool login = false;
  String errorMssg = "";
  String usernameLabel = "";
  String nameLabel = "";
  String surnamesLabel = "";
  String emailLabel = "";
  String passwordLabel = "";
  String confirmPasswordLabel = "";
  String passwordHashed = "";
  int tlfLabel = 0;
  int ageLabel = 0;
  String selectedLanguage = "ca";
  String? profileImageUrl; // Para almacenar la URL de la imagen de perfil subida
  String? forumImageUrl; // Para almacenar la URL de la imagen del foro subida

  LoadData ld = LoadData();
  S3ImageUploader s3ImageUploader = S3ImageUploader(); // Instancia de S3ImageUploader

  

  bool _emailCorrecte(String email) {
    // Expresión regular para validar el formato del email
    String pattern = r'^[^@]+@[^@]+\.[^@]+$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }

  bool _telefonCorrecte() {
    if (tlfLabel.toString().length == 9 || (tlfLabel.toString().length == 1 && tlfLabel == 0)) {
      return true;
    }
    return false;
  }

  Future<String> _existeixUsuariEmailTelefon() async {
    String ageLabelDef = "", tlfLabelDef = "";
    if (ageLabel > 0) {
      ageLabelDef = ageLabel.toString();
    }
    if (tlfLabel > 0) {
      tlfLabelDef = tlfLabel.toString();
    }
    profileImageUrl ??= 'assets/default.png';
    String existeix = "";
    var requestBody = jsonEncode({
      'username': usernameLabel,
      'email': emailLabel,
      'password': passwordHashed,
      'telefon': tlfLabelDef,
      'age': ageLabelDef,
      'language': selectedLanguage,
      'name': "$nameLabel $surnamesLabel",
      'profileImageUrl': profileImageUrl 
    });

    ld.usernameLabel = usernameLabel;
    ld.edat = ageLabelDef;
    ld.tlf = tlfLabelDef;
    ld.email = emailLabel;
    ld.nomUser = '$nameLabel $surnamesLabel';
    ld.urlPerfil = profileImageUrl!;

    await http.post(Uri.parse('$ip/usuaris/signup'), headers: {'Content-Type': 'application/json'}, body: requestBody).then((respuesta) {
      existeix = respuesta.body;
      return existeix;
    }).catchError((error) {
      if (kDebugMode) {
        print('Error: $error');
      }
      return "error";
    });

    return existeix;
  }

  Future<String> errorMssgController(BuildContext innerContext) async {
    if (usernameLabel == "") {
      return TranslationService().translate('enterUsername'); // "Has d'introduïr un nom d'usuari."
    } else if (nameLabel == "" || surnamesLabel == "") {
      return TranslationService().translate('enterYourName'); // "Has d'introduïr el teu nom."
    } else if (emailLabel == "") {
      return TranslationService().translate('enterEmail'); // "Has d'introduïr un email."
    } else if (passwordLabel == "") {
      return TranslationService().translate('enterPassword'); // "Has d'introduïr una contrasenya."
    } else if (confirmPasswordLabel == "") {
      return TranslationService().translate('confirmPassword'); // "Has de confirmar la contrasenya."
    } else if (passwordLabel != confirmPasswordLabel) {
      return TranslationService().translate('passwordsDoNotMatch'); // "Les contrasenyes no coincideixen."
    } else if (!_telefonCorrecte()) {
      return TranslationService().translate('enterValidPhone'); // "Has d'introduïr un telèfon correcte."
    } else if (!_emailCorrecte(emailLabel)) {
      return "Format d'email incorrecte";
    } else if (ageLabel == 0) {
      return "Has de seleccionar el teu any de naixament";
    }

    return await _existeixUsuariEmailTelefon().then((resultado) {
      if (resultado == "username") {
        return TranslationService().translate('usernameExists'); // "L'usuari introduït ja existeix."
      } else if (resultado == "email") {
        return TranslationService().translate('emailExists'); // "Hi ha un compte registrat amb el mateix email."
      } else if (resultado == "telefono") {
        return TranslationService().translate('phoneExists'); // "Hi ha un compte registrat amb el mateix telèfon."
      } else if (resultado == "error") {
        return TranslationService().translate('error'); // "Error"
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
            style: const TextStyle(fontSize: 15, color: Colors.red),
          ),
        ],
      );
    }
  }

  Widget _buildSignupContainer(BuildContext context, double screenHeight, double screenWidth) {
    Color iconCol;
    if (obscurePassword) {
      iconCol = Colors.black87;
    } else {
      iconCol = Colors.black54;
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 250, 255),
      body: Builder(builder: (BuildContext innerContext) {
        String ageText = "Selecciona *";
        if (ageLabel == 0) {
          ageText = '${TranslationService().translate('yearBorn')} *';
        } else {
          ageText = ageLabel.toString();
        }

        return SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 40, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
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
                    children: [
                      ClipRRect(
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.black)),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                usernameLabel = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: TranslationService().translate('usernameHint'),
                              labelText: TranslationService().translate('usernameLabel'),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              child: Container(
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.black)),
                                ),
                                child: TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      nameLabel = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: TranslationService().translate('firstNameHint'),
                                    labelText: TranslationService().translate('firstNameLabel'),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 4,
                            child: ClipRRect(
                              child: Container(
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.black)),
                                ),
                                child: TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      surnamesLabel = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: TranslationService().translate('lastNameHint'),
                                    labelText: TranslationService().translate('lastNameLabel'),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      ClipRRect(
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.black)),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                emailLabel = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: TranslationService().translate('emailHint'),
                              labelText: TranslationService().translate('emailLabel'),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
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
                              });
                            },
                            decoration: InputDecoration(
                              hintText: TranslationService().translate('passwordHint'),
                              labelText: TranslationService().translate('passwordLabel'),
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.visibility, size: 25, color: iconCol),
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
                      const SizedBox(height: 25),
                      ClipRRect(
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.black)),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                confirmPasswordLabel = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: TranslationService().translate('confirmPasswordHint'),
                              labelText: TranslationService().translate('confirmPasswordLabel'),
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.visibility, size: 25, color: iconCol),
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
                      const SizedBox(height: 25),
                      ClipRRect(
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.black)),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                if (value.isNotEmpty) {
                                  tlfLabel = int.parse(value);
                                } else {
                                  tlfLabel = 0;
                                }
                              });
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: TranslationService().translate('tlfHint'),
                              labelText: TranslationService().translate('tlfLabel'),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      // Botón para subir la foto de perfil
                      ElevatedButton(
                        onPressed: () async {
                          final imageUrl = await s3ImageUploader.uploadProfileImage(usernameLabel);
                          if (imageUrl != null) {
                            setState(() {
                              profileImageUrl = imageUrl;
                            });
                          }
                        },
                        child: Text(TranslationService().translate('fotoPerfil')),
                      ),
                      // Mostrar la imagen de perfil si existe
                      if (profileImageUrl != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: S3ImageLoader.loadImage(profileImageUrl!, width: 100, height: 100),
                        ),
                    
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButton<int>(
                            onChanged: (value) {
                              setState(() {
                                if (value == null) {
                                  ageLabel = 0;
                                } else {
                                  ageLabel = value;
                                }
                              });
                            },
                            items: [
                              DropdownMenuItem<int>(
                                value: null,
                                child: Text(
                                  ageText,
                                  style: const TextStyle(
                                      color: Color.fromARGB(180, 0, 0, 0),
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              ...List.generate(125, (int index) => 2024 - index)
                                  .map<DropdownMenuItem<int>>((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(value.toString()),
                                );
                              }),
                            ],
                            underline: Container(
                              height: 1,
                              color: Colors.black,
                            ),
                          ),
                          DropdownButton<String>(
                            value: selectedLanguage,
                            onChanged: (String? newLanguage) {
                              if (newLanguage != null) {
                                setState(() {
                                  TranslationService().loadTranslations(newLanguage);
                                  selectedLanguage = newLanguage;
                                });
                                saveLanguage(newLanguage); // Guardar el idioma seleccionado en SharedPreferences
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
                            style: const TextStyle(
                              color: Color.fromARGB(180, 0, 0, 0),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            underline: Container(
                              height: 1,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      buildErrorMssg(),
                      const SizedBox(height: 35),
                      ElevatedButton(
                        onPressed: () {
                          errorMssgController(innerContext).then((resultado) {
                            setState(() {
                              errorMssg = resultado;
                              if (errorMssg == "") {
                                ld.usernameLabel = usernameLabel;
                                signup = true;
                              }
                            });
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                        ),
                        child: Text(
                          TranslationService().translate('createAcc'),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.black,
                              thickness: 1.0,
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.black, // Color de la línea
                              thickness: 1.0, // Grosor de la línea
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            TranslationService().translate('haveAcc?'),
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
                                    login = true;
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.zero,
                                  child: Text(
                                    " ${TranslationService().translate('loginButton')}",
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> saveLanguage(String languageCode) async {
    ld.saveLanguage(languageCode);
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

    if (!signup & !login) {
      content = _buildSignupContainer(context, screenHeight, screenWidth);
    } else if (login) {
      content = LoginScreen(ip: ip);
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
