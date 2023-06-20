import 'dart:math';

import 'quiz_page.dart';

class QuizHelper {
  static List<T> shuffle<T>(List<T> items) {
    var random = Random();
    for (var i = items.length - 1; i > 0; i--) {
      var j = random.nextInt(i + 1);
      var temp = items[i];
      items[i] = items[j];
      items[j] = temp;
    }
    return items;
  }

  static List<Question> shuffleQuestions(List<Question> questions) {
    for (var i = 0; i < questions.length; i++) {
      var options = questions[i].options;
      shuffle<Option>(options);
    }
    return shuffle<Question>(questions);
  }
}
