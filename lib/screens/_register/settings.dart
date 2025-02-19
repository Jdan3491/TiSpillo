import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'auth_service.dart';

class RegisterSettings {
  final GlobalKey<FormBuilderState> formKey;
  bool isLoading = false;
  String? errorMessage;
  bool obscureText = true;

  RegisterSettings({required this.formKey});

  void toggleVisibility() {
    obscureText = !obscureText;
  }

  Future<void> handleSignUp(BuildContext context) async {
    isLoading = true;
    await RegisterService.register(formKey, context);
    isLoading = false;
  }
}
