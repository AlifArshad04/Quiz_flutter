import 'package:flutter/material.dart';
import 'package:flutter_quiz/home_page.dart';
import 'package:flutter_quiz/leaderboard_page.dart';
import 'package:flutter_quiz/quiz_page.dart';
import 'package:flutter_quiz/result_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(
      ChangeNotifierProvider(
          create: (_) => QuizProvider(),
          child: Flutter_Quiz(),)
  );
}

class Flutter_Quiz extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_quiz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/quiz': (context) => QuizPage(),
        '/result': (context) => ResultPage(),
        '/leaderboard': (context) => LeaderboardPage()
      },
    );
  }
}

class QuizProvider with ChangeNotifier {
  int correctAnswers = 0;

  void incrementCorrectAnswers() {
    correctAnswers++;
    notifyListeners();
  }
}