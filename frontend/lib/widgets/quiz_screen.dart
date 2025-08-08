import 'package:flutter/foundation.dart';
import  'package:flutter/material.dart';
import 'package:frontend/providers/locale_translationProvider.dart';
import 'package:frontend/utils/load_data.dart';
import 'package:frontend/widgets/navigation_bar.dart';
import 'package:intl/intl.dart';

class QuizScreen  extends StatefulWidget {

  final LoadData ld;

  const QuizScreen({super.key, required this.ld});

  @override
  State<QuizScreen> createState() => QuizState();
}

class QuizState extends State<QuizScreen> {

  int totalQuestions = 3;
  int totalOptions = 4;

  String ip = "";

  late LoadData ld;

  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  late List<Map<String, dynamic>> questionsMap;

  bool isLoading = false;


  Widget buildResult(BuildContext context) {

    return FutureBuilder(
      future: ld.updatePlant(correctAnswers * 5),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AlertDialog(
            content: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return AlertDialog(
            title: Text(TranslationService().translate('results')),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Colors.black87, width: 3),
            ),
            content: SizedBox(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${TranslationService().translate('correctQuestions')}: $correctAnswers'),
                    Text('${TranslationService().translate('incorrectQuestions')}: ${totalQuestions - correctAnswers}'),
                    Text('${TranslationService().translate('punctuation')}: ${correctAnswers * 5}'), //Prova
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyNavigationBar(ld: ld, actual: 3)));
                },
                child: Text(TranslationService().translate('close')),
              )
            ],
          );
        }
      },
    );
  }

  Future<void> answerQuestion(int selectedAnswerIndex) async {
    setState(() {
      isLoading = true;
    });

    try {
      bool resultado = await ld.esRespostaCorrecta(questionsMap[currentQuestionIndex]['nump'], selectedAnswerIndex);
      
      if (resultado) {
        setState(() {
          correctAnswers++;
        });
      }

      if (currentQuestionIndex < totalQuestions - 1) {
        setState(() {
          currentQuestionIndex++;
        });
      } else {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return buildResult(context);
          },
        );
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error al obtener la respuesta: $error");
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
 
  Widget _buildCustomScrollView(double screenWidth, double screenHeight) {
    
    DateTime now = DateTime.now();
    String today = DateFormat('yyyy-MM-dd').format(now);

    if (ld.lastAnswer == "never" || ld.lastAnswer != today) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: screenWidth,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 2.0,
                  ),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18)),
              child: Text(
                questionsMap[currentQuestionIndex]['question'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),
            Column(
              children: List.generate(
                4,
                (index) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () {
                        answerQuestion(index);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        questionsMap[currentQuestionIndex]['answers'][index],
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                color: Colors.black,
                width: 2.0,
              ),
              color: Colors.white,
              borderRadius: BorderRadius.circular(18)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: LinearProgressIndicator(
                  color: Colors.blue,
                  value: currentQuestionIndex / totalQuestions,
                  minHeight: 10,
                )),
            )
          ],
        ),
      );
    }

    return AlertDialog(
      title: SizedBox(
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, 
          children: [
            Text(
              textAlign: TextAlign.center,
              TranslationService().translate('DialyEcoQuizDone'),
              style: const TextStyle(
                fontSize: 14, 
                color: Color.fromRGBO(29, 79, 35, 1), 
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cerrar el AlertDialog
          },
          child: Text(
            TranslationService().translate('close'),
            style: const TextStyle(
              fontSize: 14, 
              color: Color.fromRGBO(29, 79, 35, 1), 
            ),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: Color.fromRGBO(29, 79, 35, 1), 
          width: 2
        ),
      ),
    );
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    ld = widget.ld;
    ip = ld.ip;
    questionsMap = ld.questionsMap;
  
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _buildCustomScrollView(screenWidth, screenHeight)
    );
  }
}