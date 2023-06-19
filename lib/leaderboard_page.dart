import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

class LeaderboardPage extends StatelessWidget {
  late final List<PlayerScore> scores = [PlayerScore(playerName: "a", score: 0)];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
      ),
      body: ListView.builder(
        itemCount: scores.length,
        itemBuilder: (context, index) {
          final playerScore = scores[index];
          return ListTile(
            title: Text(playerScore.playerName),
            subtitle: Text('Score: ${playerScore.score}'),
          );
        },
      ),
    );
  }
}

class PlayerScore {
  final String playerName;
  final int score;

  PlayerScore({required this.playerName, required this.score});
}

class Leaderboard {
  List<LeaderboardEntry> leaderboardData = [];
  final String leaderboardFilePath;

  Leaderboard(this.leaderboardFilePath) {
    leaderboardData = [];
    loadLeaderboardData();
  }

  // Method to load leaderboard data from the JSON file
  void loadLeaderboardData() {
    try {
      File file = File(leaderboardFilePath);
      if (file.existsSync()) {
        String fileContent = file.readAsStringSync();
        if (fileContent.isNotEmpty) {
          leaderboardData = List<LeaderboardEntry>.from(jsonDecode(fileContent));
        }
      }
    } catch (e) {
      print('Error loading leaderboard data: $e');
    }
  }

  // Method to save leaderboard data to the JSON file
  void saveLeaderboardData() {
    try {
      File file = File(leaderboardFilePath);
      String fileContent = jsonEncode(leaderboardData);
      file.writeAsStringSync(fileContent);
    } catch (e) {
      print('Error saving leaderboard data: $e');
    }
  }

  // Method to add a new entry to the leaderboard
  void addEntry(String playerName, int playerScore) {
    LeaderboardEntry entry = LeaderboardEntry(name: playerName, score: playerScore);
    leaderboardData.add(entry);
    leaderboardData.sort((a, b) => b.score.compareTo(a.score));
    if (leaderboardData.length > 5) {
      leaderboardData = leaderboardData.sublist(0, 5);
    }
    saveLeaderboardData();
  }

  // Method to display the leaderboard
  void displayLeaderboard() {
    for (int i = 0; i < leaderboardData.length; i++) {
      LeaderboardEntry entry = leaderboardData[i];
      print('${i + 1}. ${entry.name}: ${entry.score}');
    }
  }
}

class LeaderboardEntry {
  final String name;
  final int score;

  LeaderboardEntry({required this.name, required this.score});
}

