import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 8) text = text.substring(0, 8);

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;

      if ((nonZeroIndex == 2 || nonZeroIndex == 4) && i != text.length - 1) {
        buffer.write('/');
      }
    }

    var new_string_text = buffer.toString();
    return newValue.copyWith(
      text: new_string_text,
      selection: TextSelection.collapsed(offset: new_string_text.length),
    );
  }
}
