import 'package:flutter/material.dart';

class CircleIconButton extends StatelessWidget {
  const CircleIconButton(
      {Key key, @required this.onPressed, @required this.icon})
      : super(key: key);

  final Function onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: RawMaterialButton(
        constraints: BoxConstraints.expand(width: 48, height: 48),
        onPressed: onPressed,
        child: Icon(
          icon,
          color: IconTheme.of(context).color,
        ),
        shape: CircleBorder(
            side: BorderSide(width: 2, color: IconTheme.of(context).color)),
      ),
    );
  }
}


