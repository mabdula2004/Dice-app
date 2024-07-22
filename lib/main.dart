import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(DiceRollerApp());
}

class DiceRollerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dice Roller',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DiceRollerHomePage(),
    );
  }
}

class DiceRollerHomePage extends StatefulWidget {
  @override
  _DiceRollerHomePageState createState() => _DiceRollerHomePageState();
}

class _DiceRollerHomePageState extends State<DiceRollerHomePage> with SingleTickerProviderStateMixin {
  final Random _random = Random();
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  List<int> _diceValues = [1];
  List<Color> _diceColors = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);
    _diceColors.add(_getRandomColor()); // Initial color for the first dice
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _rollDice() {
    _controller.forward(from: 0).then((_) {
      setState(() {
        for (int i = 0; i < _diceValues.length; i++) {
          _diceValues[i] = _random.nextInt(6) + 1;
        }
      });
    });
  }

  void _addDice() {
    if (_diceValues.length < 9) {
      setState(() {
        _diceValues.add(1);
        _diceColors.add(_getUniqueRandomColor());
      });
    }
  }

  void _removeDice() {
    if (_diceValues.length > 1) {
      setState(() {
        _diceValues.removeLast();
        _diceColors.removeLast();
      });
    }
  }

  Color _getRandomColor() {
    return Color.fromARGB(
      255,
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
    );
  }

  Color _getUniqueRandomColor() {
    Color color;
    do {
      color = _getRandomColor();
    } while (_diceColors.contains(color));
    return color;
  }

  int _calculateTotal() {
    return _diceValues.reduce((a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dice Roller'),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            _rollDice();
          }
        },
        child: AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform(
              transform: Matrix4.rotationY(_rotationAnimation.value),
              alignment: Alignment.center,
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Total: ${_calculateTotal()}',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      _buildDiceLayout(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: _rollDice,
              child: Icon(Icons.casino),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                // Implement settings functionality here
              },
              child: Icon(Icons.settings),
            ),
          ),
          Positioned(
            bottom: 90,
            right: 20,
            child: FloatingActionButton(
              onPressed: _addDice,
              child: Icon(Icons.add),
            ),
          ),
          Positioned(
            bottom: 160,
            right: 20,
            child: FloatingActionButton(
              onPressed: _removeDice,
              child: Icon(Icons.remove),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiceLayout() {
    if (_diceValues.length <= 5) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _diceValues
            .asMap()
            .entries
            .map((entry) => Column(
          children: [
            DiceWidget(
              value: entry.value,
              color: _diceColors[entry.key],
              size: _calculateDiceSize(entry.key),
            ),
            if (entry.key != _diceValues.length - 1)
              Divider(
                color: Colors.black,
                thickness: 2,
                height: 20,
              ),
          ],
        ))
            .toList(),
      );
    } else {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 10.0,
        runSpacing: 10.0,
        children: _diceValues
            .asMap()
            .entries
            .map((entry) => DiceWidget(
          value: entry.value,
          color: _diceColors[entry.key],
          size: _calculateDiceSize(entry.key),
        ))
            .toList(),
      );
    }
  }

  double _calculateDiceSize(int index) {
    const double maxSize = 100.0;
    const double minSize = 40.0;
    const double sizeStep = (maxSize - minSize) / 8; // We have a maximum of 9 dice
    return maxSize - (sizeStep * index);
  }
}

class DiceWidget extends StatelessWidget {
  final int value;
  final Color color;
  final double size;

  DiceWidget({required this.value, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: _buildDiceFace(value),
      ),
    );
  }

  Widget _buildDiceFace(int value) {
    double dotSize = size / 8;
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      shrinkWrap: true,
      children: List.generate(9, (index) {
        return CircleAvatar(
          radius: dotSize,
          backgroundColor: _dotShouldBeVisible(value, index) ? Colors.black : Colors.transparent,
        );
      }),
    );
  }

  bool _dotShouldBeVisible(int value, int index) {
    const Map<int, List<int>> diceMap = {
      1: [4],
      2: [0, 8],
      3: [0, 4, 8],
      4: [0, 2, 6, 8],
      5: [0, 2, 4, 6, 8],
      6: [0, 2, 3, 5, 6, 8],
    };

    return diceMap[value]!.contains(index);
  }
}
