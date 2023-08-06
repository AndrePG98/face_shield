import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 4,
              child: SizedBox(
                width: 150,
                height: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: const Image(
                    image: AssetImage('assets/images/icon.png'),
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: Text(
                  'FaceShield',
                  softWrap: false,
                  style: GoogleFonts.notoSerifHebrew(
                    textStyle: const TextStyle(fontSize: 30)
                  )
                ),
              )
            )
          ],
        )
      )
    );
  }
}