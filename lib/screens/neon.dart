import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class Neon extends StatefulWidget {
  const Neon({super.key});

  @override
  State<Neon> createState() => _NeonState();
}

class _NeonState extends State<Neon> {
  bool isPressed = false;
  @override
  Widget build(BuildContext context) {
    Color shadowColor = Colors.red;
    return Scaffold(
      backgroundColor: const Color(0xFF00000F),
      body: Center(
        child: Listener(
          onPointerDown: (event) => setState(() {
            isPressed = true;
          }),
          onPointerUp: (event) => setState(() {
            isPressed = false;
          }),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  for (double i = 1; i < 5; i++)
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: (isPressed ? 5 : 3) * i,
                    ),
                  for (double i = 1; i < 5; i++)
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: (isPressed ? 5 : 3) * i,
                      blurStyle: BlurStyle.outer,
                      spreadRadius: -1,
                    )
                ]),
            child: TextButton(
              onPressed: () {},
              onHover: (value) => setState(() {
                isPressed = value;
              }),
              style: TextButton.styleFrom(
                  side: const BorderSide(color: Colors.white, width: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
              child: Text(
                'Neon Button',
                style: TextStyle(
                  color: Colors.white,
                  shadows: [
                    for (double i = 1; i < (isPressed ? 8 : 4); i++)
                      Shadow(color: shadowColor, blurRadius: 3 * i),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
