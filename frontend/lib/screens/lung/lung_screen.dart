import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/providers/locale_translationProvider.dart';
import 'package:frontend/utils/load_data.dart';
import 'package:frontend/utils/s3_image_loader.dart';

import 'package:intl/intl.dart';

class LungScreen extends StatefulWidget {

  final LoadData ld;

  const LungScreen({super.key, required this.ld});

  @override
  State<LungScreen> createState() => LungScreenState();
}

class LungScreenState extends State<LungScreen> {

  late LoadData ld;
  List<Widget> llistaCaixes = [];
  double curvaturaWidgets = 18.0;
  double paddingCaixes = 15.0;
  List<double> marginFirstWidget = [15, 0, 15, 10];
  List<double> marginNextWidgets = [15, 0, 15, 10];

  double subtitlesUltimaSet = 16;
  double textUltimaSet = 15;

  int valorICALung = 0;

  static const Map<int, String> lungImages = {
    0: 'lung_gray.png',
    50: 'lung_green.png',
    100: 'lung_yellow.png',
    150: 'lung_orange.png',
    200: 'lung_red.png',
    300: 'lung_purple.png',
    500: 'lung_brown.png',
  };

  static const Map<int, Color> colorMapICA = {
    50: Color.fromARGB(255, 75, 170, 79),
    100: Color.fromARGB(255, 233, 217, 78),
    150: Color.fromARGB(255, 255, 189, 91),
    200: Color.fromARGB(255, 250, 99, 88),
    300: Color.fromARGB(255, 187, 106, 201),
    500: Color.fromARGB(255, 125, 77, 60)
  };

  List<String> ultimaSetmanaDies = [];

  List<String> ultimaSetmanaUbs = [];

  List<int> ultimaSetmanaICAs = [];

  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    ld = widget.ld;
    if (ld.isLoadedForum) {
      isLoaded = true;
      ultimaSetmanaDies = widget.ld.ultimaSetmanaDies;
      ultimaSetmanaUbs = widget.ld.ultimaSetmanaUbs;
      ultimaSetmanaICAs = widget.ld.ultimaSetmanaICAs;
    } else {
      ld.addListener(() {
        if (ld.isLoadedPulmo) {
          setState(() {
            isLoaded = true;
            ultimaSetmanaDies = widget.ld.ultimaSetmanaDies;
            ultimaSetmanaUbs = widget.ld.ultimaSetmanaUbs;
            ultimaSetmanaICAs = widget.ld.ultimaSetmanaICAs;
          });
        }
      });
    }
  }

  int calcularMitja(List<int> lista) {

    if (lista.isEmpty) {
      return -1;
    } else {
      List<int> valorsValids = lista.where((valor) => valor != -1).toList();
      if (valorsValids.isEmpty) return -1;
      int suma = valorsValids.reduce((a, b) => a + b);
      double mitja = suma / valorsValids.length;

      return mitja.toInt();
    }
  }

  List<Widget> llistaDies (screenHeight, double screenWidth) {

    List<Widget> columnItems = [];
    //var localizations = AppLocalizations.of(context)!;
    columnItems.add(
      Text (
        TranslationService().translate('day'), //'Dia',
        style: TextStyle (
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: subtitlesUltimaSet
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
    columnItems.add(const SizedBox(height: 10));

    for (int i = 0; i < ultimaSetmanaDies.length; i++) {
      bool senseVal = ultimaSetmanaDies[i] == "-";

      columnItems.add(
        Text (
          senseVal ? '-' : ultimaSetmanaDies[i],
          style: TextStyle (
            color: Colors.black,
            fontSize: textUltimaSet
          ),
          overflow: TextOverflow.ellipsis,
        ),
      );
      if (i != ultimaSetmanaDies.length-1) columnItems.add(const SizedBox(height: 10));
    }

    return columnItems;
  }

  List<Widget> llistaUbs (screenHeight, double screenWidth) {

    List<Widget> columnItems = [];
    //var localizations = AppLocalizations.of(context)!;
    columnItems.add(
      Text (
        TranslationService().translate('ubi'), //'Ubicació',
        style: TextStyle (
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: subtitlesUltimaSet
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
    columnItems.add(const SizedBox(height: 10));

    for (int i = 0; i < ultimaSetmanaUbs.length; i++) {
      bool senseVal = ultimaSetmanaUbs[i] == "-";

      columnItems.add(
        Text (
          senseVal ? '-' : ultimaSetmanaUbs[i],
          style: TextStyle (
              color: Colors.black,
              fontSize: textUltimaSet
          ),
          overflow: TextOverflow.ellipsis,
        ),
      );
      if (i != ultimaSetmanaUbs.length-1) columnItems.add(const SizedBox(height: 10));
    }
    return columnItems;
  }

  List<Widget> llistaICAs (screenHeight, double screenWidth) {

    List<Widget> columnItems = [];
    //var localizations = AppLocalizations.of(context)!;
    columnItems.add(
      Text (
        TranslationService().translate('ica'), // 'ICA',
        style: TextStyle (
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: subtitlesUltimaSet
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
    columnItems.add(const SizedBox(height: 10));

    for (int i = 0; i < ultimaSetmanaICAs.length; i++) {
      bool senseVal = ultimaSetmanaICAs[i] < 0;

      columnItems.add(
        Text (
          senseVal ? '-' : '${ultimaSetmanaICAs[i]}',
          style: TextStyle (
            color: colorMapICA.entries
                .firstWhere((entry) => ultimaSetmanaICAs[i] <= entry.key)
                .value,
            fontWeight: FontWeight.bold,
            fontSize: textUltimaSet
          ),
          overflow: TextOverflow.ellipsis,
        ),
      );
      if (i != ultimaSetmanaICAs.length-1) columnItems.add(const SizedBox(height: 10));
    }

    return columnItems;
  }


  Widget _buildCustomScrollView(double screenHeight, double screenWidth) {

    ultimaSetmanaDies = widget.ld.ultimaSetmanaDies;
    ultimaSetmanaUbs = widget.ld.ultimaSetmanaUbs;
    ultimaSetmanaICAs = widget.ld.ultimaSetmanaICAs;

    String lungImage = lungImages.entries
        .firstWhere((entry) => valorICALung <= entry.key)
        .value;

    Color col = Colors.black;
    if (valorICALung != -1) {
      colorMapICA.entries
          .firstWhere((entry) => valorICALung <= entry.key)
          .value;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = MediaQuery.of(context).size.width;
              double screenHeight = MediaQuery.of(context).size.height;

              return Stack(
                children: [
                  S3ImageLoader.loadImage(
                    'assets/$lungImage',
                    width: screenWidth,
                    height: screenHeight/2.2,
                  ),
                  Positioned(
                    bottom: screenHeight/2.2 * 0.03, // Adjust as needed
                    right: screenWidth * 0.15,      // Adjust as needed
                    child: Text(
                      valorICALung != -1 ? '$valorICALung' : '-',
                      style: TextStyle(
                        color: col,
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Column(
            children: llistaCaixes,
          ),
        ],
      ),
    );
  }

  Widget _buildLastWeek(double screenHeight, double screenWidth) {
    List<Widget> casellesDia = llistaDies(screenHeight, screenWidth);
    List<Widget> casellesICA = llistaICAs(screenHeight, screenWidth);
    List<Widget> casellesUbs = llistaUbs(screenHeight, screenWidth);

    return Container(

      width: screenWidth,
      padding: EdgeInsets.all(paddingCaixes),
      margin: EdgeInsets.fromLTRB(marginNextWidgets[0], marginNextWidgets[1], marginNextWidgets[2], marginNextWidgets[3]),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2.0,
        ),
        color: Colors.white, // Color de fondo blanco para que sea visible
        borderRadius: BorderRadius.circular(curvaturaWidgets),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            TranslationService().translate('lastweek'),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: casellesDia,
              ),
              const SizedBox(width: 15),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: casellesUbs,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: casellesICA,
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildHistoricGraph(double screenWidth) {

    List<int> filteredICAs = ultimaSetmanaICAs.where((ica) => ica != -1).toList();

    if (filteredICAs.isEmpty) {
      return Container(
        width: screenWidth,
        height: 200,
        padding: EdgeInsets.all(paddingCaixes),
        margin: EdgeInsets.fromLTRB(marginNextWidgets[0], marginNextWidgets[1], marginNextWidgets[2], marginNextWidgets[3]),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 2.0,
          ),
          color: Colors.white, // Color de fondo blanco para que sea visible
          borderRadius: BorderRadius.circular(curvaturaWidgets),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              TranslationService().translate('historicgraphic'),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 60),
            Text(
              textAlign: TextAlign.center,
              TranslationService().translate('errorgraphic'),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
            )
          ]
        ),
      );
    } else {

      DateFormat formatter = DateFormat('dd-MM');
      List<String> ultimaSetmanaDiesFormated = ultimaSetmanaDies.map((fechaString) {
        DateTime fechaObjeto = DateTime.parse(fechaString);
        return formatter.format(fechaObjeto);
      }).toList();

      return Container(
        width: screenWidth,
        padding: EdgeInsets.all(paddingCaixes),
        margin: EdgeInsets.fromLTRB(
            marginNextWidgets[0], marginNextWidgets[1], marginNextWidgets[2],
            marginNextWidgets[3]),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 2.0,
          ),
          color: Colors.white, // Color de fondo blanco para que sea visible
          borderRadius: BorderRadius.circular(curvaturaWidgets),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              TranslationService().translate('historicgraphic'),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 15),
            Container(
              width: screenWidth,
              height: 200,
              padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),

              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: filteredICAs
                          .asMap()
                          .entries
                          .map((entry) {
                        return FlSpot(entry.key.toDouble(),
                            entry.value.toDouble());
                      }).toList(),
                      colors: [colorMapICA.entries
                          .firstWhere((entry) => valorICALung <= entry.key)
                          .value
                      ],
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                              radius: 4.0,
                              // Cambia el tamaño de los puntos
                              color: colorMapICA.entries
                                  .firstWhere((entry) =>
                              filteredICAs[index] <= entry.key)
                                  .value,
                              // Color de los puntos
                              strokeColor: Colors.transparent,
                              // Color del borde de los puntos
                              strokeWidth: 0, // Grosor del borde de los puntos
                            ),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (value) =>
                      const TextStyle(color: Colors.black, fontSize: 14),
                      margin: 10,
                      getTitles: (value) {
                        if (value >= 0 && value < ultimaSetmanaDiesFormated.length) {
                          return ultimaSetmanaDiesFormated[value.toInt()];
                        }
                        return '';
                      },
                    ),
                    leftTitles: SideTitles(
                        showTitles: true,
                        interval: 50
                    ),
                  ),
                  minY: 0,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }


  @override
Widget build(BuildContext context) {
  Size screenSize = MediaQuery.of(context).size;
  double screenWidth = screenSize.width;
  double screenHeight = screenSize.height;

  valorICALung = calcularMitja(ultimaSetmanaICAs);

  llistaCaixes = [
    //Caixa last week
    _buildLastWeek(screenHeight, screenWidth),
    //Caixa historic
    _buildHistoricGraph(screenWidth)
  ];

  return Scaffold(
    backgroundColor: Colors.transparent,
    body: isLoaded
        ? _buildCustomScrollView(screenHeight, screenWidth)
        : const Center(
            child: CircularProgressIndicator(),
          ),
  );
}

}