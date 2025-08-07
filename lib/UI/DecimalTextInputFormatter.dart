import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter(
      {required this.decimalRange, this.activatedNegativeValues})
      : assert(
            decimalRange >= 0, 'DecimalTextInputFormatter declaretion error');

  final int decimalRange;
  final bool? activatedNegativeValues;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (newValue.text.contains(' ')) {
      return oldValue;
    }

    if (newValue.text.isEmpty) {
      return newValue;
    } else if (double.tryParse(newValue.text) == null &&
        !(newValue.text.length == 1 &&
            (activatedNegativeValues == true ||
                activatedNegativeValues == null) &&
            newValue.text == '-')) {
      return oldValue;
    }

    if (activatedNegativeValues == false &&
        double.tryParse(newValue.text)! < 0) {
      return oldValue;
    }

    // ignore: unnecessary_null_comparison
    if (decimalRange != null) {
      String value = newValue.text;

      if (decimalRange == 0 && value.contains(".")) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      }

      if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}

class NumberFormField extends StatelessWidget {
  final InputDecoration decoration;
  final TextEditingController controller;
  final int decimalRange;

  const NumberFormField(
      {super.key,
      required this.decoration,
      required this.controller,
      required this.decimalRange});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: decoration,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d+\-\.]')),
        DecimalTextInputFormatter(decimalRange: decimalRange),
      ],
    );
  }
}
