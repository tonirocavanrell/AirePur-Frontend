import 'package:flutter/material.dart';
import 'package:frontend/providers/locale_translationProvider.dart';
import 'package:frontend/screens/plant/assignar_comunitat_dialog.dart';
import 'package:frontend/screens/plant/map_plant/map_plant_screen.dart';
import 'package:frontend/utils/load_data.dart';
import 'package:frontend/utils/s3_image_loader.dart';
import 'package:frontend/widgets/quiz_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlantScreen extends StatefulWidget {

  final LoadData ld;
  final LatLng? mypos;

  const PlantScreen({super.key, required this.ld, required this.mypos});

  @override
  State<PlantScreen> createState() => PlantScreenState();
}

class PlantScreenState extends State<PlantScreen> {
  
  bool acabat = false;
  bool codiEstacioIsNull = false;
  double curvaturaWidgets = 18.0;
  double paddingCaixes = 15.0;
  List<double> marginFirstWidget = [15, 15, 15, 10];
  List<double> marginNextWidgets = [15, 0, 15, 10];

  List<Widget> llistaCaixes = [];

  int level = 1;
  int puntuacioAlNivell = 0;
  int puntuacioNivell = 15;
  List<int> userAchivements = [];

  late LatLng? mypos;

  String ip = "";

  late LoadData ld;

  void showQuiz(double screenHeight, double screenWidth) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: const Color.fromARGB(255, 77, 146, 86),
            title: Text(
              TranslationService().translate('dailyEcoQuiz'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color.fromRGBO(29, 79, 35, 1),
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            content: FutureBuilder(
              future: ld.getPreguntes(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  // Aquí se construye el contenido del AlertDialog
                  return SizedBox(
                    height: screenHeight * 0.55,
                    child: QuizScreen(ld: ld),
                  );
                }
              },
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(curvaturaWidgets),
              side: const BorderSide(color: Colors.black87, width: 2),
            ),
            elevation: 8,
          ),
        );
      },
    );
  }

  Widget _buildXPBar(double screenWidth, double screenHeight) {

    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(25, 5, 25, 0),
            width: screenWidth,
            height: 25,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 180, 231, 183),
              borderRadius: BorderRadius.circular(5),
            ),

            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  width: screenWidth * (puntuacioAlNivell/puntuacioNivell),
                  height: 25,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 75, 170, 79),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),

                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.info, size: 20, color: Colors.black54),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
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
                                    text: TranslationService().translate('improvePlant'),
                                  ),
                                ],
                              ),
                            ),

                            content: SizedBox(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                            text: TranslationService().translate('completeCorrectly'),
                                          ),
                                          const TextSpan(
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                              fontStyle: FontStyle.italic
                                            ),
                                            text: 'Daily EcoQuiz', //no traduïr
                                          ),
                                          const TextSpan(
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                            text: ' ( ', //no traduïr
                                          ),
                                          WidgetSpan(
                                            child: S3ImageLoader.loadImage('assets/quiz_icon.png', width: 20, height: 20),
                                          ),
                                          TextSpan(
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                            text: TranslationService().translate('toImopriveAndContribute'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 15),
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
                                  TranslationService().translate('close'),
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
                ),

                Center(
                  child: Text(
                    '$puntuacioAlNivell/$puntuacioNivell',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

  }

  Widget _buildMap(double screenWidth, double screenHeight, int codi) {
    
    IconButton municipiQuest;
    if (codi == 0) {
      municipiQuest = IconButton(
        iconSize: 35,
        color: Colors.black,
        onPressed: (){
          showDialog(
            context: context,
            builder: (BuildContext context) => AssignarComunitatDialog(ld: ld),
          );
        },
        icon: const Icon(Icons.location_city_rounded)
      );
    } else {
      municipiQuest = IconButton(
        icon: S3ImageLoader.loadImage('assets/quiz_icon.png', width: 30, height: 30),
        onPressed: () {
          showQuiz(screenHeight, screenWidth);
        },
      );
    }

    mypos = widget.ld.mypos;

    return Container (
      width: screenWidth,
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: S3ImageLoader.loadImage('assets/world_icon.png', width: 30, height: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapScreenPlant(mypos: mypos, ld: ld)),
              );
            },
          ),
          municipiQuest
        ]
      ),
    );
  }

  Widget _buildPlant(double screenHeight, double screenWidth, int level) {

    return Column(
      children: [
        S3ImageLoader.loadImage(
          'assets/plant_level$level.png',
          height: screenHeight * 0.4,
        ),
      ]
    );
  }

  Container _buildAchievement(String title, String desc, double screenWidth, int unlocked) {
    
    Color col = Colors.black12;
    if (unlocked == 1) {
      col = Colors.green.shade200;
    } else {
      col = Colors.black12;
    }

    return Container(
      width: screenWidth,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: col,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(desc)
        ]
      ),
    );
  }

  
  Widget _buildRankAndAchivements(double screenWidth) {

    userAchivements = ld.achivements;
    if (userAchivements.isEmpty) userAchivements = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    return Container (
      width: screenWidth,
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: S3ImageLoader.loadImage('assets/trophy_icon.png', width: 35, height: 35),
            onPressed: () {
               _showRankingDialog(context);
            },
          ),
          IconButton(
            icon: S3ImageLoader.loadImage('assets/badge_icon.png', width: 35, height: 35),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      TranslationService().translate('achievements'),
                      textAlign: TextAlign.left,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Reemplaza con el valor que desees
                      side: const BorderSide(color: Colors.black87, width: 3), // Añade un borde
                    ),
                    elevation: 8,
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAchievement(TranslationService().translate('novel'), TranslationService().translate('level2Arrived'), screenWidth, userAchivements[8]),
                          _buildAchievement(TranslationService().translate('principiant'), TranslationService().translate('level3Arrived'), screenWidth, userAchivements[1]),
                          _buildAchievement(TranslationService().translate('aprenent'), TranslationService().translate('level4Arrived'), screenWidth, userAchivements[2]),
                          _buildAchievement(TranslationService().translate('aficionat'), TranslationService().translate('level5Arrived'), screenWidth, userAchivements[0]),
                          _buildAchievement(TranslationService().translate('experimentat'), TranslationService().translate('level6Arrived'), screenWidth, userAchivements[4]),
                          _buildAchievement(TranslationService().translate('destacat'), TranslationService().translate('level7Arrived'), screenWidth, userAchivements[5]),
                          _buildAchievement(TranslationService().translate('expert'), TranslationService().translate('level8Arrived'), screenWidth, userAchivements[6]),
                          _buildAchievement(TranslationService().translate('mestre'), TranslationService().translate('level9Arrived'), screenWidth, userAchivements[7]),
                          _buildAchievement(TranslationService().translate('llegenda'), TranslationService().translate('level10Arrived'), screenWidth, userAchivements[3]),

                          _buildAchievement(TranslationService().translate('2seguits'), TranslationService().translate('answerQuiz2daysseguits'), screenWidth, userAchivements[14]),
                          _buildAchievement(TranslationService().translate('3seguits'), TranslationService().translate('answerQuiz3daysseguits'), screenWidth, userAchivements[15]),
                          _buildAchievement(TranslationService().translate('4seguits'), TranslationService().translate('answerQuiz4daysseguits'), screenWidth, userAchivements[16]),
                          _buildAchievement(TranslationService().translate('5seguits'), TranslationService().translate('answerQuiz5daysseguits'), screenWidth, userAchivements[17]),
                          _buildAchievement(TranslationService().translate('6seguits'), TranslationService().translate('answerQuiz6daysseguits'), screenWidth, userAchivements[18]),
                          _buildAchievement(TranslationService().translate('7seguits'), TranslationService().translate('answerQuiz7daysseguits'), screenWidth, userAchivements[19]),
                          _buildAchievement(TranslationService().translate('8seguits'), TranslationService().translate('answerQuiz8daysseguits'), screenWidth, userAchivements[20]),
                          _buildAchievement(TranslationService().translate('9seguits'), TranslationService().translate('answerQuiz9daysseguits'), screenWidth, userAchivements[21]),
                          _buildAchievement(TranslationService().translate('10seguits'), TranslationService().translate('answerQuiz10daysseguits'), screenWidth, userAchivements[9]),
                          _buildAchievement(TranslationService().translate('30seguits'), TranslationService().translate('answerQuiz30daysseguits'), screenWidth, userAchivements[10]),
                          _buildAchievement(TranslationService().translate('50seguits'), TranslationService().translate('answerQuiz50daysseguits'), screenWidth, userAchivements[11]),
                          _buildAchievement(TranslationService().translate('100seguits'), TranslationService().translate('answerQuiz100daysseguits'), screenWidth, userAchivements[12]),
                          _buildAchievement(TranslationService().translate('200seguits'), TranslationService().translate('answerQuiz200daysseguits'), screenWidth, userAchivements[13]),
                          _buildAchievement(TranslationService().translate('365seguits'), TranslationService().translate('answerQuiz365daysseguits'), screenWidth, userAchivements[22])
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Cierra el AlertDialog
                        },
                        child: Text(TranslationService().translate('close')),
                      )
                    ],
                  );
                },
              );
            },
          ),
        ]
      ),
    );
  }

   //Ranking
  
  Future<void> _showRankingDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder(
          future: Future.wait([ld.fetchRankings(), ld.sendRankingUsuaris()]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const AlertDialog(
                content: SizedBox(
                  width: 50,
                  height: 50,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: Text(TranslationService().translate('error')),
                content: Text(TranslationService().translate('errorRankings')),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              );
            } else {
              return DefaultTabController(
                length: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: AlertDialog(
                    titlePadding: const EdgeInsets.all(0),
                    title: Container(
                      color: const Color.fromARGB(255, 38, 134, 41),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            child: const Text(
                              'Ranking',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          TabBar(
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.black,
                            tabs: [
                              Tab(text: TranslationService().translate('rankingUsuaris')),
                              Tab(text: TranslationService().translate('rankingComunitats')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    content: SizedBox(
                      width: double.maxFinite,
                      height: 400,
                      child: Column(
                        children: [
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildRankingU(ld.rankingsUsers, ld.usernameLabel),
                                _buildRankingC(ld.rankingsCommunity, ld.userComunitat),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(TranslationService().translate('TancaRanking')),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }


  Widget _buildRankingC(List<Map<String, dynamic>> rankings, String municipi) {
    return ListView.builder(
      itemCount: rankings.length,
      itemBuilder: (context, index) {
        final isComunityUser = rankings[index]['municipi'] == municipi;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: isComunityUser ? const Color.fromARGB(255, 180, 231, 183) : Colors.white, 
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: ListTile(
            title: Text(rankings[index]['municipi']),
            trailing: Text(rankings[index]['puntuacion'].toString()),
          ),
        );
      },
    );
  }


  Widget _buildRankingU(List<Map<String, dynamic>> rankings, String nomUser) {
    return ListView.builder(
      itemCount: rankings.length,
      itemBuilder: (context, index) {
        final isCurrentUser = rankings[index]['username'] == nomUser;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: isCurrentUser ? const Color.fromARGB(255, 180, 231, 183) : Colors.white, // Verde si es el usuario actual
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: ListTile(
            title: Text('${rankings[index]['posicion']}. ${rankings[index]['username']}'),
            trailing: Text(rankings[index]['puntuacionTotal'].toString()),
          ),
        );
      },
    );
  }


  


  Widget _buildCustomContainer(double screenHeight, double screenWidth) {
    
    double ciutatFontSize = 45;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: S3ImageLoader.loadImageAsImageProvider('assets/background_plant_image.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),

        Column(
          children: <Widget>[
            const SizedBox(height: 90),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: ciutatFontSize,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: "${TranslationService().translate('level')}: ",
                        style: TextStyle(
                          fontSize: ciutatFontSize,
                        ),
                      ),
                      TextSpan(
                        text: '$level',
                        style: TextStyle(
                          fontSize: ciutatFontSize+15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              ]
            ),

            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: llistaCaixes,
            ),
          ],
        ),
      ]
    );
  }
  
  @override
  Widget build(BuildContext context) {
    
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    ld = widget.ld;
    ip = ld.ip;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder(
        future: ld.getPlanta(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Container(
                color: const Color.fromARGB(255, 230, 255, 234),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          } else if (ld.userCodi == "0") {
            level = ld.nivell;
            puntuacioAlNivell = ld.puntuacioAlNivell;
            puntuacioNivell = ld.puntuacioNivell;

            llistaCaixes = [
              //Caixa botons ranking i achivements
              _buildRankAndAchivements(screenWidth),
              //Caixa imatge planta
              _buildPlant(screenHeight, screenWidth, level),
              //Caixa boto map
              _buildMap(screenWidth, screenHeight, 0),
              //Caixa XP
              _buildXPBar(screenWidth, screenHeight),
              //caixa quiz
            ];

            return _buildCustomContainer(screenHeight, screenWidth);
          } else {
            level = ld.nivell;
            puntuacioAlNivell = ld.puntuacioAlNivell;
            puntuacioNivell = ld.puntuacioNivell;

            llistaCaixes = [
              //Caixa botons ranking i achivements
              _buildRankAndAchivements(screenWidth),
              //Caixa imatge planta
              _buildPlant(screenHeight, screenWidth, level),
              //Caixa boto map
              _buildMap(screenWidth, screenHeight, 1),
              //Caixa XP
              _buildXPBar(screenWidth, screenHeight),
              //caixa quiz
            ];
            
            return _buildCustomContainer(screenHeight, screenWidth);
          }
        },
      ),
    );
  }
  
}