import 'package:citations/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = 40;
    double width = 40;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Spacer(),
            Image.asset(
              "assets/quote.png",
              height: 150,
              width: 150,
              color: Colors.black,
            ),
            SizedBox(
              height: 50,
            ),
            RichText(
              text: TextSpan(
                style: GoogleFonts.lato(
                  textStyle: TextStyle(fontSize: 50, color: Colors.black),
                ),
                children: [
                  TextSpan(text: "Laissez-vous\n", style: TextStyle(fontSize: 50)),
                  TextSpan(
                      text: "Inspirer",
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 50)),
                ],
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomeScreen()));
                },
                
                child: Text("Allons-y", style: TextStyle(color: Colors.white),),
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Colors.black),),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}