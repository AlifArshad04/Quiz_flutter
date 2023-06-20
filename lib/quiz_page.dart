import 'dart:async';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'shuffle_ques.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _remainingTime = 30;
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int correctAnswers = 0;
  bool _answeredCorrectly = false;
  bool _showAnswer = false;
  late Timer _timer;
  bool _timeUp = false;
  final int totalSeconds = 30; // Total seconds for the countdown
  double progressValue = 1.0; // Progress value for the progress bar

  @override
  void initState() {
    super.initState();
    loadQuizData();
    startTimer();
  }


  Future<void> loadQuizData() async {
    final String data = await DefaultAssetBundle.of(context as BuildContext).loadString('assets/quiz_data.json');
    final List<dynamic> jsonQuestions = json.decode(data);
    _questions = jsonQuestions.map((jsonQuestion) => Question.fromJson(jsonQuestion)).toList();
    setState(() {
      _questions = QuizHelper.shuffleQuestions(_questions);
    });
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    Timer.periodic(oneSec, (Timer timer) {
      if (_remainingTime == 0) {
        timer.cancel();
        // Handle end of the quiz
        // You can navigate to the result page or show a dialog
        // with the final score and review the answers
        Navigator.pushNamed(this.context, '/result');
      } else {
        setState(() {
          _remainingTime--;
          progressValue = _remainingTime / totalSeconds;
        });
      }
    });
  }

  void answerQuestion(bool isCorrect) {
    if (isCorrect) {
      _answeredCorrectly = true;
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      quizProvider.incrementCorrectAnswers();
    }
    _showAnswer = true;

    // Move to the next question after a delay
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _currentQuestionIndex++;
        _answeredCorrectly = false;
        _showAnswer = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    if (_timeUp) {
      return Center(
        child: Text(
          'Time is up!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Remaining Time: $_remainingTime',
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 10,),
            LinearProgressIndicator(
              value: progressValue,
              minHeight: 10,
              backgroundColor: Colors.orange[800],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 50),
            _questions.isNotEmpty
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1}:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  _questions[_currentQuestionIndex].questionText,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24),
                ),
                // SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  padding: EdgeInsets.all(16),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: List.generate(
                    _questions[_currentQuestionIndex].options.length,
                        (index) {
                      final option = _questions[_currentQuestionIndex].options[index];
                      return Container(
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: _showAnswer ? null : () {
                            answerQuestion(option.isCorrect);

                          },
                          child: Text(option.optionText),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                if (_showAnswer)
                  Text(
                    _answeredCorrectly ? 'Correct Answer!' : 'Incorrect Answer!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        color: _answeredCorrectly ? Colors.green : Colors.red
                    ),
                  ),
                if (_showAnswer && !_answeredCorrectly)
                  Text(
                    'Correct answer is: ${_questions[_currentQuestionIndex].options.firstWhere((option) => option.isCorrect).optionText}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        // color: _answeredCorrectly ? Colors.green : Colors.red
                    ),
                  ),
              ],
            )
                : CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}


class Question {
  final String questionText;
  final List<Option> options;

  Question({
    required this.questionText,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final List<dynamic> jsonOptions = json['options'];
    final options = jsonOptions.map((jsonOption) => Option.fromJson(jsonOption)).toList();

    return Question(
      questionText: json['questionText'],
      options: options,
    );
  }
}

class Option {
  final String optionText;
  final bool isCorrect;

  Option({
    required this.optionText,
    required this.isCorrect,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      optionText: json['optionText'],
      isCorrect: json['isCorrect'],
    );
  }
}
