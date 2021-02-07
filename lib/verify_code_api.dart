// Amplify Flutter Packages
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/cupertino.dart';

import 'amplifyconfiguration.dart';

import 'package:driving_range_assistant_ui/utils.dart';

class VerifyCodeApi {
  String _userName;
  String _verificationCode;

  VerifyCodeApi(this._userName, this._verificationCode);

  Future<bool> verify() async {
    try {
      SignUpResult res = await Amplify.Auth.confirmSignUp(
          username: this._userName,
          confirmationCode: this._verificationCode
      );
      return true;
    } on AuthError catch (e) {
        printAmplifyStackTrace(e);
        return false;
    }
  }
}