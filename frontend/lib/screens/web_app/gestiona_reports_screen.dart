import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/forum/forum.dart';
import 'package:frontend/utils/load_data.dart';
import 'package:frontend/utils/s3_image_loader.dart';
import 'package:http/http.dart' as http;

class LlistaReportsScreen extends StatefulWidget {

  final LoadData ld;

  const LlistaReportsScreen({super.key, required this.ld});

  @override
  State<LlistaReportsScreen> createState() => _LlistaReportsScreenState();
}

class _LlistaReportsScreenState extends State<LlistaReportsScreen> {

  String ip = "";
  String token = "";
  List<dynamic> reports = [];
  LoadData ld = LoadData();
  bool isLoading = true;
  bool publicacioLoading = true;

  Message pb = Message(userName: '', urlAvatar: '', messageText: '', idPublicacio: '', idAnswered: '', fecha: '', hora: '', image: '');
  
  @override
  void initState() {
    super.initState();
    ld = widget.ld;
    ip = ld.ip;
    token = ld.token;
    loadReports();
  }

  Future<void> loadReports() async {
    setState(() {
      isLoading = true; // Comienza la carga
    });

    try {
      await ld.getReports(); // Llama a la función de carga de LoadData
      reports = ld.reports; // Actualiza los reports locales con los cargados

    } catch (e) {
      if (kDebugMode) {
        print('Error loading reports: $e');
      }
    }

    setState(() {
      isLoading = false; // Termina la carga
    });
  }

  Future<void> loadPublicacio(String postId) async {
    publicacioLoading = true; // Comienza la carga

    try {
      await ld.getPostById(postId); // Llama a la función de carga de LoadData
      pb = ld.publicacio; // Actualiza los reports locales con los cargados
    } catch (e) {
      if (kDebugMode) {
        print('Error loading reports: $e');
      }
    }

    setState(() {
      publicacioLoading = false; // Termina la carga
    });
  }

  Future<void> deleteReport(String reportId) async
  {
    String uri = '$ip/reports/deletereport';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    Map<String, String> body = {
      'id': reportId.toString(),
    };


    try {
      final response = await http.post(
        Uri.parse(uri),
        headers: headers,
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Codi: ${response.body}');
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
    loadReports();
  }

  Future<void> deleteUser(String reportId, String reason, String username, String msg) async
  {
    String uri = '$ip/reports/deleteuser';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    Map<String, String> body = {
      'text': reason,
      'username': username,
    };

    try {
      final response = await http.post(
        Uri.parse(uri),
        headers: headers,
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        if (response.body == 'ok') {
          deleteReport(reportId);
        } else {
          if (kDebugMode) {
            print('${response.body}: Parametres mal passats');
          }
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

  Future<void> deletePost(String idpublicacio, String reason, String usernameReportat, String reportId) async
  {
    String uri = '$ip/reports/deletepublicacio';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    Map<String, String> body = {
      'text': reason,
      'username': usernameReportat,
      'idpublicacio': idpublicacio
    };

    try {
      final response = await http.post(
        Uri.parse(uri),
        headers: headers,
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        
        if (response.body == 'ok') {
          if (kDebugMode) {
            print('Acces correcte: ${response.statusCode}');
          }
          deleteReport(reportId);
        } else {
          if (kDebugMode) {
            print('${response.body}: Parametres mal passats');
          }
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

  Widget _showConfirmationDialogDeleteReport(BuildContext context, String reportId) {
    return AlertDialog(
      title: const Text('Confirmació'),
      content: const Text('Estàs segur que vols esborrar el report?'),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel·lar'),
          onPressed: () {
            Navigator.of(context).pop(); // Dismiss the dialog
          },
        ),
        ElevatedButton(
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Color.fromARGB(255, 216, 129, 129))
          ),
          onPressed: () async{
            await deleteReport(reportId);
            await loadReports();
            Navigator.of(context).pop();
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }

  Widget _showConfirmationDialogDeleteUser(BuildContext context, String usuariReportat, String reportId) {
    String reason = '';
    return AlertDialog(
      title: const Text('Confirmació'),
      content: SingleChildScrollView( // Usamos SingleChildScrollView para evitar overflow si el contenido es muy grande
        child: ListBody(
          children: <Widget>[
            const Text('Estàs segur que vols esborrar l\'usuari?'), // Texto de confirmación
            const SizedBox(height: 20), // Espacio opcional entre el mensaje y el texto adicional
            const Text('Aquesta acció no es pot desfer', style: TextStyle(fontWeight: FontWeight.bold)), // Texto adicional
            TextField(
              decoration: const InputDecoration(
                hintText: 'Escriu el motiu de l\'esborrament', // Texto de ayuda en el campo
                border: OutlineInputBorder(), // Borde del TextField
              ),
              onChanged: (value) {
                // Actualiza el estado con el motivo ingresado por el usuario
                setState(() {
                  reason = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel·lar'),
          onPressed: () {
            Navigator.of(context).pop(); // Dismiss the dialog
          },
        ),
        ElevatedButton(
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Color.fromARGB(255, 216, 129, 129))
          ),
          onPressed: () async {
            await deleteUser(reportId, reason, usuariReportat, reason);
            await loadReports();
            Navigator.of(context).pop();
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }

  Widget _showConfirmationDialogDeletePost(BuildContext context, String reportId, String postId, String usuariReportat, String usuariReportador) {
    String reason = '';
    return AlertDialog(
      title: const Text('Confirmació'),
      content: SingleChildScrollView( // Usamos SingleChildScrollView para evitar overflow si el contenido es muy grande
        child: ListBody(
          children: <Widget>[
            const Text('Estàs segur que vols esborrar la publicació?'), // Texto de confirmación
            const SizedBox(height: 20), // Espacio opcional entre el mensaje y el texto adicional
            const Text('Aquesta acció no es pot desfer', style: TextStyle(fontWeight: FontWeight.bold)), // Texto adicional
            TextField(
              decoration: const InputDecoration(
                hintText: 'Escriu el motiu de l\'esborrament', // Texto de ayuda en el campo
                border: OutlineInputBorder(), // Borde del TextField
              ),
              onChanged: (value) {
                // Actualiza el estado con el motivo ingresado por el usuario
                setState(() {
                  reason = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel·lar'),
          onPressed: () {
            Navigator.of(context).pop(); // Dismiss the dialog
          },
        ),
        ElevatedButton(
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Color.fromARGB(255, 216, 129, 129))
          ),
          onPressed: () async {
            await deletePost (postId, reason, usuariReportat, reportId);
            await loadReports();
            Navigator.of(context).pop();
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }

   Widget _showConfirmationDialogToggleBlock(BuildContext context, String usuariReportat) {
    return FutureBuilder<void>(
      future: ld.getUser(usuariReportat),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('No es pot carregar l\'estat de bloqueig del usuari.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel·lar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        } else {
          bool isBlocked = ld.isBlocked;
          return AlertDialog(
            title: const Text('Confirmació'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Estàs segur que vols alternar el bloqueig del usuari $usuariReportat? Ara es troba ${isBlocked ? "bloquejat" : "desbloquejat"}.'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel·lar'),
                onPressed: () {
                  publicacioLoading = true;
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Color.fromARGB(255, 216, 129, 129)),
                ),
                onPressed: () async {
                  await ld.toggleUserBlock(usuariReportat, !isBlocked);
                  loadReports(); // Actualiza la lista de informes después de la acción
                  publicacioLoading = true;
                  Navigator.of(context).pop(); // Cierra el diálogo
                },
                child: const Text('Alternar Bloqueig'),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _showPostDialog(BuildContext context, String idPost) {
    return FutureBuilder<void>(
      future: loadPublicacio(idPost),
      builder: (context, snapshot) {
        if (publicacioLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(pb.idPublicacio),
            content: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.black),
              ),
              // Agrega padding en todos los lados del Container
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Puedes ajustar el valor del padding aquí
                child: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Row(
                        children: [
                          ClipOval(
                            child: SizedBox(
                              width: 40, // Ajustar tamaño del avatar según sea necesario
                              height: 40,
                              child: S3ImageLoader.loadImage(
                                pb.urlAvatar,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10), // Espacio horizontal entre el avatar y el texto
                          Text(pb.userName),
                        ],
                      ),
                      if (pb.image != "") SizedBox(
                        height: 100, // Alto de la imagen
                        child: S3ImageLoader.loadImage(pb.image, height: 200),
                      ),
                      Text(pb.messageText), // Texto del mensaje
                    ],
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Enrere'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Reports'),
      ),
      body: !isLoading ? ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          String data = report['fechaReport'];
          String hora = report['horaReport'];

          String fechaCompleta = "$data a les $hora";

          return Container(
            margin: const EdgeInsets.all(10.0),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10.0),
                Row(
                  children: [
                    Text(
                      'ID: ${report['idReport']}',
                      style: const TextStyle(
                        fontSize: 22,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => _showPostDialog(context, report['idpublicacio'].toString()),
                          );
                      },
                      icon: const Icon(Icons.visibility_outlined),
                    )
                  ],
                ),
                const SizedBox(height: 10.0),
                Text(
                  report['missatge'],
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5.0),
                Text('Reportador: ${report['usuariReportador']}'),
                const SizedBox(height: 10.0),
                Text('Reportat: ${report['usuariReportat']}'),
                const SizedBox(height: 10.0),
                Text('Data report: $fechaCompleta'),
                const SizedBox(height: 5.0),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => _showConfirmationDialogDeletePost(context, report['idReport'].toString(), report['idpublicacio'].toString(), report['usuariReportat'], ld.usernameLabel),
                          );
                        },
                        child: const Text(
                          'Esborra Post',
                          style: TextStyle(fontSize: 12.0), // Tamaño de fuente más pequeño
                        ),
                      ),
                    ),
                    const SizedBox(width: 10), // Espacio entre botones
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => _showConfirmationDialogDeleteUser(context, report['usuariReportat'], report['idReport'].toString()),
                          );
                        },
                        child: const Text(
                          'Esborra Usuari',
                          style: TextStyle(fontSize: 12.0), // Tamaño de fuente más pequeño
                        ),
                      ),
                    ),
                    const SizedBox(width: 10), // Espacio entre botones
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => _showConfirmationDialogToggleBlock(context, report['usuariReportat']),
                          );
                        },
                        child: const Text(
                          'Alternar Bloqueig',
                          style: TextStyle(fontSize: 12.0), // Tamaño de fuente más pequeño
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => _showConfirmationDialogDeleteReport(context, report['idReport'].toString()),
                      );
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ),
              ],
            ),
          );
        },
      ) : const Center(child: CircularProgressIndicator()),
    );
  }



}
