import 'dart:math';

import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:formz_submit_button/formz_submit_button.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: 'Rounded Loading Button Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FormzSubmissionStatus btn1Status = FormzSubmissionStatus.initial;
  FormzSubmissionStatus btn2Status = FormzSubmissionStatus.initial;

  void _doSomethingForBtn1() async {
    print("_doSomethingForBtn1");
    setState(() {
      btn1Status = FormzSubmissionStatus.inProgress;
    });
    await Future.delayed(const Duration(seconds: 10));
    if (Random.secure().nextBool()) {
      setState(() {
        btn1Status = FormzSubmissionStatus.success;
      });
    } else {
      setState(() {
        btn1Status = FormzSubmissionStatus.failure;
      });
    }
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      btn1Status = FormzSubmissionStatus.initial;
    });
  }

  void _doSomethingForBtn2() async {
    setState(() {
      btn2Status = FormzSubmissionStatus.inProgress;
    });
    await Future.delayed(const Duration(seconds: 5));
    if (Random.secure().nextBool()) {
      setState(() {
        btn2Status = FormzSubmissionStatus.success;
      });
    }
    setState(() {
      btn2Status = FormzSubmissionStatus.failure;
    });
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      btn2Status = FormzSubmissionStatus.initial;
    });
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rounded Loading Button Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FormzSubmitButton(
              status: btn1Status,
              successIcon: Icons.cloud,
              failedIcon: Icons.cottage,
              child: Text('Tap me!', style: TextStyle(color: Colors.white)),
              onPressed: _doSomethingForBtn1,
            ),
            SizedBox(height: 50),
            FormzSubmitButton(
              status: btn2Status,
              color: Colors.amber,
              successColor: Colors.amber,
              valueColor: Colors.black,
              borderRadius: 10,
              child: Text(
                'Tap me i have a huge text',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _doSomethingForBtn2,
            ),
            SizedBox(height: 50),
            OutlinedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              onPressed: () {
                setState(() {
                  btn1Status = FormzSubmissionStatus.initial;
                  btn2Status = FormzSubmissionStatus.initial;
                });
              },
              child: Text('Reset'),
            ),
            SizedBox(height: 20),
            OutlinedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              onPressed: () {
                setState(() {
                  btn1Status = FormzSubmissionStatus.failure;
                  btn2Status = FormzSubmissionStatus.failure;
                });
              },
              child: Text('Error'),
            ),
            SizedBox(height: 20),
            OutlinedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              onPressed: () {
                setState(() {
                  btn1Status = FormzSubmissionStatus.success;
                  btn2Status = FormzSubmissionStatus.success;
                });
              },
              child: Text('Success'),
            ),
          ],
        ),
      ),
    );
  }
}
