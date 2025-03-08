class Score {
  final String playerName;
  final int timeInSeconds;
  final String difficulty;
  final DateTime date;

  Score({
    required this.playerName,
    required this.timeInSeconds,
    required this.difficulty,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'playerName': playerName,
        'timeInSeconds': timeInSeconds,
        'difficulty': difficulty,
        'date': date.toIso8601String(),
      };

  factory Score.fromJson(Map<String, dynamic> json) => Score(
        playerName: json['playerName'] as String,
        timeInSeconds: json['timeInSeconds'] as int,
        difficulty: json['difficulty'] as String,
        date: DateTime.parse(json['date'] as String),
      );
}
