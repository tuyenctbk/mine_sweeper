import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/score.dart';

class ScoreService {
  static const String _key = 'high_scores';
  static const int _maxScoresPerDifficulty = 5;

  Future<List<Score>> getHighScores(String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    final String? scoresJson = prefs.getString(_key);
    if (scoresJson == null) return [];

    final List<dynamic> scoresList = json.decode(scoresJson);
    final scores = scoresList
        .map((json) => Score.fromJson(json))
        .where((score) => score.difficulty == difficulty)
        .toList();

    scores.sort((a, b) => a.timeInSeconds.compareTo(b.timeInSeconds));
    return scores;
  }

  Future<void> addScore(Score newScore) async {
    final prefs = await SharedPreferences.getInstance();
    final String? scoresJson = prefs.getString(_key);

    List<Score> allScores = [];
    if (scoresJson != null) {
      final List<dynamic> scoresList = json.decode(scoresJson);
      allScores = scoresList.map((json) => Score.fromJson(json)).toList();
    }

    // Add new score
    allScores.add(newScore);

    // Filter scores by difficulty and sort by time
    final Map<String, List<Score>> scoresByDifficulty = {};
    for (final score in allScores) {
      scoresByDifficulty[score.difficulty] ??= [];
      scoresByDifficulty[score.difficulty]!.add(score);
    }

    // Keep only top scores for each difficulty
    final List<Score> topScores = [];
    for (final scores in scoresByDifficulty.values) {
      scores.sort((a, b) => a.timeInSeconds.compareTo(b.timeInSeconds));
      topScores.addAll(scores.take(_maxScoresPerDifficulty));
    }

    // Save updated scores
    await prefs.setString(
        _key,
        json.encode(
          topScores.map((score) => score.toJson()).toList(),
        ));
  }

  Future<bool> isHighScore(String difficulty, int timeInSeconds) async {
    final scores = await getHighScores(difficulty);
    if (scores.length < _maxScoresPerDifficulty) return true;
    return timeInSeconds < scores.last.timeInSeconds;
  }
}
