import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

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
          player1Health = result;
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
            style: TextStyle(fontSize: 52, fontWeight: FontWeight.bold),
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
        title: Text('SimpleCalculator'),
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
                child: buildPlayerBox(
                  'Player 1',
                  Colors.lightBlueAccent[700],
                  player1Health,
                ),
              ),
              Expanded(
                flex: 1,
                child: buildPlayerBox(
                  'Player 2',
                  Colors.pinkAccent[100],
                  player2Health,
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
