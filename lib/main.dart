import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

//run flutter Application
void main() {
  runApp(Calculator());
}

//Main application front page
class Calculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SimpleCalculator(),
    );
  }
}

//stateful widget that we are doing all the stuff on
class SimpleCalculator extends StatefulWidget {
  @override
  _SimpleCalculatorState createState() => _SimpleCalculatorState();
}

class _SimpleCalculatorState extends State<SimpleCalculator> {
  String equation = '0';
  String result = '0';
  String player1Health = '8000';
  String player2Health = '8000';
  String expression = '';
  double equationFontSize = 38.0;
  double resultFontSize = 48.0;
  int playerSelected = 0;
  AudioPlayer audioPlugin = AudioPlayer();
  String hpSound;
  String coinSound;
  String diceSound;

  //load the sound effects.
  @override
  void initState() {
    _load('LifePointSoundEffect.mp3', 'hpSound');
    _load('CoinFlip.mp3', 'coinSound');
    _load('DiceRoll.mp3', 'diceSound');
  }

  Future<Null> _load(String filename, String soundType) async {
    final ByteData data = await rootBundle.load('assets/$filename');
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/$filename');
    await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);

    if (soundType == 'hpSound') {
      hpSound = tempFile.uri.toString();
    } else if (soundType == 'coinSound') {
      coinSound = tempFile.uri.toString();
    } else if (soundType == 'diceSound') {
      diceSound = tempFile.uri.toString();
    }
  }

  void _playSound(String soundName) {
    if (hpSound != null && soundName == 'hpSound') {
      audioPlugin.play(hpSound, isLocal: true);
    } else if (coinSound != null && soundName == 'coinSound') {
      audioPlugin.play(coinSound, isLocal: true);
    } else if (diceSound != null && soundName == 'diceSound') {
      audioPlugin.play(diceSound, isLocal: true);
    }
  }

  void restartGame() {
    setState(() {
      equation = '0';
      result = '0';
      player1Health = '8000';
      player2Health = '8000';
      expression = '';
      equationFontSize = 38.0;
      resultFontSize = 48.0;
      playerSelected = 0;
    });
  }

  buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        equation = '0';
        result = '0';
      } else if (buttonText == "⌫") {
        equation = equation.substring(0, equation.length - 1);
        if (equation == '') {
          equation = '0';
        }
      } else if (buttonText == "=") {
        expression = equation;
        expression = expression.replaceAll('×', '*');
        expression = expression.replaceAll('÷', '/');
        try {
          Parser p = new Parser();
          Expression exp = p.parse(expression);

          ContextModel cm = ContextModel();

          result = '${exp.evaluate(EvaluationType.REAL, cm).toInt()}';
          equation = '0';
          if (playerSelected != 0) {
            if (playerSelected == 1) {
              player1Health = result;
            } else if (playerSelected == 2) {
              player2Health = result;
            }
          }
          if (int.parse(player1Health) <= 0) {
            _showWinner('2');
            _playSound('hpSound');
          } else if (int.parse(player2Health) <= 0) {
            _showWinner('1');
            _playSound('hpSound');
          }
        } catch (e) {
          result = 'Error';
          //result = e.toString(); //for debugging
        }
      } else {
        if (equation == "0") {
          equation = buttonText;
        } else {
          equation = equation + buttonText;
        }
      }
    });
  }

  void _showPopUp(String title, Widget content) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: content,
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _coinToss() {
    var rng = Random();
    String content = '';
    if (rng.nextInt(2) == 0) {
      content = 'heads';
    } else {
      content = 'tails';
    }
    //print(rng.nextInt(2).toString());
    _showPopUp(
      'Coin Toss!',
      Text('It is $content'),
    );
  }

  void _rollDie() {
    var rng = Random();
    double iconSize = 50;
    Icon dieIcon;
    int random = rng.nextInt(6);
    if (random == 0) {
      dieIcon = Icon(
        Icons.looks_one,
        size: iconSize,
      );
    } else if (random == 1) {
      dieIcon = Icon(
        Icons.looks_two,
        size: iconSize,
      );
    } else if (random == 2) {
      dieIcon = Icon(
        Icons.looks_3,
        size: iconSize,
      );
    } else if (random == 3) {
      dieIcon = Icon(
        Icons.looks_4,
        size: iconSize,
      );
    } else if (random == 4) {
      dieIcon = Icon(
        Icons.looks_5,
        size: iconSize,
      );
    } else if (random == 5) {
      dieIcon = Icon(
        Icons.looks_6,
        size: iconSize,
      );
    }
    _showPopUp(
      'Roll a die!',
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('You have rolled a '),
          dieIcon,
        ],
      ),
    );
  }

  void _showWinner(String winnerName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Player $winnerName Win!'),
          content: Text('Thank you for using my Application. :)'),
          actions: <Widget>[
            FlatButton(
              child: Text('Play Again'),
              onPressed: () {
                restartGame();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildPlayerBox(String name, Color color, String healthPoints) {
    return Container(
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FittedBox(
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          FittedBox(
            child: Text(
              healthPoints,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(String buttonText, double buttonWidth, double buttonHeight,
      Color buttonColor) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.1 * buttonWidth,
      height: MediaQuery.of(context).size.height * 0.1 * buttonHeight,
      color: buttonColor,
      child: FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.0),
          side: BorderSide(
              color: Colors.white, width: 1, style: BorderStyle.solid),
        ),
        padding: EdgeInsets.all(16.0),
        onPressed: () => buttonPressed(buttonText),
        child: FittedBox(
          child: Text(
            buttonText,
            style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.normal,
                color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Yugilator'),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                _playSound('coinSound');
                _coinToss();
              },
              child: Icon(
                Icons.fiber_smart_record,
                color: Colors.yellow,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                _playSound('diceSound');
                _rollDie();
              },
              child: Icon(
                Icons.casino,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                _playSound('hpSound');
                restartGame();
              },
              child: Icon(
                Icons.refresh,
              ),
            ),
          ),
        ],
      ),
      body: Column(children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      equation = player1Health;
                      playerSelected = 1;
                    });
                  },
                  child: buildPlayerBox(
                    'Player 1',
                    Colors.lightBlueAccent[700],
                    player1Health,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      equation = player2Health;
                      playerSelected = 2;
                    });
                  },
                  child: buildPlayerBox(
                    'Player 2',
                    Colors.pinkAccent[100],
                    player2Health,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
          child: Text(
            equation,
            style: TextStyle(fontSize: equationFontSize),
          ),
        ),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * .75,
              child: Table(children: [
                TableRow(children: [
                  buildButton('C', 1, 1, Colors.redAccent),
                  buildButton('×', 1, 1, Colors.blueAccent),
                  buildButton('÷', 1, 1, Colors.blueAccent),
                ]),
                TableRow(children: [
                  buildButton('7', 1, 1, Colors.black54),
                  buildButton('8', 1, 1, Colors.black54),
                  buildButton('9', 1, 1, Colors.black54),
                ]),
                TableRow(children: [
                  buildButton('4', 1, 1, Colors.black54),
                  buildButton('5', 1, 1, Colors.black54),
                  buildButton('6', 1, 1, Colors.black54),
                ]),
                TableRow(children: [
                  buildButton('1', 1, 1, Colors.black54),
                  buildButton('2', 1, 1, Colors.black54),
                  buildButton('3', 1, 1, Colors.black54),
                ]),
                TableRow(children: [
                  buildButton('.', 1, 1, Colors.black54),
                  buildButton('0', 1, 1, Colors.black54),
                  buildButton('00', 2, 1, Colors.black54),
                ]),
              ]),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.25,
              child: Table(children: [
                TableRow(children: [
                  buildButton('⌫', 1, 1, Colors.blueAccent),
                ]),
                TableRow(children: [
                  buildButton('-', 1, 1, Colors.blueAccent),
                ]),
                TableRow(children: [
                  buildButton('+', 1, 1, Colors.blueAccent),
                ]),
                TableRow(children: [
                  buildButton('=', 1, 2, Colors.redAccent),
                ]),
              ]),
            )
          ],
        ),
      ]),
    );
  }
}
