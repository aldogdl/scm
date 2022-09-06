import 'package:flutter/material.dart';

import 'texto.dart';

class WidgetsAndUtils {

  ///
  static Future<bool?> showAlertBody(BuildContext context, {
    required String titulo,
    required Widget body,
    bool onlyAlert = true,
    bool withYesOrNot = false,
    bool onlyYES = false,
    bool dismissible = true,
    String msgOnlyYes = 'SI',
  }) async {

    return showDialog<bool?>(
      context: context,
      barrierDismissible: dismissible,
      builder: (_) => AlertDialog(
        contentPadding: const EdgeInsets.all(0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Texto(txt: titulo, sz: 19, isBold: true, isCenter: true, txtC: Colors.white),
            ),
            const Divider(),
            body
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: (onlyAlert)
        ? null : _acctiones(context, withYesOrNot, onlyYES, msgOnlyYes, false),
      )
    );
  }

  ///
  static Future<bool?> showAlert(BuildContext context, {
    required String titulo,
    required String msg,
    bool onlyAlert = true,
    bool withYesOrNot = false,
    bool onlyYES = false,
    String msgOnlyYes = 'SI',
    bool focusOnConfirm = false,
  }) async {

    return showDialog<bool?>(
      context: context,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Texto(txt: titulo, sz: 19, isBold: true, isCenter: true, txtC: Colors.white),
            const Divider(),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.33,
              child: Texto(txt: msg, isCenter: true, sz: 17),
            )
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: (onlyAlert)
        ? null
        : _acctiones(context, withYesOrNot, onlyYES, msgOnlyYes, focusOnConfirm),
      )
    );
  }

  ///
  static List<Widget> _acctiones(
    BuildContext context,
    bool siAndNo,
    bool onlyYes,
    String msgOnlyYes,
    bool focusOnConfirm,
  ) {

    List<Widget> btns = [
      _btnAlert(
        context, acc: msgOnlyYes,
        bg: Colors.purple, fnc: true, focusOnConfirm: focusOnConfirm
      )
    ];

    if(siAndNo) {
      btns.insert(0, _btnAlert(
        context, acc: 'NO',
        bg: Colors.red, fnc: false, focusOnConfirm: false
      ));
    }
    return btns;
  }

  ///
  static Widget _btnAlert(BuildContext context, {
    required bool fnc,
    required String acc,
    required Color bg,
    required bool focusOnConfirm,
  }) {

    return ElevatedButton(
      autofocus: focusOnConfirm,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(bg)
      ),
      onPressed: () => Navigator.of(context).pop(fnc),
      child: Texto(txt: acc, isBold: true, isCenter: true, txtC: Colors.white)
    );
  }
}