import 'package:flutter/material.dart';

class Styledtextfield extends StatefulWidget {
  const Styledtextfield({super.key, this.controller, this.labelText});

  final TextEditingController? controller;
  final String? labelText;

  @override
  State<Styledtextfield> createState() => _StyledtextfieldState();
}

class _StyledtextfieldState extends State<Styledtextfield> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22.0),
      child: Container(
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFC8B283), Color(0xFFF9DDAA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.2],
            tileMode: TileMode.clamp,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(7.0)),
          ),
        ),
        child: TextField(
          controller: widget.controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: "${widget.labelText}",
            labelStyle: TextStyle(color: Color(0xFFC8B283)),
            // fillColor: Color(0xFFF9DDAA),
            // filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
