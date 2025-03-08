class Cell {
  final int row;
  final int col;
  bool isMine;
  bool isRevealed;
  bool isFlagged;
  int adjacentMines;

  Cell({
    required this.row,
    required this.col,
    this.isMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.adjacentMines = 0,
  });

  void reveal() {
    isRevealed = true;
  }

  void toggleFlag() {
    if (!isRevealed) {
      isFlagged = !isFlagged;
    }
  }

  bool get isEmpty => !isMine && adjacentMines == 0;
  bool get isNumber => !isMine && adjacentMines > 0;
} 