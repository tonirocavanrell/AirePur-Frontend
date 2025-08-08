import 'package:flutter/material.dart';
import 'package:frontend/providers/locale_translationProvider.dart';
import 'package:frontend/utils/load_data.dart'; // Importar la clase LoadData
import 'package:timeago/timeago.dart' as timeago; // Importar la biblioteca timeago

class NotificationsScreen extends StatefulWidget {
  final double ica; // Parámetro para recibir el valor de ICA
  final LoadData ld;

  const NotificationsScreen({super.key, required this.ica, required this.ld});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<Map<String, dynamic>> notifications;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      notifications = [
        {
          'title': getTitleBasedOnICA(widget.ica),
          'detail': getDetailBasedOnICA(widget.ica),
          'time': widget.ld.notificationTime, // Usa la hora de creación de la notificación
          'read': widget.ld.hasReadNotification, // Inicializa el estado de lectura de la notificación
        },
        {
          'title': getTitleBasedOnAdvice(widget.ica),
          'detail': getDetailBasedOnAdvice(widget.ica),
          'time': widget.ld.notificationTime, // Usa la hora de creación de la notificación
          'read': widget.ld.hasReadNotification, // Inicializa el estado de lectura de la notificación
        }
      ];
    });
  }

  String getTitleBasedOnICA(double ica) {
    if (ica < 50) {
      return TranslationService().translate('notiBuenaTitle');
    } else if (ica < 100) {
      return TranslationService().translate('notiModeradaTitle');
    } else {
      return TranslationService().translate('notiMalaTitle');
    }
  }

  String getTitleBasedOnAdvice(double ica) {
    if (ica < 50) {
      return TranslationService().translate('notiAdviceBueno');
    } else if (ica < 100) {
      return TranslationService().translate('notiAdviceModerado');
    } else {
      return TranslationService().translate('notiAdviceMalo');
    }
  }

  String getDetailBasedOnICA(double ica) {
    if (ica < 50) {
      return TranslationService().translate('notiBuenaDetail');
    } else if (ica < 100) {
      return TranslationService().translate('notiModeradaDetail');
    } else {
      return TranslationService().translate('notiMalaDetail');
    }
  }

  String getDetailBasedOnAdvice(double ica) {
    if (ica < 50) {
      return TranslationService().translate('notiAdviceBuenoDetail');
    } else if (ica < 100) {
      return TranslationService().translate('notiAdviceModeradoDetail');
    } else {
      return TranslationService().translate('notiAdviceMaloDetail');
    }
  }

  Icon getIconForICA(double ica, int icaAdvice) {
    if (icaAdvice == 0) {
      if (ica < 50) {
        return const Icon(Icons.sentiment_very_satisfied, color: Colors.green); // Icono verde para buena calidad
      } else if (ica < 100) {
        return const Icon(Icons.sentiment_satisfied, color: Colors.amber); // Icono ámbar para calidad moderada
      } else {
        return const Icon(Icons.sentiment_very_dissatisfied, color: Colors.red); // Icono rojo para mala calidad
      }
    } else {
      if (ica < 50) {
        return const Icon(Icons.warning_amber_rounded, color: Colors.green);
      } else if (ica < 100) {
        return const Icon(Icons.warning_amber_rounded, color: Colors.amber); 
      } else {
        return const Icon(Icons.warning_amber_rounded, color: Colors.red);
      }
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TranslationService().translate('notifications')),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          var notification = notifications[index];
          String timeAgo = timeago.format(notification['time']);
          return ListTile(
            leading: getIconForICA(widget.ica, index),
            title: Text(notification['title']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ICA: ${widget.ica}'),
              ],
            ),
            trailing: Text(
              timeAgo,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            tileColor: notification['read'] ? Colors.white : Colors.lightBlue[50], // Cambia el color de fondo si está leída
            onTap: () async {
              if (!notification['read']) {
                setState(() {
                  notifications[index]['read'] = true;
                });
                await widget.ld.saveNotificationReadStatus(true);
              }
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(notification['title']),
                    content: Text(notification['detail']),
                    actions: <Widget>[
                      TextButton(
                        child: Text(TranslationService().translate('close')),
                        onPressed: () {
                          Navigator.of(context).pop(); // Cierra el diálogo
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
