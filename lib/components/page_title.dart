import 'package:flutter/material.dart';


class PageTitle extends StatelessWidget {
  final String title;
  const PageTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
    color: Colors.transparent,
    margin: EdgeInsets.fromLTRB(0, 30, 0, 30),
    child: Align(
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
            color: Color(0xFF00A7FD),
            fontSize: 30,
            fontFamily: 'PlaypenSans',
            fontWeight: FontWeight.bold),
      ),
    ),
  );
  }
}