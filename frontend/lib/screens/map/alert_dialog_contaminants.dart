import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/providers/locale_translationProvider.dart';
import 'package:frontend/utils/Config.dart';
import 'package:http/http.dart' as http;

class ContaminantsDialog extends StatefulWidget {

  final String codiEstacio;
  final String municipi;
  final String comarca;
  final String valorICA;

  const ContaminantsDialog({super.key, required this.codiEstacio, required this.municipi, required this.comarca, required this.valorICA});

  @override
  State<ContaminantsDialog> createState() => _ContaminantsDialogState();
}

class _ContaminantsDialogState extends State<ContaminantsDialog> {

  bool contsCarregats = false;
  bool isCheckedSO2 = false;
  bool isCheckedNO = false;
  bool isCheckedNO2 = false;
  bool isCheckedO3 = false;
  bool isCheckedNOX = false;
  bool isCheckedPM10 = false;
  bool isCheckedPM25 = false;
  bool isCheckedCO = false;
  bool isCheckedC6H6 = false;

  //Datos para el grafico
  DateTime? selectedDate;
  double? quantity;
  String? selectedPollutant;
  TextEditingController quantityController = TextEditingController();
  List<DateTime> dates = [];
  List<double> quantitiesSO2 = [];
  List<double> quantitiesO3 = [];
  List<double> quantitiesNOX = [];
  List<double> quantitiesNO2 = [];
  List<double> quantitiesNO = [];
  List<double> quantitiesPM10 = [];
  List<double> quantitiesCO = [];
  List<double> quantitiesPM25 = [];
  List<double> quantitiesC6H6 = [];
  
  String ip = Config.ip;

  Future<List<dynamic>> fetchContaminantsData(String codiEstacio) async {

    final String url = '$ip/dadesestacio/$codiEstacio';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      contsCarregats = true;
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception(TranslationService().translate('contaminantsError'));
    }
  }

  Widget selectButtons () {
    return ElevatedButton(
      onPressed: () async {
        // Mostrar un DatePicker para que el usuario seleccione una fecha
        DateTime now = DateTime.now();
        DateTime lastSelectableDate = DateTime(now.year, now.month, now.day);

        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2024),
          lastDate: lastSelectableDate,
        );

        if (pickedDate != null) {
          setState(() {
            quantitiesSO2.clear();
            quantitiesNO.clear();
            quantitiesNO2.clear();
            quantitiesNOX.clear();
            quantitiesO3.clear();
            quantitiesPM10.clear();
            quantitiesPM25.clear();
            quantitiesCO.clear();
            quantitiesC6H6.clear();
            dates.clear();
            isCheckedNO = isCheckedNO2 = isCheckedNOX = isCheckedO3 = isCheckedSO2 = isCheckedPM10 = isCheckedC6H6 = isCheckedCO = isCheckedPM25 = false;
            selectedDate = pickedDate;
            fetchDates();
          });
        }
      },
      child: Text(selectedDate != null ? '${TranslationService().translate('fechaSeleccionada')}: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}' : TranslationService().translate('seleccionarFecha')),
    );
  }

  Future<void> fetchDates() async {
    DateTime currentDate = DateTime.now();

    currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
    selectedDate = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);

    DateTime aux = selectedDate!;

    currentDate = currentDate.subtract(const Duration(days: 1));

    while (aux.isBefore(currentDate) || aux.isAtSameMomentAs(currentDate)) {
      dates.add(aux);
      aux = aux.add(const Duration(days: 1));
    }
  }

  Future<void> fetchDataO3() async {
     final response = await http.get(Uri.parse('$ip/dadesestacio/desde/${widget.codiEstacio}/$selectedDate/O3'));
     if (quantitiesO3.isNotEmpty) quantitiesO3 = [];
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      // Parsear los datos obtenidos y generar las listas de fechas y cantidades
      for (var entry in data) {
        if (entry['quantitat'] != -1 && entry['quantitat'] != 'NaN') {
          quantitiesO3.add(entry['quantitat']);
        } else {
          quantitiesO3.add(0);
        }
      }
      quantitiesO3 = quantitiesO3.reversed.toList();
      // Mostrar el gráfico con los datos obtenidos
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchDataSO2() async {
    final response = await http.get(Uri.parse('$ip/dadesestacio/desde/${widget.codiEstacio}/$selectedDate/SO2'));
    if (quantitiesSO2.isNotEmpty) quantitiesSO2 = [];
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      // Parsear los datos obtenidos y generar las listas de fechas y cantidades
      for (var entry in data) {
        if (entry['quantitat'] != -1 && entry['quantitat'] != 'NaN') {
          quantitiesSO2.add(entry['quantitat']);
        } else {
          quantitiesSO2.add(0);
        }
      }
      // Mostrar el gráfico con los datos obtenidos
    } else {
      throw Exception('Failed to load data');
    }
  }
  
  Future<void> fetchDataNO() async {
     final response = await http.get(Uri.parse('$ip/dadesestacio/desde/${widget.codiEstacio}/$selectedDate/NO'));
    if (quantitiesNO.isNotEmpty) quantitiesNO = [];
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      // Parsear los datos obtenidos y generar las listas de fechas y cantidades
      for (var entry in data) {
        if (entry['quantitat'] != -1 && entry['quantitat'] != 'NaN') {
          quantitiesNO.add(entry['quantitat']);
        }
        else {
          quantitiesNO.add(0);
        } 
      }
      // Mostrar el gráfico con los datos obtenidos
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchDataNO2() async {
     final response = await http.get(Uri.parse('$ip/dadesestacio/desde/${widget.codiEstacio}/$selectedDate/NO2'));
     if (quantitiesNO2.isNotEmpty) quantitiesNO2 = [];
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      // Parsear los datos obtenidos y generar las listas de fechas y cantidades
      for (var entry in data) {
        if (entry['quantitat'] != -1 && entry['quantitat'] != 'NaN') {
          quantitiesNO2.add(entry['quantitat']);
        } else {
          quantitiesNO2.add(0);
        } 
      }
      // Mostrar el gráfico con los datos obtenidos
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchDataPM10() async {
     final response = await http.get(Uri.parse('$ip/dadesestacio/desde/${widget.codiEstacio}/$selectedDate/PM10'));
     if (quantitiesPM10.isNotEmpty) quantitiesPM10 = [];
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      // Parsear los datos obtenidos y generar las listas de fechas y cantidades
      for (var entry in data) {
        if (entry['quantitat'] != -1 && entry['quantitat'] != 'NaN') {
          quantitiesPM10.add(entry['quantitat']);
        } else {
          quantitiesPM10.add(0);
        }
      }
      // Mostrar el gráfico con los datos obtenidos
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchDataNOX() async {
     final response = await http.get(Uri.parse('$ip/dadesestacio/desde/${widget.codiEstacio}/$selectedDate/NOX'));
     if (quantitiesNOX.isNotEmpty) quantitiesNOX = [];
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      // Parsear los datos obtenidos y generar las listas de fechas y cantidades
      for (var entry in data) {
        if (entry['quantitat'] != -1 && entry['quantitat'] != 'NaN') {
          quantitiesNOX.add(entry['quantitat']);
        } else {
          quantitiesNOX.add(0);
        }
      }
      // Mostrar el gráfico con los datos obtenidos
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchDataCO() async {
     final response = await http.get(Uri.parse('$ip/dadesestacio/desde/${widget.codiEstacio}/$selectedDate/CO'));
     if (quantitiesCO.isNotEmpty) quantitiesCO = [];
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      // Parsear los datos obtenidos y generar las listas de fechas y cantidades
      for (var entry in data) {
        if (entry['quantitat'] != -1 && entry['quantitat'] != 'NaN') {
          quantitiesCO.add(entry['quantitat']);
        } else {
          quantitiesCO.add(0);
        }
      }
      // Mostrar el gráfico con los datos obtenidos
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchDataPM25() async {
     final response = await http.get(Uri.parse('$ip/dadesestacio/desde/${widget.codiEstacio}/$selectedDate/PM25'));
     if (quantitiesPM25.isNotEmpty) quantitiesPM25 = [];
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      // Parsear los datos obtenidos y generar las listas de fechas y cantidades
      for (var entry in data) {
        if (entry['quantitat'] != -1 && entry['quantitat'] != 'NaN') {
          quantitiesPM25.add(entry['quantitat']);
        } else {
          quantitiesPM25.add(0);
        }
      }
      // Mostrar el gráfico con los datos obtenidos
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchDataC6H6() async {
     final response = await http.get(Uri.parse('$ip/dadesestacio/desde/${widget.codiEstacio}/$selectedDate/C6H6'));
     if (quantitiesC6H6.isNotEmpty) quantitiesC6H6 = [];
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      // Parsear los datos obtenidos y generar las listas de fechas y cantidades
      for (var entry in data) {
        if (entry['quantitat'] != -1 && entry['quantitat'] != 'NaN') {
          quantitiesC6H6.add(entry['quantitat']);
        } else {
          quantitiesC6H6.add(0);
        }
      }
      // Mostrar el gráfico con los datos obtenidos
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchDataAll() async {
    await Future.wait([
      if (isCheckedNO) fetchDataNO(),
      if (isCheckedPM10) fetchDataPM10(),
      if (isCheckedPM25) fetchDataPM25(),
      if (isCheckedCO) fetchDataCO(),
      if (isCheckedNOX) fetchDataNOX(),
      if (isCheckedNO2) fetchDataNO2(),
      if (isCheckedO3) fetchDataO3(),
      if (isCheckedC6H6) fetchDataC6H6(),
      if (isCheckedSO2) fetchDataSO2(),
    ]);
  }

  //Widget del grafico filtrat 
  Widget showChart(List<DateTime> dates) {
    return FutureBuilder(
      future: fetchDataAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Column(
            children: [
        Text(TranslationService().translate('dataGraph')),
        SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 200,
              child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  bottomTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTextStyles: (value) => const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    getTitles: (value) {
                      // Mostrar solo la fecha seleccionada en el eje X
                      int index = value.toInt();
                      if (/*index >= 0 && index < dates.length*/index % calculateInterval(dates.length) == 0 && index < dates.length) {
                        return '${dates[index].day}/${dates[index].month}';
                      }
                      return '';
                    },
                    margin: 8,
                  ),
                  leftTitles: SideTitles(
                    showTitles: true,
                    getTextStyles: (value) => const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    getTitles: (value) {
                      // Puedes personalizar la forma en que se muestran las cantidades en el eje Y
                      return '${value.toInt()}';
                    },
                    margin: 8,
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                minX: 0,
                maxX: dates.length.toDouble() - 1,
                minY: 0,
                //maxY: quantitiesNO2.isNotEmpty ? quantitiesNO2.reduce((curr, next) => curr > next ? curr : next) : 0,
                lineBarsData: [
                  // Linea NO
                  if (isCheckedNO && quantitiesNO.isNotEmpty) LineChartBarData(
                    spots: List.generate(
                      dates.length,
                      (index) => FlSpot(index.toDouble(), quantitiesNO[index].toDouble()),
                    ),
                    isCurved: false,
                    colors: [const Color.fromARGB(255, 246, 151, 51)],
                    barWidth: 4,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Linea SO2
                  if (isCheckedSO2 && quantitiesSO2.isNotEmpty) LineChartBarData(
                    spots: List.generate(
                      dates.length,
                      (index) => FlSpot(index.toDouble(), quantitiesSO2[index]),
                    ),
                    isCurved: true,
                    colors: [const Color.fromARGB(255, 251, 65, 65)],
                    barWidth: 4,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Linea NOX
                  if (isCheckedNOX && quantitiesNOX.isNotEmpty) LineChartBarData(
                    spots: List.generate(
                      dates.length,
                      (index) => FlSpot(index.toDouble(), quantitiesNOX[index]),
                    ),
                    isCurved: true,
                    colors: [Colors.blue],
                    barWidth: 4,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Linea NO2
                  if (isCheckedNO2 && quantitiesNO2.isNotEmpty) LineChartBarData(
                    spots: List.generate(
                      dates.length,
                      (index) => FlSpot(index.toDouble(), quantitiesNO2[index]),
                    ),
                    isCurved: true,
                    colors: [const Color.fromARGB(255, 56, 156, 29)],
                    barWidth: 4,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Linea O3
                  if (isCheckedO3 && quantitiesO3.isNotEmpty) LineChartBarData(
                    spots: List.generate(
                      dates.length,
                      (index) => FlSpot(index.toDouble(), quantitiesO3[index]),
                    ),
                    isCurved: true,
                    colors: [const Color.fromARGB(255, 158, 29, 124)],
                    barWidth: 4,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Linea PM10
                  if (isCheckedPM10  && quantitiesPM10.isNotEmpty) LineChartBarData(
                    spots: List.generate(
                      dates.length,
                      (index) => FlSpot(index.toDouble(), quantitiesPM10[index]),
                    ),
                    isCurved: true,
                    colors: [const Color.fromARGB(255, 248, 37, 163)],
                    barWidth: 4,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Linea PM25
                  if (isCheckedPM25 && quantitiesPM25.isNotEmpty) LineChartBarData(
                    spots: List.generate(
                      dates.length,
                      (index) => FlSpot(index.toDouble(), quantitiesPM25[index]),
                    ),
                    isCurved: true,
                    colors: [const Color.fromARGB(255, 239, 253, 47)],
                    barWidth: 4,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Linea CO
                  if (isCheckedCO && quantitiesCO.isNotEmpty) LineChartBarData(
                    spots: List.generate(
                      dates.length,
                      (index) => FlSpot(index.toDouble(), quantitiesCO[index]),
                    ),
                    isCurved: true,
                    colors: [const Color.fromARGB(255, 47, 245, 255)],
                    barWidth: 4,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Linea C6H6
                  if (isCheckedC6H6 && quantitiesC6H6.isNotEmpty) LineChartBarData(
                    spots: List.generate(
                      dates.length,
                      (index) => FlSpot(index.toDouble(), quantitiesC6H6[index]),
                    ),
                    isCurved: true,
                    colors: [const Color.fromARGB(255, 44, 6, 6)],
                    barWidth: 4,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: false),
                  ),
                ]
              ),
            ),
          ),
      ],
          );
        }
      },
    );
  }

  int calculateInterval(int length) {
  if (length <= 5) return 1;
  if (length <= 10) return 2;
  return length ~/ 5; // Ajusta según tus necesidades
}

  Color getColorText(String label) {
    if (label == 'SO2') return const Color.fromARGB(255, 251, 65, 65);
    if (label == 'PM10') return const Color.fromARGB(255, 248, 37, 163);
    if (label == 'PM25') return const Color.fromARGB(255, 239, 253, 47);
    if (label == 'CO') return const Color.fromARGB(255, 47, 245, 255);
    if (label == 'NOX') return Colors.blue;
    if (label == 'NO') return const Color.fromARGB(255, 246, 151, 51);
    if (label == 'NO2') return const Color.fromARGB(255, 56, 156, 29);
    if (label == 'C6H6') return const Color.fromARGB(255, 44, 6, 6);
    if (label == 'O3') return const Color.fromARGB(255, 158, 29, 124);
    return Colors.black;
  }

  Widget checkboxWithLabel(String label, bool isChecked, Function fetchData) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (bool? value) {
            setState(() {
              if (label == 'SO2') isCheckedSO2 = value!;
              if (label == 'CO') isCheckedCO = value!;
              if (label == 'PM10') isCheckedPM10 = value!;
              if (label == 'NO') isCheckedNO = value!;
              if (label == 'NOX') isCheckedNOX = value!;
              if (label == 'NO2') isCheckedNO2 = value!;
              if (label == 'PM25') isCheckedPM25 = value!;
              if (label == 'C6H6') isCheckedC6H6 = value!;
              if (label == 'O3') isCheckedO3 = value!;
            });
          },
        ),
        Text(
          label,
          style: TextStyle(
            color: getColorText(label),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.municipi,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              '${TranslationService().translate('comarca')} ${widget.comarca}\nICA: ${widget.valorICA}',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 15),
            Text(
              TranslationService().translate('contaminants'),
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),

            const SizedBox(height: 10),
            FutureBuilder(
              future: fetchContaminantsData(widget.codiEstacio),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !contsCarregats) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Utiliza CrossAxisAlignment.start para alinear los hijos a la izquierda
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Alinea los textos de los contaminantes a la izquierda
                    children: snapshot.data.map<Widget>((contaminant) {
                      // Incluye un punto al principio de cada elemento del listado
                      return Text(
                        "• ${contaminant['contaminant']}: ${contaminant['quantitat']} ${contaminant['unitat']}",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
            selectButtons(),
            if (selectedDate != null) Wrap(
              children: [
                checkboxWithLabel('SO2', isCheckedSO2, fetchDataSO2),
                checkboxWithLabel('O3', isCheckedO3, fetchDataO3),
                checkboxWithLabel('NO2', isCheckedNO2, fetchDataNO2),
                checkboxWithLabel('NOX', isCheckedNOX, fetchDataNOX),
                checkboxWithLabel('NO', isCheckedNO, fetchDataNO),
                checkboxWithLabel('PM10', isCheckedPM10, fetchDataPM10),
                checkboxWithLabel('PM25', isCheckedPM25, fetchDataPM25),
                checkboxWithLabel('C6H6', isCheckedC6H6, fetchDataC6H6),
                checkboxWithLabel('CO', isCheckedCO, fetchDataCO),
              ],
            ),
            if (selectedDate != null) showChart(dates),
          ],
        ),
      ),
      backgroundColor: Colors.white, // Cambia el color de fondo
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Colors.black87, width: 3), // Añade un borde
      ),
      elevation: 8,
      actions: <Widget>[
        TextButton(
          child: Text(
            TranslationService().translate('close'),
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}