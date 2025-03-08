import 'package:flutter/material.dart';
import '../models/cell.dart';

class CellWidget extends StatelessWidget {
  final Cell cell;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CellWidget({
    Key? key,
    required this.cell,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: _getCellColor(),
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Center(
          child: _getCellContent(),
        ),
      ),
    );
  }

  Color _getCellColor() {
    if (!cell.isRevealed) {
      return Colors.grey[300]!;
    }
    if (cell.isMine) {
      return Colors.red[100]!;
    }
    return Colors.white;
  }

  Widget _getCellContent() {
    if (!cell.isRevealed) {
      if (cell.isFlagged) {
        return const Icon(Icons.flag, color: Colors.red, size: 20);
      }
      return const SizedBox.shrink();
    }

    if (cell.isMine) {
      return const Icon(Icons.brightness_7, color: Colors.red, size: 20);
    }

    if (cell.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      cell.adjacentMines.toString(),
      style: TextStyle(
        color: _getNumberColor(),
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Color _getNumberColor() {
    switch (cell.adjacentMines) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.orange;
      case 6:
        return Colors.teal;
      case 7:
        return Colors.black;
      case 8:
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}
