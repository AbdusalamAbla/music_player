import 'package:flutter/material.dart';
import 'dart:async';
import 'package:overlay_support/overlay_support.dart';
import 'package:music_player/models/user_scp_model.dart';


class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final GlobalKey<FormState> _formState = GlobalKey();

  TextEditingController _phoneController;
  TextEditingController _passwordController;

  String _loginFailedMessage;

  @override
  void initState() {
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("登录"),
        ),
        body: Form(
          key: _formState,
          autovalidate: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(
                  height: 100,
                ),
                TextFormField(
                  controller: _phoneController,
                  validator: (text) {
                    if (text.trim().isEmpty) {
                      return "手机号不能为空";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    errorText: _loginFailedMessage,
                    filled: true,
                    labelText: "手机号码",
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  autofocus: false,
                ),
                const SizedBox(
                  height: 24,
                ),
                PasswordField(
                  validator: (text) {
                    if (text.trim().isEmpty) {
                      return "密码不能为空";
                    }
                    return null;
                  },
                  controller: _passwordController,
                ),
                const SizedBox(
                  height: 24,
                ),
                RaisedButton(
                  onPressed: _onLogin,
                  child: Text("点击登录",
                      style: Theme.of(context).primaryTextTheme.body1),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ));
  }

  void _onLogin() async {
    if (_formState.currentState.validate()) {
      try {
        var result = await showLoaderOverlay(
            context,
            UserAccount.of(context, rebuildOnChange: false)
                .login(_phoneController.text, _passwordController.text));
        if (result["code"] == 200) {
          Navigator.pop(context); //login succeed
        } else {
          showSimpleNotification(context, Text(result["msg"] ?? "登录失败"));
        }
      } catch (e) {
        showSimpleNotification(context, Text('$e'));
      }
    }
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    this.validator,
    this.controller,
  });

  final FormFieldValidator<String> validator;
  final TextEditingController controller;

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: _obscureText,
      validator: widget.validator,
      controller: widget.controller,
      decoration: InputDecoration(
        border: const UnderlineInputBorder(),
        filled: true,
        labelText: "密码",
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            semanticLabel: _obscureText ? '显示密码' : '隐藏密码',
          ),
        ),
      ),
    );
  }
}


Future<T> showLoaderOverlay<T>(BuildContext context, Future<T> data,
    {Duration timeout = const Duration(seconds: 5)}) {
  assert(data != null);

  final Completer<T> completer = Completer.sync();

  final entry = OverlayEntry(builder: (context) {
    return AbsorbPointer(
      child: SafeArea(
        child: Center(
          child: Container(
            height: 160,
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  });
  Overlay.of(context).insert(entry);
  data
      .then((value) {
        completer.complete(value);
      })
      .timeout(timeout)
      .catchError((e, s) {
        completer.completeError(e, s);
      })
      .whenComplete(() {
        entry.remove();
      });
  return completer.future;
}