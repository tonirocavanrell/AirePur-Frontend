import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:frontend/providers/locale_translationProvider.dart';
import 'package:frontend/utils/Config.dart';
import 'package:frontend/utils/load_data.dart';
import 'package:frontend/widgets/navigation_bar.dart';
import 'package:http/http.dart' as http;

class AssignarComunitatDialog extends StatefulWidget {
  const AssignarComunitatDialog({super.key, required this.ld});

  final LoadData ld;

  @override
  State<AssignarComunitatDialog> createState() => _AssignarComunitatDialogState();
}

class _AssignarComunitatDialogState extends State<AssignarComunitatDialog> {

  List<dynamic> _municipis = [];
  dynamic selected;
  bool carregat = false;
  Map<String, String> _municipisAmbCodi = {};
  String ip = Config.ip;

  late LoadData ld;

  Future<List<dynamic>> fetchMunicipis() async {
    final response = await http.get(Uri.parse('$ip/localitzacionsestacio/municipis'));

    if (response.statusCode == 200) {
      var decodedJson = jsonDecode(utf8.decode(response.bodyBytes));
      if (decodedJson is Map<String, dynamic>) {
        _municipisAmbCodi = Map<String, String>.fromIterables(
          decodedJson.keys,
          decodedJson.values.map((value) => value.toString()).toList()
        );
        carregat = true;
      } else {
        if (kDebugMode) {
          print('El JSON decodificado no es un mapa.');
        }
      }
      return json.decode(utf8.decode(response.bodyBytes)).keys.toList();
    } else {
      throw Exception('Failed to load municipios from server');
    }
  }

  void handleChange(dynamic newValue) {
    if (newValue != null) {
      setState(() {
        selected = newValue;
      });
    }
  }

  Future<void> _putMunicipi (selected) async {

    var requestBody = jsonEncode({
      'username': widget.ld.usernameLabel,
      'codi': _municipisAmbCodi[selected].toString(),
    });

    if (selected != null) {
      await http.post(Uri.parse('$ip/usuaris/updateCS'), headers: {'Content-Type': 'application/json'}, body: requestBody).then((respuesta) {
        ld.userCodi = _municipisAmbCodi[selected].toString();
      }).catchError((error) {
        if (kDebugMode) {
          print('Error: $error');
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMunicipis().then((municipis) {
      setState(() {
        _municipis = municipis;
        if (kDebugMode) {
          print("MUNI: $_municipis");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    ld = widget.ld;

    return Dialog(
      backgroundColor: Colors.white, // Cambia el color de fondo
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Colors.black87, width: 3), // Añade un borde
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              TranslationService().translate('municipioChoice'),
              style: const TextStyle(
                fontSize: 25,
              ),
            ),

            const SizedBox(height: 10),
            Text(
              TranslationService().translate('municipioChoiceDesc'),
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 20),
            !carregat
              ? const CircularProgressIndicator()
              : DropdownSearch<dynamic>(
                  items: _municipis,
                  onChanged: handleChange,
                ),

            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(TranslationService().translate('cancel')),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    if (selected != null) {
                      _putMunicipi(selected!);
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MyNavigationBar(ld: ld, actual: 3),
                        ),
                      );
                    }
                  },
                  child: Text(TranslationService().translate('accept')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}