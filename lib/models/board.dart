import 'dart:math';
import 'cell.dart';

class Board {
  final int rows;
  final int cols;
  final int mines;
  late List<List<Cell>> grid;
  bool isGameOver;
  bool isWon;

  Board({
    required this.rows,
    required this.cols,
    required this.mines,
  })  : isGameOver = false,
        isWon = false {
    _initializeBoard();
  }

  void _initializeBoard() {
    // Create empty grid
    grid = List.generate(
      rows,
      (row) => List.generate(
        cols,
        (col) => Cell(row: row, col: col),
      ),
    );

    // Place mines randomly
    final random = Random();
    int minesPlaced = 0;
    while (minesPlaced < mines) {
      final row = random.nextInt(rows);
      final col = random.nextInt(cols);
      if (!grid[row][col].isMine) {
        grid[row][col].isMine = true;
        minesPlaced++;
      }
    }

    // Calculate adjacent mines
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (!grid[row][col].isMine) {
          grid[row][col].adjacentMines = _countAdjacentMines(row, col);
        }
      }
    }
  }

  int _countAdjacentMines(int row, int col) {
    int count = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        final newRow = row + i;
        final newCol = col + j;
        if (newRow >= 0 && newRow < rows && newCol >= 0 && newCol < cols) {
          if (grid[newRow][newCol].isMine) {
            count++;
          }
        }
      }
    }
    return count;
  }

  void revealCell(int row, int col) {
    if (isGameOver || isWon) return;

    final cell = grid[row][col];
    if (cell.isFlagged || cell.isRevealed) return;

    cell.reveal();

    if (cell.isMine) {
      isGameOver = true;
      _revealAllMines();
      return;
    }

    if (cell.isEmpty) {
      _revealAdjacentCells(row, col);
    }

    _checkWin();
  }

  void _revealAdjacentCells(int row, int col) {
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        final newRow = row + i;
        final newCol = col + j;
        if (newRow >= 0 && newRow < rows && newCol >= 0 && newCol < cols) {
          revealCell(newRow, newCol);
        }
      }
    }
  }

  void _revealAllMines() {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (grid[row][col].isMine) {
          grid[row][col].reveal();
        }
      }
    }
  }

  void _checkWin() {
    bool allNonMinesRevealed = true;
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (!grid[row][col].isMine && !grid[row][col].isRevealed) {
          allNonMinesRevealed = false;
          break;
        }
      }
      if (!allNonMinesRevealed) break;
    }
    isWon = allNonMinesRevealed;
  }

  void toggleFlag(int row, int col) {
    if (isGameOver || isWon) return;
    grid[row][col].toggleFlag();
  }
}
