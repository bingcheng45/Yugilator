import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

void main() {
  runApp(Calculator());
}

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
  String mp3Uri;

  @override
  void initState() {
    _load();
  }

  Future<Null> _load() async {
    final ByteData data =
        await rootBundle.load('assets/LifePointSoundEffect.mp3');
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/LifePointSoundEffect.mp3');
    await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    mp3Uri = tempFile.uri.toString();
    print('finished loading, uri=$mp3Uri');
  }

  void _playSound() {
    if (mp3Uri != null) {
      audioPlugin.play(mp3Uri, isLocal: true);
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
        // equationFontSize = 38.0;
        // resultFontSize = 48.0;
      } else if (buttonText == "⌫") {
        // equationFontSize = 48.0;
        // resultFontSize = 38.0;
        equation = equation.substring(0, equation.length - 1);
        if (equation == '') {
          equation = '0';
        }
      } else if (buttonText == "=") {
        // equationFontSize = 38.0;
        // resultFontSize = 48.0;

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
            _playSound();
          } else if (int.parse(player2Health) <= 0) {
            _showWinner('1');
            _playSound();
          }
        } catch (e) {
          result = 'Error';
          //result = e.toString(); //for debugging
        }
      } else {
        // equationFontSize = 48.0;
        // resultFontSize = 38.0;
        if (equation == "0") {
          equation = buttonText;
        } else {
          equation = equation + buttonText;
        }
      }
    });
  }

  void _ShowPopUp(String title, Widget content) {
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
    _ShowPopUp(
      'Coin Toss!',
      Text('It is $content'),
    );
  }

  void _rollDie() {
    var rng = Random();
    double iconSize = 50;
    Icon dieIcon;
    if (rng.nextInt(6) == 0) {
      dieIcon = Icon(
        Icons.looks_one,
        size: iconSize,
      );
    } else if (rng.nextInt(6) == 1) {
      dieIcon = Icon(
        Icons.looks_two,
        size: iconSize,
      );
    } else if (rng.nextInt(6) == 2) {
      dieIcon = Icon(
        Icons.looks_3,
        size: iconSize,
      );
    } else if (rng.nextInt(6) == 3) {
      dieIcon = Icon(
        Icons.looks_4,
        size: iconSize,
      );
    } else if (rng.nextInt(6) == 4) {
      dieIcon = Icon(
        Icons.looks_5,
        size: iconSize,
      );
    } else if (rng.nextInt(6) == 5) {
      dieIcon = Icon(
        Icons.looks_6,
        size: iconSize,
      );
    }
    _ShowPopUp(
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
      //width: MediaQuery.of(context).size.width,
      // height: MediaQuery.of(context).size.height,
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            healthPoints,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
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
        child: Text(
          buttonText,
          style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.normal,
              color: Colors.white),
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
                _rollDie();
              },
              child: Icon(
                Icons.looks_6,
              ),
            ),
          ),
        ],
      ),
      body: Column(children: <Widget>[
        // Container(
        //   alignment: Alignment.centerRight,
        //   padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
        //   child: Text(
        //     result,
        //     style: TextStyle(fontSize: resultFontSize),
        //   ),
        // ),
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
