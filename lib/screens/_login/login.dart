import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../core/widgets/full_button_ts.dart';
import '../../core/widgets/language_selector.dart';
import '../../l10n/translations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'settings.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginSettings _settings = LoginSettings();
  final Translations translations = Translations();
  String _currentLanguage = 'IT';

  void _toggleVisibility() {
    setState(() {
      _settings.toggleVisibility();
    });
  }

  void _handleLogin() async {
    await _settings.handleLogin(context);
    // State Update
    setState(() {});
  }


    Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLanguage = prefs.getString('language');
    setState(() {
      _currentLanguage = savedLanguage ?? 'IT';
    });

    final translations = Translations();
    await translations.loadLanguage(_currentLanguage);
  }

@override
  void initState() {
    super.initState();
     _loadLanguage(); // Running
  }


   void _onLanguageChanged() {
    setState(() {
      _currentLanguage = _currentLanguage == 'IT' ? 'EN' : 'IT'; // Change Language
    });
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  LanguageSelector(onLanguageChanged: _onLanguageChanged),
                  SizedBox(height: 20),
                  Text(
                    'TiSpillo',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontFamily: 'Cursive',
                    ),
                  ),
                  SizedBox(height: 20),
                  FormBuilder(
                    key: _settings.formKey,
                    child: Column(
                      children: [
                        FormBuilderTextField(
                          name: 'email',
                          decoration: InputDecoration(
                            hintText: translations.translate('email_hint'),
                            prefixIcon: Icon(Icons.email, color: Theme.of(context).primaryColor),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                                errorText: translations.translate('email_required')),
                            FormBuilderValidators.email(
                                errorText: translations.translate('email_invalid')),
                          ]),
                        ),
                        SizedBox(height: 20),
                        FormBuilderTextField(
                          name: 'password',
                          obscureText: _settings.obscureText,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock, color: Theme.of(context).primaryColor),
                            hintText: translations.translate('password_hint'),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _settings.obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: _toggleVisibility,
                            ),
                          ),
                          validator: FormBuilderValidators.required(
                              errorText: translations.translate('password_required')),
                        ),
                        SizedBox(height: 20),
                        FullButtonTs(
                          onPressed: _settings.isLoading ? () => {} : _handleLogin,
                          child: _settings.isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(translations.translate('login'), style: TextStyle(color: Colors.white)),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Theme.of(context).primaryColor)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                translations.translate('or_text'),
                                style: TextStyle(color: Theme.of(context).primaryColor),
                              ),
                            ),
                            Expanded(child: Divider(color: Theme.of(context).primaryColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        translations.translate('no_account'),
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text(
                          translations.translate('register'),
                          style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  
                      SizedBox(height: 40),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
