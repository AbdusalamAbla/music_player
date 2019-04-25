import 'dart:async';

import 'package:flutter/material.dart';

Future<bool> showConfirmDialog(BuildContext context, Widget content,
    {String positiveLabel, String negativeLabel}) async {
  negativeLabel ??= "取消";
  positiveLabel ??= "确认";

  bool result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: content,
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text(negativeLabel)),
            FlatButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text(positiveLabel)),
          ],
        );
      });
  result ??= false;
  return result;
}