import 'package:flutter/material.dart';

import 'scannerScreen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Alignment startAlignment = Alignment.center;
    Alignment endAlignment = Alignment.centerLeft;
    double t = 0.07;

    Alignment? alignedLeft = Alignment.lerp(startAlignment, endAlignment, t);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/palace.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: alignedLeft,
                        child: Text(
                          'Welcome!',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        child: Text(
                          'Your adventure with our App begins now!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(bottom: 70.0),
              child: ElevatedButton(
                onPressed: () {
                  // Itt navigálunk át a ScannerScreen-re, amikor megnyomják a gombot
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ScannerScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                ),
                child: Text('Try to scan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
