import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/board.dart';
import '../models/score.dart';
import '../services/score_service.dart';
import '../widgets/cell_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Board board;
  static const int rows = 9;
  static const int cols = 9;
  static const int mines = 10;
  late int remainingFlags;
  String difficulty = 'Beginner';
  int elapsedSeconds = 0;
  Timer? gameTimer;
  final ScoreService _scoreService = ScoreService();
  bool isFirstMove = true;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedSeconds++;
      });
    });
  }

  void _stopTimer() {
    gameTimer?.cancel();
    gameTimer = null;
  }

  void _initializeGame() {
    setState(() {
      board = Board(rows: rows, cols: cols, mines: mines);
      remainingFlags = mines;
      elapsedSeconds = 0;
      isFirstMove = true;
    });
    _stopTimer();
  }

  void _changeDifficulty(String? newDifficulty) {
    if (newDifficulty == null) return;
    setState(() {
      difficulty = newDifficulty;
      switch (newDifficulty) {
        case 'Beginner':
          board = Board(rows: 9, cols: 9, mines: 10);
          remainingFlags = 10;
          break;
        case 'Intermediate':
          board = Board(rows: 16, cols: 16, mines: 40);
          remainingFlags = 40;
          break;
        case 'Expert':
          board = Board(rows: 16, cols: 30, mines: 99);
          remainingFlags = 99;
          break;
      }
      elapsedSeconds = 0;
      isFirstMove = true;
    });
    _stopTimer();
  }

  void _showHighScores() async {
    final scores = await _scoreService.getHighScores(difficulty);
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('High Scores - $difficulty'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: scores.length,
              itemBuilder: (context, index) {
                final score = scores[index];
                return ListTile(
                  leading: Text('#${index + 1}'),
                  title: Text(score.playerName),
                  subtitle: Text(score.date.toString().split('.')[0]),
                  trailing: Text('${score.timeInSeconds}s'),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _checkForHighScore() async {
    if (await _scoreService.isHighScore(difficulty, elapsedSeconds)) {
      if (!mounted) return;

      final TextEditingController nameController = TextEditingController();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('New High Score!'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Enter your name',
              ),
              autofocus: true,
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Submit'),
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    await _scoreService.addScore(Score(
                      playerName: name,
                      timeInSeconds: elapsedSeconds,
                      difficulty: difficulty,
                      date: DateTime.now(),
                    ));
                    if (!mounted) return;
                    Navigator.of(context).pop();
                    _showHighScores();
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _shareGame() async {
    await Share.share(
      'Check out this awesome Minesweeper game! Can you beat my score?',
      subject: 'Minesweeper Challenge',
    );
  }

  Future<void> _rateApp() async {
    // For demo purposes, we'll use a generic app store URL
    // In a real app, you would use your actual app store URLs
    final Uri url = Uri.parse('https://play.google.com/store/apps/details');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _showSocialMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Share & More'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share Game'),
                onTap: () {
                  Navigator.pop(context);
                  _shareGame();
                },
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Rate App'),
                onTap: () {
                  Navigator.pop(context);
                  _rateApp();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minesweeper'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.grid_3x3),
            tooltip: 'Difficulty',
            onSelected: _changeDifficulty,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Beginner',
                child: Text('Beginner (9x9, 10 mines)'),
              ),
              const PopupMenuItem<String>(
                value: 'Intermediate',
                child: Text('Intermediate (16x16, 40 mines)'),
              ),
              const PopupMenuItem<String>(
                value: 'Expert',
                child: Text('Expert (16x30, 99 mines)'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'New Game',
            onPressed: _initializeGame,
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events),
            tooltip: 'High Scores',
            onPressed: _showHighScores,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share & More',
            onPressed: _showSocialMenu,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('How to Play'),
                    content: const SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text('• Left click or tap to reveal a cell'),
                          Text(
                              '• Right click (two-finger click) or long-press to flag a potential mine'),
                          Text('• Numbers show adjacent mines'),
                          Text('• Flag all mines to win!'),
                          SizedBox(height: 16),
                          Text('Mac Controls:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('• Two-finger click = Right click'),
                          Text('• Press and hold = Alternative way to flag'),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusBar(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: AspectRatio(
                  aspectRatio: board.cols / board.rows,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: board.cols,
                      childAspectRatio: 1,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                    ),
                    itemCount: board.rows * board.cols,
                    itemBuilder: (context, index) {
                      final row = index ~/ board.cols;
                      final col = index % board.cols;
                      return CellWidget(
                        cell: board.grid[row][col],
                        onTap: () => _onCellTap(row, col),
                        onLongPress: () => _onCellLongPress(row, col),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_outlined, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                '$remainingFlags',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.timer_outlined),
              const SizedBox(width: 8),
              Text(
                '$elapsedSeconds',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (board.isGameOver)
            const Text(
              'Game Over!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            )
          else if (board.isWon)
            const Text(
              'You Won!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            Text(
              difficulty,
              style: const TextStyle(fontSize: 18),
            ),
        ],
      ),
    );
  }

  void _onCellTap(int row, int col) {
    if (isFirstMove) {
      isFirstMove = false;
      _startTimer();
    }

    setState(() {
      board.revealCell(row, col);
      if (board.isWon || board.isGameOver) {
        _stopTimer();
        if (board.isWon) {
          _checkForHighScore();
        }
      }
    });
  }

  void _onCellLongPress(int row, int col) {
    setState(() {
      if (!board.grid[row][col].isRevealed) {
        if (board.grid[row][col].isFlagged) {
          remainingFlags++;
        } else {
          remainingFlags--;
        }
        board.toggleFlag(row, col);
      }
    });
  }
}
