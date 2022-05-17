import 'package:flutter/material.dart';

import 'texto.dart';

class DecorationField {

  static Widget fieldBy({
    required TextEditingController ctr,
    required FocusNode fco,
    required double orden,
    required String help,
    required Function validate,
    required IconData iconoPre,
    bool isPass = false,
    bool showPass = true,
    int minLines = 1,
    ValueChanged<bool>? onPressed,
  }) {

    return FocusTraversalOrder(
      order: NumericFocusOrder(orden),
      child: TextFormField(
        controller: ctr,
        focusNode: fco,
        maxLines: minLines,
        textInputAction: TextInputAction.next,
        obscureText: (!isPass) ? false : showPass,
        validator: (val) => validate(val),
        decoration: DecorationField.get(
          help: help, isPass: isPass, iconoPre: iconoPre,
          showHidden: (isPass)
          ? IconButton(
            onPressed: () => onPressed!(!showPass),
            icon: Icon((showPass) ? Icons.visibility : Icons.visibility_off)
          )
          : null
        ),
      ),
    );
  }

  ///
  static Widget dropBy({
    required FocusNode fco,
    required String help,
    required IconData iconoPre,
    required double orden,
    required List<String> items,
    required ValueChanged<String?> onChange,
    String defaultValue = ''
  }) {

    defaultValue = (defaultValue.isNotEmpty) ? defaultValue : items.first;
    if(!items.contains(defaultValue)) {
      defaultValue = items.first;
    }
    return FocusTraversalOrder(
      order: NumericFocusOrder(orden),
      child: DropdownButtonFormField<String>(
        focusNode: fco,
        onChanged: (valSel) => onChange(valSel!),
        value: defaultValue,
        items: items.map((cargo) => DropdownMenuItem(
          value: cargo,
          child: Texto(txt: cargo),
        )).toList(),
        decoration: DecorationField.get(help: help, iconoPre:iconoPre),
      ),
    );
  }

  ///
  static InputDecoration get({
    required String help,
    required IconData iconoPre,
    bool isPass = false,
    Widget? showHidden
  }) {

    return InputDecoration(
      suffixIcon: (!isPass)
      ? null
      : Focus(
        canRequestFocus: false,
        descendantsAreFocusable: false,
        child: showHidden ?? const SizedBox()
      ),
      hintText: help,
      hintStyle: const TextStyle(
        color: Color.fromARGB(255, 88, 88, 88)
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.grey,
          width: 1
        ),
      ),
      prefixIcon: Icon(iconoPre, size: 15, color: Colors.white.withOpacity(0.2)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.grey,
          width: 1
        ),
      ),
      errorStyle: const TextStyle(
        color: Color.fromARGB(255, 255, 244, 149)
      ),
      helperText: (help.isNotEmpty) ? help : null
    );
  }
}