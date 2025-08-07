import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

void toast(BuildContext context, String text, MaterialColor col) {
  showToast(text,
      context: context,
      textStyle: const TextStyle(fontSize: 20.0, color: Colors.white),
      backgroundColor: col,
      textPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
      borderRadius: const BorderRadius.vertical(
          top: Radius.elliptical(10.0, 20.0),
          bottom: Radius.elliptical(10.0, 20.0)),
      textAlign: TextAlign.justify,
      textDirection: TextDirection.rtl);
}
