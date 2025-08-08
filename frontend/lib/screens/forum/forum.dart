import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/load_data.dart';
import 'package:frontend/utils/s3_image_loader.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:frontend/providers/locale_translationProvider.dart';

class ForumPage extends StatelessWidget {
  final LoadData ld;
  const ForumPage({super.key, required this.ld, });
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Message Form',
      home: MessageBoard(ld: ld),
    );
  }
}

class Message {
  String userName;
  String messageText;
  String fecha;
  String hora;
  String urlAvatar;
  String idPublicacio;
  String idAnswered; // Indica si es un comentario hijo
  String image;
  Message({required this.userName, required this.urlAvatar, required this.messageText, required this.idPublicacio, required this.idAnswered, required this.fecha, required this.hora, required this.image});
}

class MessageBoard extends StatefulWidget {
  final LoadData ld;
  const MessageBoard({super.key, required this.ld});
  _MessageBoardState createState() => _MessageBoardState();
}

class _MessageBoardState extends State<MessageBoard> {
  final TextEditingController _messageController = TextEditingController();
  List<Message> messages = [];
  bool _isMessageEmpty = true;
  String ip = "";
  late LoadData ld;

  String parentId = "";
  String usernameParent = ""; 
  String usuariReportador = "";
  String usuariReportat = "";

  String imageForum = "";
  bool isLoaded = false;

  S3ImageUploader s3ImageUploader = S3ImageUploader();

  @override
  void initState() {
    super.initState();
    ld = widget.ld;
    ip = ld.ip;
    if (ld.isLoadedForum) {
      isLoaded = true;
      messages = ld.messages;
    } else {
      ld.addListener(() {
        if (ld.isLoadedForum) {
          setState(() {
            isLoaded = true;
            messages = ld.messages;
          });
        }
      });
    }
    _messageController.addListener(_onMessageChanged);
  }

  void _onMessageChanged() {
    setState(() {
      _isMessageEmpty = _messageController.text.trim().isEmpty;
    });
  }

  Future<void> _sendMessageToBackend(Message message) async {
    // Endpoint de tu backend
    String endpoint = '$ip/publicacions/postpublicacio';
    String requestBody;
    
    if (parentId == "") {
        requestBody = jsonEncode({
        'username': message.userName,
        'contingut': message.messageText,
        'fecha': message.fecha,
        'hora': message.hora,
        'idPublicacio': message.idPublicacio,
        'idanswered': null,
        'urlAvatar': message.urlAvatar,
        'imatge': message.image
        });
    } else {
        requestBody = jsonEncode({
        'username': message.userName,
        'contingut': message.messageText,
        'fecha': message.fecha,
        'hora': message.hora,
        'idPublicacio': message.idPublicacio,
        'idanswered': message.idAnswered,
        'urlAvatar': message.urlAvatar,
        'imatge': message.image
        });
    }
    // Realizar la solicitud HTTP POST al backend
    await http.post(Uri.parse(endpoint), headers: {'Content-Type': 'application/json'}, body: requestBody).then((respuesta) {

    }).catchError((error) {
      if (kDebugMode) {
        print('Error: $error');
      }
    });

    imageForum = "";
  }

  Future<void> _sendReportToBackend(String reportReason, String reportedUserName, String postId) async {
    // Asignar los valores de usuariReportador y usuariReportat
    usuariReportador = ld.usernameLabel;
    usuariReportat = reportedUserName;

    // Endpoint de tu backend
    String endpoint = '$ip/reports/postreport';

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    String fecha = DateFormat('yyyy-MM-dd').format(today);
    String hora = DateFormat('HH:mm:ss').format(now);

    var requestBody = jsonEncode({
      'missatge': reportReason,
      'imatge': '',
      'fecha': fecha,
      'hora': hora,
      'usernameReportador': usuariReportador,
      'usernameReportat': usuariReportat,
      'idpublicacio': postId
    });
    // Realizar la solicitud HTTP POST al backend
    await http.post(Uri.parse(endpoint), headers: {'Content-Type': 'application/json'}, body: requestBody).then((respuesta) {
    }).catchError((error) {

      print('Error: $error');
    });
  }

  Future<void> eliminarPublicacio(String id) async {
    try {
      final response = await http.delete(Uri.parse('$ip/publicacions/delete/$id'));
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(TranslationService().translate('deletedPubli'));
        }
      } else {
        if (kDebugMode) {
          print('${TranslationService().translate('deletePubliError')}${response.statusCode}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error: $error');
      }
    }
  }
  
  Future<void> _sendMessage(String usernamePare, String image) async {
    String messageText = _messageController.text.trim();
    _messageController.clear();
    if (messageText.isNotEmpty) {
      String userName = ld.usernameLabel; // Nombre de usuario 
      //String avatarUrl = ''; // URL del avatar del usuario
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      String fecha = DateFormat('yyyy-MM-dd').format(today);
      String hora = DateFormat('HH:mm:ss').format(now);
      Message newMessage;
      if(usernamePare != "") {
        newMessage = Message(userName: userName, messageText: '@$usernamePare $messageText', idPublicacio: fecha+hora+userName, idAnswered: parentId, fecha: fecha, hora: hora, urlAvatar: ld.urlPerfil, image: image);
      } else {
        newMessage = Message(userName: userName, messageText: messageText, idPublicacio: fecha+hora+userName, idAnswered: parentId, fecha: fecha, hora: hora, urlAvatar: ld.urlPerfil, image: image);
      }
      await _sendMessageToBackend(newMessage);

      if (kDebugMode) {
        print('ParentId: $parentId');
        print('idanswered: ${newMessage.idAnswered}');
      }

      setState(() {
        messages.insert(0, newMessage); // Inserta el nuevo mensaje en la parte superior de la lista
        _messageController.clear(); // Limpia el campo de texto después de enviar el mensaje
        _isMessageEmpty = true; // Restablece el estado del botón "Enviar" a vacío
      });
    }
  }

  Future<void> _refreshMessages() async {
    // Limpia la lista actual de mensajes antes de cargar los nuevos
    messages.clear();

    // Llama a la función para obtener los mensajes desde el backend
    await ld.getMessages();
    messages = ld.messages;

    // Actualiza el estado para reconstruir la interfaz con los nuevos mensajes
    setState(() {});
  }

  String formatDate(String date) {
  DateTime parsedDate = DateTime.parse(date);
  return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    
    List<Message> topLevelMessages = messages.where((message) => message.idAnswered.isEmpty).toList();
    topLevelMessages.sort((a, b) {
      int dateComparison = a.fecha.compareTo(b.fecha);
      if (dateComparison != 0) {
        return dateComparison;
      } else {
        return a.hora.compareTo(b.hora);
      }
    });

    Padding fotoMssg;
    double hMssg = 100;
    if (imageForum != "") {
      fotoMssg = Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: IntrinsicWidth(
          child: SizedBox(
            height: 200, // Alto de la imagen
            child: S3ImageLoader.loadImage(imageForum, height: 100),
          ),
        ),
      );
      hMssg = 350;
    } else {
      fotoMssg = const Padding(padding: EdgeInsets.all(0));
      hMssg = 100;
    }

    return Scaffold(
      body: isLoaded
          ? RefreshIndicator(
              onRefresh: _refreshMessages,
              child: Stack(
                children: [
                  // Fondo de la imagen desde Amazon S3
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: S3ImageLoader.loadImageAsImageProvider('assets/background_image.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 95,),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(8.0),
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              height: hMssg, // Ajustar la altura del contenedor según sea necesario
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(color: Colors.black, width: 2.0),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _messageController,
                                      maxLines: null, // Permite que el TextField se expanda según sea necesario
                                      keyboardType: TextInputType.multiline,
                                      decoration: InputDecoration(
                                        hintText: parentId.isNotEmpty
                                            ? '${TranslationService().translate('replyingTo')} $usernameParent...'
                                            : TranslationService().translate('whatRUthinking'),
                                        border: InputBorder.none, // Eliminar el borde del TextField
                                      ),
                                    ),
                                  ),
                                  fotoMssg,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end, // Alinear los botones a la derecha
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_outlined),
                                        onPressed: () {
                                          setState(() {
                                            imageForum = "";
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 5),
                                      IconButton(
                                        icon: const Icon(Icons.photo),
                                        onPressed: () async {
                                          final image = await s3ImageUploader.uploadForumImage();
                                          if (image != null) {
                                            setState(() {
                                              imageForum = image;
                                            });
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 10),
                                      if (parentId.isNotEmpty)
                                        Container(
                                          margin: const EdgeInsets.only(right: 8.0), // Espaciado entre los botones
                                          child: TextButton(
                                            onPressed: parentId.isNotEmpty
                                                ? () {
                                                    setState(() {
                                                      parentId = '';
                                                      usernameParent = '';
                                                    });
                                                  }
                                                : null,
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20.0), // Bordes redondos
                                                  side: const BorderSide(color: Colors.black), // Borde negro
                                                ),
                                              ),
                                            ),
                                            child: Text(TranslationService().translate('cancel')),
                                          ),
                                        ),
                                      TextButton(
                                        onPressed: _isMessageEmpty ? null : () => _sendMessage(usernameParent, imageForum),
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20.0), // Bordes redondos
                                              side: const BorderSide(color: Colors.black), // Borde negro
                                            ),
                                          ),
                                        ),
                                        child: Text(TranslationService().translate('send')),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          reverse: true,
                          itemCount: topLevelMessages.length,
                          itemBuilder: (context, topLevelIndex) {
                            Message topLevelMessage = topLevelMessages[topLevelIndex];
                            List<Message> childMessages = messages.where((message) => message.idAnswered == topLevelMessage.idPublicacio).toList();
                            // Ordenar los mensajes hijos cronológicamente de forma ascendente
                            childMessages.sort((a, b) {
                              // Primero, compara las fechas
                              int dateComparison = a.fecha.compareTo(b.fecha);
                              if (dateComparison != 0) {
                                // Si las fechas son diferentes, devuelve el resultado de la comparación de fechas
                                return dateComparison;
                              } else {
                                // Si las fechas son iguales, compara las horas
                                return a.hora.compareTo(b.hora);
                              }
                            });
                            Padding imatgeMssg;
                            if (topLevelMessage.image != "") {
                              imatgeMssg = Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0),
                                child: IntrinsicWidth(
                                  child: SizedBox(
                                    height: 100, // Alto de la imagen
                                    child: S3ImageLoader.loadImage(topLevelMessage.image, height: 100),
                                  ),
                                ),
                              );
                            } else {
                              imatgeMssg = const Padding(padding: EdgeInsets.all(0));
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(color: Colors.black),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipOval(
                                            child: SizedBox(
                                              width: 40, // Ajustar tamaño del avatar según sea necesario
                                              height: 40,
                                              child: S3ImageLoader.loadImage(
                                                topLevelMessage.urlAvatar,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      topLevelMessage.userName.length > 8
                                                        ? '${topLevelMessage.userName.substring(0, 15)}...'
                                                        : topLevelMessage.userName,
                                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                    // IconButton y PopupMenuButton movidos fuera de Row
                                                  ],
                                                ),
                                                const SizedBox(height: 4.0),
                                                Text(
                                                  topLevelMessage.messageText,
                                                  style: const TextStyle(fontSize: 16.0),
                                                ),
                                                const SizedBox(height: 4.0),
                                                imatgeMssg,
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.mode_comment_outlined),
                                            onPressed: () {
                                              parentId = topLevelMessage.idPublicacio;
                                              usernameParent = topLevelMessage.userName;
                                              if (kDebugMode) {
                                                print('ParentId_2: $parentId');
                                                print('idanswered_2: $usernameParent');                                                
                                              }
                                              setState(() {});
                                              if (kDebugMode) {
                                                print('${TranslationService().translate('replyTo')} ${topLevelMessage.messageText}');
                                              }
                                            },
                                          ),
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert),
                                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                              PopupMenuItem<String>(
                                                value: 'reportar',
                                                child: Text(TranslationService().translate('report')),
                                              ),
                                              if (topLevelMessage.userName == ld.usernameLabel)
                                                PopupMenuItem<String>(
                                                  value: 'borrar',
                                                  child: Text(TranslationService().translate('delete')),
                                                ),
                                            ],
                                            onSelected: (String value) {
                                              if (value == 'reportar') {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    String reportReasonP = "";
                                                    return AlertDialog(
                                                      title: Text(TranslationService().translate('reportTo') + topLevelMessage.userName),
                                                      content: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          TextField(
                                                            onChanged: (value) {
                                                              reportReasonP = value; // Actualizar el motivo del reporte cuando cambia el texto en el campo de texto
                                                            },
                                                            decoration: InputDecoration(hintText: TranslationService().translate('reportReason')),
                                                          ),
                                                        ],
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(context).pop(); // Cierra el cuadro de diálogo
                                                          },
                                                          child: Text(TranslationService().translate('cancel')),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            _sendReportToBackend(reportReasonP, topLevelMessage.userName, topLevelMessage.idPublicacio);
                                                            Navigator.of(context).pop(); // Cierra el cuadro de diálogo
                                                          },
                                                          child: Text(TranslationService().translate('send')),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              } else if (value == 'borrar') {
                                                // Lógica para borrar el mensaje
                                                eliminarPublicacio(topLevelMessage.idPublicacio);
                                                setState(() {
                                                  messages.remove(topLevelMessage);
                                                });
                                                if (kDebugMode) {
                                                  print('${TranslationService().translate('deletedMessage')} ${topLevelMessage.idPublicacio}');
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5.0), // Espacio entre el contenido y la fecha/hora
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Text(
                                          '${formatDate(topLevelMessage.fecha)} ${topLevelMessage.hora}',
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Aquí mostramos los mensajes hijos
                                ...childMessages.map((childMessage) {
                                  Padding childImatgeMssg;
                                  if (childMessage.image != "") {
                                    childImatgeMssg = Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                                      child: IntrinsicWidth(
                                        child: SizedBox(
                                          height: 100, // Alto de la imagen
                                          child: S3ImageLoader.loadImage(childMessage.image, height: 100),
                                        ),
                                      ),
                                    );
                                  } else {
                                    childImatgeMssg = const Padding(padding: EdgeInsets.all(0));
                                  }
                                  return Container(
                                    margin: const EdgeInsets.only(left: 32.0, right: 16.0, top: 8.0, bottom: 8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(color: Colors.black),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              ClipOval(
                                                child: SizedBox(
                                                  width: 30, // Ajustar tamaño del avatar según sea necesario
                                                  height: 30,
                                                  child: S3ImageLoader.loadImage(
                                                    childMessage.urlAvatar,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8.0),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      childMessage.userName.length > 8
                                                        ? '${childMessage.userName.substring(0, 15)}...'
                                                        : childMessage.userName,
                                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                    const SizedBox(height: 4.0),
                                                    Text(
                                                      childMessage.messageText,
                                                      style: const TextStyle(fontSize: 16.0),
                                                    ),
                                                    const SizedBox(height: 4.0),
                                                    childImatgeMssg,
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.mode_comment_outlined),
                                                onPressed: () {
                                                  parentId = topLevelMessage.idPublicacio;
                                                  usernameParent = childMessage.userName;
                                                  setState(() {});
                                                  if (kDebugMode) {
                                                    print('${TranslationService().translate('replyTo')} ${childMessage.messageText}');
                                                  }
                                                },
                                              ),
                                              PopupMenuButton<String>(
                                                icon: const Icon(Icons.more_vert),
                                                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                                  PopupMenuItem<String>(
                                                    value: 'reportar',
                                                    child: Text(TranslationService().translate('report')),
                                                  ),
                                                  if (childMessage.userName == ld.usernameLabel)
                                                    PopupMenuItem<String>(
                                                      value: 'borrar',
                                                      child: Text(TranslationService().translate('delete')),
                                                    ),
                                                ],
                                                onSelected: (String value) {
                                                  if (value == 'reportar') {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        String reportReason = "";
                                                        return AlertDialog(
                                                          title: Text(TranslationService().translate('reportTo') + childMessage.userName),
                                                          content: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              TextField(
                                                                onChanged: (value) {
                                                                  reportReason = value;
                                                                },
                                                                decoration: InputDecoration(hintText: TranslationService().translate('reportReason')),
                                                              ),
                                                            ],
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(context).pop();
                                                              },
                                                              child: Text(TranslationService().translate('cancel')),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                _sendReportToBackend(reportReason, childMessage.userName, childMessage.idPublicacio);
                                                                Navigator.of(context).pop();
                                                              },
                                                              child: Text(TranslationService().translate('send')),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  } else if (value == 'borrar') {
                                                    eliminarPublicacio(childMessage.idPublicacio);
                                                    setState(() {
                                                      messages.remove(childMessage);
                                                    });
                                                    if (kDebugMode) {
                                                      print('${TranslationService().translate('deletedMessage')} ${childMessage.idPublicacio}');
                                                    }
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                                            child: Text(
                                              '${formatDate(childMessage.fecha)} ${childMessage.hora}',
                                              style: const TextStyle(color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }




  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}