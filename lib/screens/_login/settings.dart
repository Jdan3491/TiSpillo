import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'auth_service.dart';
class LoginSettings {
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  bool isLoading = false;
  String? errorMessage;
  bool obscureText = true;

  void toggleVisibility() {
    obscureText = !obscureText;
  }

  Future<void> handleLogin(BuildContext context) async {
    isLoading = true;
    errorMessage = null;

    final result = await AuthService.login(
      formKey,
      context,
    );

    isLoading = false;
    errorMessage = result;
  }
}
