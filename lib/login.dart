import 'package:flutter/material.dart';

// Amplify Flutter Packages
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/services.dart';

import 'amplifyconfiguration.dart';

import 'package:driving_range_assistant_ui/sign_up_api.dart';
import 'package:driving_range_assistant_ui/verify_code_api.dart';
import 'package:driving_range_assistant_ui/sign_in_api.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _amplifyConfigured = false;
  final _emailController = TextEditingController();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verifyCodeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  int _selectedIndex = 0;
  bool _isSignedUp = false;
  String _userName;
  String _errorText = "";

  @override
  initState() {
    super.initState();
    _configureAmplify();
  }

  void _onItemPressed(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void setErrorText(String text) {
    setState(() {
      _errorText = text;
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _emailController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    _verifyCodeController.dispose();
    super.dispose();
  }

  void _configureAmplify() async {

    // Add Pinpoint and Cognito Plugins, or any other plugins you want to use
    AmplifyAuthCognito authPlugin = AmplifyAuthCognito();
    Amplify.addPlugin(authPlugin);

    // Once Plugins are added, configure Amplify
    await Amplify.configure(amplifyconfig);
    try {
      setState(() {
        _amplifyConfigured = true;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_formKey != null && _formKey.currentState != null) {
      _formKey.currentState.reset();
    }

    List<Widget> _formOptions = <Widget>[
      Container(
          child: _loginWidget(),
      ),
      Container(
          child: _signUpWidget(),
      ),
      Container(
          child: _verifyWidget(),
      ),
    ];

    List<Widget> _appBarOptions = <Widget>[
      Text("Enter Credentials"),
      Text("Register"),
      Text("Verify Code"),
    ];
    
    return Scaffold(
        appBar: AppBar(
          title: _appBarOptions.elementAt(_selectedIndex),
        ),
        body: Form(
            key: _formKey,
            child: _formOptions.elementAt(_selectedIndex),
        )
    );
  }

  Widget _loginWidget() {
    return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: InputDecoration(
                  labelText: 'Enter your username'
              ),
              controller: _userNameController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
                decoration: InputDecoration(
                    labelText: 'Enter your password'
                ),
                obscureText: true,
                controller: _passwordController,
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (_isSignedUp == false)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    _onItemPressed(1);
                  },
                  child: Text('Sign-up'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, or false
                    // otherwise.
                    if (_formKey.currentState.validate()) {
                      SignInApi signin = new SignInApi(
                          _userNameController.text,
                          _passwordController.text
                      );

                      Future<bool> signInResult = signin.signIn()
                          .then((value) {
                            if (value) {
                              setErrorText("");
                              Navigator.pushNamed(context, '/select-image');
                            } else {
                                setErrorText("Login failed! Enter correct Credentials");
                            }
                            return value;
                          }
                      );
                    }
                  },
                  child: Text('Sign-in'),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  '$_errorText',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ]
    );
  }

  Widget _signUpWidget() {
    return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s'))
                ],
                decoration: InputDecoration(
                    labelText: 'Enter a valid email address. Verification code will be sent to it.'
                ),
                controller: _emailController,
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s'))
                ],
                decoration: InputDecoration(
                    labelText: 'Enter your username'
                ),
                controller: _userNameController,
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.deny("\s")
                ],
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'Enter your password'
                ),
                controller: _passwordController,
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, or false
                    // otherwise.
                    if (_formKey.currentState.validate()) {
                      var signup = new SignUpApi(
                          _emailController.text,
                          _userNameController.text,
                          _passwordController.text
                      );
                      signup.signUp();
                      setState(() {
                        _userName = _userNameController.text;
                        _isSignedUp = true;
                      });
                      _onItemPressed(2);
                    }
                  },
                  child: Text('Sign-up'),
                ),
              ),
            ],
          ),
        ]
    );
  }

  Widget _verifyWidget() {
    return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                ],
                decoration: InputDecoration(
                    labelText: 'Enter verification code'
                ),
                controller: _verifyCodeController,
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, or false
                    // otherwise.
                    if (_formKey.currentState.validate()) {
                      var verifyCode = new VerifyCodeApi(
                          _userName,
                          _verifyCodeController.text
                      );
                      verifyCode.verify()
                        .then((value) {
                          if (value) {
                            Amplify.Auth.signOut();
                            _onItemPressed(0);
                          }
                      });
                    }
                  },
                  child: Text('Verify'),
                ),
              ),
            ],
          ),
        ]
    );
  }
}