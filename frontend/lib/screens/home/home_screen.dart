import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/providers/locale_translationProvider.dart';

class HomeScreen extends StatefulWidget {

  final String ciutat;
  final int ica;
  final Map<String, double> contaminants;
  final Map<String, int> suggestedplaces;

  const HomeScreen({super.key, required this.ciutat, required this.ica, required this.contaminants, required this.suggestedplaces});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  late String ciutat;

  late int valorICA;
  List<Widget> llistaCaixes = [];

  double curvaturaWidgets = 18.0;
  double paddingCaixes = 15.0;
  List<double> marginFirstWidget = [15, 15, 15, 10];
  List<double> marginNextWidgets = [15, 0, 15, 10];
  double midaLletraCiutats = 14;
  double midaColorsLlegenda = 35;

  static const Map<int, Color> colorMapPM10 = {
    20: Color.fromARGB(255, 75, 170, 79),
    40: Color.fromARGB(255, 233, 217, 78),
    50: Color.fromARGB(255, 255, 189, 91),
    100: Color.fromARGB(255, 250, 99, 88),
    150: Color.fromARGB(255, 187, 106, 201),
    300: Color.fromARGB(255, 125, 77, 60)
  };
  static const Map<int, Color> colorMapNO2 = {
    40: Color.fromARGB(255, 75, 170, 79),
    90: Color.fromARGB(255, 233, 217, 78),
    120: Color.fromARGB(255, 255, 189, 91),
    230: Color.fromARGB(255, 250, 99, 88),
    340: Color.fromARGB(255, 187, 106, 201),
    500: Color.fromARGB(255, 125, 77, 60)
  };
  static const Map<int, Color> colorMapO3 = {
    50: Color.fromARGB(255, 75, 170, 79),
    100: Color.fromARGB(255, 233, 217, 78),
    130: Color.fromARGB(255, 255, 189, 91),
    240: Color.fromARGB(255, 250, 99, 88),
    380: Color.fromARGB(255, 187, 106, 201),
    500: Color.fromARGB(255, 125, 77, 60)
  };
  static const Map<int, Color> colorMapC6H6 = {
    5: Color.fromARGB(255, 75, 170, 79),
    10: Color.fromARGB(255, 233, 217, 78),
    20: Color.fromARGB(255, 255, 189, 91),
    50: Color.fromARGB(255, 250, 99, 88),
    100: Color.fromARGB(255, 187, 106, 201),
    150: Color.fromARGB(255, 125, 77, 60)
  };
  static const Map<int, Color> colorMapH2S = {
    25: Color.fromARGB(255, 75, 170, 79),
    50: Color.fromARGB(255, 233, 217, 78),
    100: Color.fromARGB(255, 255, 189, 91),
    200: Color.fromARGB(255, 250, 99, 88),
    500: Color.fromARGB(255, 187, 106, 201),
    600: Color.fromARGB(255, 125, 77, 60)
  };
  static const Map<int, Color> colorMapCO = {
    2: Color.fromARGB(255, 75, 170, 79),
    5: Color.fromARGB(255, 233, 217, 78),
    10: Color.fromARGB(255, 255, 189, 91),
    20: Color.fromARGB(255, 250, 99, 88),
    50: Color.fromARGB(255, 187, 106, 201),
    100: Color.fromARGB(255, 125, 77, 60)
  };
  static const Map<int, Color> colorMapSO2 = {
    100: Color.fromARGB(255, 75, 170, 79),
    200: Color.fromARGB(255, 233, 217, 78),
    350: Color.fromARGB(255, 255, 189, 91),
    500: Color.fromARGB(255, 250, 99, 88),
    750: Color.fromARGB(255, 187, 106, 201),
    1250: Color.fromARGB(255, 125, 77, 60)
  };
  static const Map<int, Color> colorMapPM25 = {
    10: Color.fromARGB(255, 75, 170, 79),
    20: Color.fromARGB(255, 233, 217, 78),
    25: Color.fromARGB(255, 255, 189, 91),
    50: Color.fromARGB(255, 250, 99, 88),
    75: Color.fromARGB(255, 187, 106, 201),
    150: Color.fromARGB(255, 125, 77, 60)
  };
  static const Map<int, Color> colorMapNOX = {
    20: Color.fromARGB(255, 75, 170, 79),
    40: Color.fromARGB(255, 233, 217, 78),
    60: Color.fromARGB(255, 255, 189, 91),
    80: Color.fromARGB(255, 250, 99, 88),
    100: Color.fromARGB(255, 187, 106, 201),
    150: Color.fromARGB(255, 125, 77, 60)
  };
  static const Map<int, Color> colorMapHg = {
    1: Color.fromARGB(255, 75, 170, 79),
    5: Color.fromARGB(255, 233, 217, 78),
    10: Color.fromARGB(255, 255, 189, 91),
    15: Color.fromARGB(255, 250, 99, 88),
    20: Color.fromARGB(255, 187, 106, 201),
    50: Color.fromARGB(255, 125, 77, 60)
  };
  static const Map<int, Color> colorMapNO = {
    10: Color.fromARGB(255, 75, 170, 79),
    20: Color.fromARGB(255, 233, 217, 78),
    25: Color.fromARGB(255, 255, 189, 91),
    50: Color.fromARGB(255, 250, 99, 88),
    75: Color.fromARGB(255, 187, 106, 201),
    150: Color.fromARGB(255, 125, 77, 60)
  };
  static const Map<int, Color> colorMapPM1 = {
    1: Color.fromARGB(255, 75, 170, 79),
    5: Color.fromARGB(255, 233, 217, 78),
    10: Color.fromARGB(255, 255, 189, 91),
    15: Color.fromARGB(255, 250, 99, 88),
    20: Color.fromARGB(255, 187, 106, 201),
    50: Color.fromARGB(255, 125, 77, 60)
  };
  
  static const Map<int, Color> colorMapICA = {
     50: Color.fromARGB(255, 75, 170, 79),
     100: Color.fromARGB(255, 233, 217, 78),
     150: Color.fromARGB(255, 255, 189, 91),
     200: Color.fromARGB(255, 250, 99, 88),
     300: Color.fromARGB(255, 187, 106, 201),
     500: Color.fromARGB(255, 125, 77, 60)
  };

  Map<String, Map <int, Color>> llistaMapes = {
    "PM10": colorMapPM10,
    "NO2": colorMapNO2,
    "O3": colorMapO3,
    "C6H6": colorMapC6H6,
    "H2S": colorMapH2S,
    "CO": colorMapCO,
    "SO2": colorMapSO2,
    "PM25": colorMapPM25,
    "NOX": colorMapNOX,
    "Hg": colorMapHg,
    "NO": colorMapNO,
    "PM1": colorMapPM1
  };

String qualitatMapString() {
    //var localizations = AppLocalizations.of(context)!;
    String qualitat = "";
    if (valorICA >= 0 && valorICA <= 50) {
        qualitat = TranslationService().translate('good');
    } else if (valorICA > 50 && valorICA <= 100) {
        qualitat = TranslationService().translate('acceptable'); //'Acceptable';
    } else if (valorICA > 100 && valorICA <= 150) {
        qualitat = TranslationService().translate('regular'); //'Regular';
    } else if (valorICA > 150 && valorICA <= 200) {
        qualitat = TranslationService().translate('bad'); //'Dolenta';
    } else if (valorICA > 200 && valorICA <= 300) {
        qualitat = TranslationService().translate('veryBad'); //'Molt dolenta';
    } else if (valorICA > 300 && valorICA <= 500) {
        qualitat = TranslationService().translate('dangerous'); //'Perillosa';
    } else {
        qualitat = "";
    }
    return qualitat;
}

  List<double> contaminants = [];
  List<String> nomContaminants = [];

  String frasesRecomanacionsString(int n) {
    //var localizations = AppLocalizations.of(context)!;
    String recommend = "";
    switch (n) {
      case 0:
        recommend = TranslationService().translate('recomm0'); //"Gaudeix d'activitats a l'aire lliure i respira natura",
        break;
      case 1:
        recommend = TranslationService().translate('recomm1'); // "Obre les finestres per que l'aire fresc i net entri a l'interior",
        break;
      case 2: 
        recommend = TranslationService().translate('recomm2'); // "Els grups sensibles han de reduïr l'exercici a l'exterior",
        break;
      case 3: 
        recommend = TranslationService().translate('recomm3'); // "Tanca les finestres per evitar l'aire brut a l'exterior",
        break;
      case 4: 
        recommend = TranslationService().translate('recomm4'); //  "Els grups sensibles han de portar mascareta a l'exterior",
        break;
      case 5: 
        recommend = TranslationService().translate('recomm5'); // "Evita l'exercici a l'exterior",
        break;
      case 6: 
        recommend = TranslationService().translate('recomm6'); // "Tanca les finestres per evitar l'aire brut de l'exterior",
        break;
      case 7: 
        recommend = TranslationService().translate('recomm7'); // "Utilitza mascareta a l'exterior",
        break;
      case 8: 
        recommend = TranslationService().translate('recomm8'); // "Utilitza un purificador d'aire",
        break;
      
      default:
        recommend = "";
    }
    return recommend;
  }

  static const List<IconData> iconesRecomanacions = [
    Icons.pedal_bike,
    Icons.window_outlined,
    Icons.masks_outlined,
    Icons.air_rounded
  ];

  List<String> ciutatsICA = [];
  List<int> valorsCiutatsICA = [];

  List<Widget> llistaContaminants (double screenWidth) {

    List<Widget> columnItems = [];

    for (int i = 0; i < contaminants.length; i++) {
      bool senseVal = contaminants[i] < 0;

      Widget row = Row(
        children: [
          const Divider(height: 30),
          Text(
            senseVal ? '- µg/m³' : '${double.parse(contaminants[i].toStringAsFixed(1))} µg/m³',
          ),
        ],
      );
      columnItems.add(row);
    }

    return columnItems;
  }

  List<Widget> llistaBarres(double screenWidth) {

    List<Widget> columnItems = []; // Lista para almacenar los elementos de la columna
    columnItems.add(
      const SizedBox(height: 1)
    );

    for (int i = 0; i < contaminants.length; i++) {

      Map<int, Color>? mapaInterior;

      if (llistaMapes.containsKey(nomContaminants[i])) {
        mapaInterior = llistaMapes[nomContaminants[i]];
      }

      int? max = mapaInterior?.keys.firstWhere((key) => contaminants[i] <= key, orElse: () => 0);

      bool senseVal = contaminants[i] < 0.1;
      Widget row = Row(
        children: [
          Container(
            margin: const EdgeInsets.all(10.5),
            width: screenWidth - 210,
            height: 9,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5),
            ),
            child: Stack(
              children: [
                // Contenedor para la barra de progreso
                Container(
                 width: senseVal ? 0 : (contaminants[i]/max!)*(screenWidth-210)+5,
                  height: 9,
                  decoration: BoxDecoration(
                    color: mapaInterior?.entries.firstWhere(
                          (element) => contaminants[i] <= element.key,
                      orElse: () => const MapEntry(-1, Colors.transparent), // Valor predeterminado
                    ).value,
                    borderRadius: BorderRadius.circular(5),
                  ),
                )
              ],
            ),
          ),
        ],
      );

      // Añadimos la fila a la lista de elementos de la columna
      columnItems.add(row);
    }

    return columnItems; // Retornamos la lista de elementos de la columna
  }

  List<Widget> llistaNomConts (double screenWidth) {

    List<Widget> columnItems = [];

    for (int i = 0; i < nomContaminants.length; i++) {
      Widget row = Row(
        children: [
          const SizedBox(height: 30),
          Text(nomContaminants[i]),
        ],
      );
      columnItems.add(row);
    }

    return columnItems;
  }

  Widget llistaRecomanacions (double screenWidth) {

    Widget columna = const Column();

    if (valorICA <= 51) {
      columna = Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  iconesRecomanacions[0],
                  // Aquí puedes utilizar cualquier icono predefinido de Material Design
                  color: colorMapICA.entries
                      .firstWhere((entry) => valorICA <= entry.key)
                      .value,
                  size: 50.0,
                ),
                const SizedBox(width: 15),
                Flexible(
                  child: Text(
                    frasesRecomanacionsString(0),
                    //frasesRecomanacions[0],
                    softWrap: true, // Permite que el texto se divida en varias líneas automáticamente
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  iconesRecomanacions[1],
                  // Aquí puedes utilizar cualquier icono predefinido de Material Design
                  color: colorMapICA.entries
                      .firstWhere((entry) => valorICA <= entry.key)
                      .value,
                  size: 50.0,
                ),
                const SizedBox(width: 15),
                Flexible(
                  child: Text(
                    frasesRecomanacionsString(1),
                    //frasesRecomanacions[1],
                    softWrap: true, // Permite que el texto se divida en varias líneas automáticamente
                  ),
                ),
              ],
            ),
          ]
      );
    } else if (valorICA > 51 && valorICA <= 151) {
      columna = Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  iconesRecomanacions[0],
                  // Aquí puedes utilizar cualquier icono predefinido de Material Design
                  color: colorMapICA.entries
                      .firstWhere((entry) => valorICA <= entry.key)
                      .value,
                  size: 50.0,
                ),
                const SizedBox(width: 15),
                Flexible(
                  child: Text(
                    frasesRecomanacionsString(2),
                    //frasesRecomanacions[2],
                    softWrap: true, // Permite que el texto se divida en varias líneas automáticamente
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  iconesRecomanacions[1],
                  // Aquí puedes utilizar cualquier icono predefinido de Material Design
                  color: colorMapICA.entries
                      .firstWhere((entry) => valorICA <= entry.key)
                      .value,
                  size: 50.0,
                ),
                const SizedBox(width: 15),
                Flexible(
                  child: Text(
                    frasesRecomanacionsString(3),
                    //frasesRecomanacions[3],
                    softWrap: true, // Permite que el texto se divida en varias líneas automáticamente
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  iconesRecomanacions[2],
                  // Aquí puedes utilizar cualquier icono predefinido de Material Design
                  color: colorMapICA.entries
                      .firstWhere((entry) => valorICA <= entry.key)
                      .value,
                  size: 50.0,
                ),
                const SizedBox(width: 15),
                Flexible(
                  child: Text(
                    frasesRecomanacionsString(4),
                    //frasesRecomanacions[4],
                    softWrap: true, // Permite que el texto se divida en varias líneas automáticamente
                  ),
                ),
              ],
            ),
          ]
      );
    } else {
      columna = Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  iconesRecomanacions[0],
                  // Aquí puedes utilizar cualquier icono predefinido de Material Design
                  color: colorMapICA.entries
                      .firstWhere((entry) => valorICA <= entry.key)
                      .value,
                  size: 50.0,
                ),
                const SizedBox(width: 15),
                Flexible(
                  child: Text(
                    frasesRecomanacionsString(5),
                    //frasesRecomanacions[5],
                    softWrap: true, // Permite que el texto se divida en varias líneas automáticamente
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  iconesRecomanacions[1],
                  // Aquí puedes utilizar cualquier icono predefinido de Material Design
                  color: colorMapICA.entries
                      .firstWhere((entry) => valorICA <= entry.key)
                      .value,
                  size: 50.0,
                ),
                const SizedBox(width: 15),
                Flexible(
                  child: Text(
                    frasesRecomanacionsString(6),
                    //frasesRecomanacions[6],
                    softWrap: true, // Permite que el texto se divida en varias líneas automáticamente
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  iconesRecomanacions[2],
                  // Aquí puedes utilizar cualquier icono predefinido de Material Design
                  color: colorMapICA.entries
                      .firstWhere((entry) => valorICA <= entry.key)
                      .value,
                  size: 50.0,
                ),
                const SizedBox(width: 15),
                Flexible(
                  child: Text(
                    frasesRecomanacionsString(7),
                    //frasesRecomanacions[7],
                    softWrap: true, // Permite que el texto se divida en varias líneas automáticamente
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  iconesRecomanacions[3],
                  // Aquí puedes utilizar cualquier icono predefinido de Material Design
                  color: colorMapICA.entries
                      .firstWhere((entry) => valorICA <= entry.key)
                      .value,
                  size: 50.0,
                ),
                const SizedBox(width: 15),
                Flexible(
                  child: Text(
                    frasesRecomanacionsString(8),
                    //frasesRecomanacions[8],
                    softWrap: true, // Permite que el texto se divida en varias líneas automáticamente
                  ),
                ),
              ],
            ),
          ]
      );
    }

    return columna;
  }

  Widget suggestedPlaces() {

    List<Widget> suggestedPlacesWidgets = [];

    for (int i = 0; i < ciutatsICA.length; i++) {
      suggestedPlacesWidgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '#${i + 1}   ${ciutatsICA[i]}',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: midaLletraCiutats,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(height: 10),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: suggestedPlacesWidgets,
    );
  }

  Widget suggestedPlacesICA() {

    List<Widget> suggestedPlacesWidgets = [];

    for (int i = 0; i < valorsCiutatsICA.length; i++) {
      final colorEntry = colorMapICA.entries.firstWhere((entry) => valorsCiutatsICA[i] <= entry.key);
      suggestedPlacesWidgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              valorsCiutatsICA[i].toString(),
              style: TextStyle(
                color: colorEntry.value,
                fontWeight: FontWeight.bold,
                fontSize: midaLletraCiutats,
              ),
            ),
            const Divider(height: 10),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: suggestedPlacesWidgets,
    );
  }


  Widget _buildContaminants(double screenWidth) {
    List<Widget> casellesNoms = llistaNomConts(screenWidth);
    List<Widget> casellesBarres = llistaBarres(screenWidth);
    List<Widget> casellesContaminants = llistaContaminants(screenWidth);

    return Container(
      //Marco Dimensions Container
      width: screenWidth,
      margin: EdgeInsets.fromLTRB(marginNextWidgets[0], marginNextWidgets[1], marginNextWidgets[2], marginNextWidgets[3]),
      padding: EdgeInsets.all(paddingCaixes),
      //Li poso marc i curvatura a les puntes
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2.0,
        ),
        color: Colors.white,
        borderRadius: BorderRadius.circular(curvaturaWidgets)
      ),
      child: Column(
          children: [
             Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text (
                  TranslationService().translate('contaminants'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )
                )
              ]
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: casellesNoms,
                ),
                Column(
                  children: casellesBarres,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: casellesContaminants,
                )
              ],
            )
          ]
        //caselles,
      ),
    );
  }


  Widget _buildQualitatAct(double screenHeight, double screenWidth) {

    DateTime now = DateTime.now();
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    String dia = DateFormat('dd-MM-yyyy').format(yesterday);

    return Container(
      width: screenWidth,
      margin: EdgeInsets.fromLTRB(marginFirstWidget[0], marginFirstWidget[1], marginFirstWidget[2], marginFirstWidget[3]),
      padding: EdgeInsets.all(paddingCaixes),
      //Li poso marc i curvatura a les puntes
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 2.0,
          ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(curvaturaWidgets)
      ),

      child: Column (
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Qualitat de l'aire en text
              Text (
                //qualitatMap.entries.firstWhere((entry) => valorICA <= entry.key).value,
                qualitatMapString(),
                style: const TextStyle (
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              ),
              //More details text
              IconButton(
                icon: const Icon(Icons.info, size: 20),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      //var localizations = AppLocalizations.of(context)!;
                      return AlertDialog(
                        title: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                            children: [
                              TextSpan(
                                text: TranslationService().translate('whatIs'), //'Què és ',
                              ),
                              TextSpan(
                                text: TranslationService().translate('ica'), // 'ICA',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic, // Aplica cursiva a "ICA"
                                ),
                              ),
                              const TextSpan(
                                text: '?',
                              ),
                            ],
                          ),
                        ),
                        content: SizedBox(
                          width: screenWidth,
                          height: screenHeight/3,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text( TranslationService().translate('icaDef'),
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text( TranslationService().translate('caption'),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Container(
                                            height: midaColorsLlegenda,
                                            color: colorMapICA.values.elementAt(0),
                                            child: Center(
                                              child: Text(
                                                TranslationService().translate('capGood'),  //'Bona: 0-50',
                                                style: const TextStyle(
                                                  color: Color.fromARGB(255, 75-60, 170-60, 79-60),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: midaColorsLlegenda,
                                            color: colorMapICA.values.elementAt(1),
                                            child: Center(
                                              child: Text(
                                                TranslationService().translate('capAcceptable'), //'Acceptable: 51-100',
                                                style: const TextStyle(
                                                  color: Color.fromARGB(255, 233-60, 217-60, 78-60),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: midaColorsLlegenda,
                                            color: colorMapICA.values.elementAt(2),
                                            child: Center(
                                              child: Text(
                                                TranslationService().translate('capRegular'), //'Regular: 101-150',
                                                style: const TextStyle(
                                                  color: Color.fromARGB(255, 255-60, 189-60, 91-60),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: midaColorsLlegenda,
                                            color: colorMapICA.values.elementAt(3),
                                            child: Center(
                                              child: Text(
                                                TranslationService().translate('capBad'), //'Dolenta: 151-200',
                                                style: const TextStyle(
                                                  color: Color.fromARGB(255, 250-60, 99-60, 88-60),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: midaColorsLlegenda,
                                            color: colorMapICA.values.elementAt(4),
                                            child: Center(
                                              child: Text(
                                                TranslationService().translate('capVeryBad'), //'Molt dolenta: 201-300',
                                                style: const TextStyle(
                                                  color: Color.fromARGB(255, 187-60, 106-60, 201-60),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: midaColorsLlegenda,
                                            color: colorMapICA.values.elementAt(5),
                                            child: Center(
                                              child: Text(
                                                TranslationService().translate('capDangerous'), //'Perillosa: 301-500',
                                                style: const TextStyle(
                                                  color: Color.fromARGB(255, 125-60, 77-60, 60-60),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 40),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: TranslationService().translate('lastUpdate'), //'Última actualització: ',
                                            style: const TextStyle(
                                                color: Colors.black38,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          TextSpan(
                                              text: dia,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.black38,
                                              )
                                          ),
                                        ],
                                      ),
                                    )
                                  ]
                                )
                              ],
                            ),
                          ),
                        ),
                        backgroundColor: Colors.white, // Cambia el color de fondo
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(curvaturaWidgets),
                          side: const BorderSide(color: Colors.black87, width: 3), // Añade un borde
                        ),
                        elevation: 8, // Añade una sombra
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              TranslationService().translate('close'), //'Tancar',
                              style: const TextStyle(
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

            ]
          ),

          const SizedBox(height: 10),
          Container(
            width: screenWidth,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5),
            ),
            //Stack per afegir una barra sobre la dimensio
            child: Stack(
              children: [
                Container(
                  width: (valorICA/500.0)*screenWidth,
                  height: 10,
                  decoration: BoxDecoration (
                    color: colorMapICA.entries.firstWhere((entry) => valorICA <= entry.key).value,
                    borderRadius: BorderRadius.circular(5),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }


  Widget _buildRecomanacions(double screenWidth) {

    Widget recomanacions = llistaRecomanacions(screenWidth);

    return Container(
      width: screenWidth,
      margin: EdgeInsets.fromLTRB(marginNextWidgets[0], marginNextWidgets[1], marginNextWidgets[2], marginNextWidgets[3]),
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2.0,
        ),
        color: Colors.white,
        borderRadius: BorderRadius.circular(curvaturaWidgets)
      ),

      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TranslationService().translate('healthRecomm'),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              recomanacions
            ],
          )
        ],
      ),
    );
  }


  Widget _buildSuggeriments(double screenWidth) {

    return Container(
      //Marco Dimensions Container
      width: screenWidth,
      margin: EdgeInsets.fromLTRB(marginNextWidgets[0], marginNextWidgets[1], marginNextWidgets[2], marginNextWidgets[3]),
      padding: EdgeInsets.all(paddingCaixes),
      //height: 213,
      //Li poso marc i curvatura a les puntes
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 2.0,
          ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(curvaturaWidgets)
      ),
      child: Column(
        children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text (
                    TranslationService().translate('suggestedPlaces'),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    )
                )
              ]
          ),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 12,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: suggestedPlaces(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: suggestedPlacesICA()
              ),
            ],
          )
        ]
      ),
    );
  }


  Widget _buildCustomScrollView(double screenHeight, double screenWidth) {

    double scaleFactor = (screenHeight + screenWidth) / 1000;
    scaleFactor = scaleFactor.clamp(0.5, 2.5);

    double ciutatFontSize = 40 * scaleFactor;
    if (ciutat.length >= 30) {
      ciutatFontSize = 30 * scaleFactor;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 70),

          const SizedBox(height: 50),
          Container(
            padding: EdgeInsets.all(paddingCaixes),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ciutat,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ciutatFontSize,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '$valorICA',
                  style: TextStyle(
                    fontSize: ciutatFontSize+5,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]
            ),
          ),

          const SizedBox(height: 30),
          Column(
            children: llistaCaixes,
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    ciutat = widget.ciutat;
  }

  @override
  Widget build(BuildContext context) {

    //Variables dispositiu
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    valorICA = widget.ica;

    nomContaminants = widget.contaminants.keys.toList();
    contaminants = widget.contaminants.values.toList();

    ciutatsICA = widget.suggestedplaces.keys.toList();
    valorsCiutatsICA = widget.suggestedplaces.values.toList();

    //var localizations = AppLocalizations.of(context)!; 
    //String health = localizations.healthRecomm;

    llistaCaixes = [
      //Caixa Estat actual
      _buildQualitatAct(screenHeight, screenWidth),
      //Caixa Contaminants
      _buildContaminants(screenWidth),
      //Caixa Recomanacions
      _buildRecomanacions(screenWidth),
      //Caixa Llocs de suggeriment
      _buildSuggeriments(screenWidth)
    ];
  
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _buildCustomScrollView(screenHeight, screenWidth)
    );
  }

}