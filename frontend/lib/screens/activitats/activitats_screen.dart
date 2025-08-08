import 'package:flutter/material.dart';
import 'package:frontend/providers/locale_translationProvider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/utils/load_data.dart';
import 'package:intl/intl.dart';

class ActivitatsScreen extends StatefulWidget {
  final LoadData ld;
  const ActivitatsScreen({super.key, required this.ld});

  @override
  State<ActivitatsScreen> createState() => _ActivitatsScreenState();
}

class _ActivitatsScreenState extends State<ActivitatsScreen> {
  String ip = "";
  List<dynamic> activitats = [];

  @override
  void initState() {
    super.initState();
    ip = widget.ld.ip;
    activitats = widget.ld.activitats;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green, // Color verde de fondo
        title: Text(
          TranslationService().translate('activitats'),
        ),
      ),
      body: ListView.builder(
              itemCount: activitats.length,
              itemBuilder: (context, index) {
                final activitat = activitats[index];
                String data = activitat['data_inici'];
                DateFormat inputFormatter = DateFormat("yyyy-MM-dd'T'HH:mm-HH:mm");
                DateTime dateTime = inputFormatter.parse(data);
                DateFormat outputFormatter = DateFormat("'De' HH:mm 'a' HH:mm 'el' dd-MM-yyyy");
                String formattedDate = outputFormatter.format(dateTime);

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
                      Image.network(activitat['imatges']),
                      const SizedBox(height: 10.0),
                      Text(
                        activitat['denominaci'],
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      Text(activitat['descripcio']),
                      const SizedBox(height: 10.0),
                      Text('Data d\'inici: $formattedDate'),
                      const SizedBox(height: 5.0),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            final url = Uri.parse(activitat['enlla_os']);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                          child: Text(TranslationService().translate('mesInfo')),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
