import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/services.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/widgets/full_button_ts.dart';
import 'settings.dart';
import '../../l10n/translations.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late final RegisterSettings _settings;
  final Translations translations = Translations();

  @override
  void initState() {
    super.initState();
    _settings = RegisterSettings(formKey: _formKey);
    print('Loading settings');
    _loadLanguage();
    setState(() {});
  }

  Future<void> _loadLanguage() async {
    String _currentLanguage = 'IT';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLanguage = prefs.getString('language');
    setState(() {
      _currentLanguage = savedLanguage ?? 'IT';
    });

    final translations = Translations();
    await translations.loadLanguage(_currentLanguage);
    setState(() {});
  }

  void _toggleVisibility() {
    setState(() {
      _settings.toggleVisibility();
    });
  }

  void _handleSignUp() async {
    await _settings.handleSignUp(context);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      appBar: AppBar(
        title: Text(translations.translate('register')),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                // Campo Email con validazione
                FormBuilderTextField(
                  name: 'email',
                  decoration: InputDecoration(
                    hintText: translations.translate('email_hint'),
                    prefixIcon: Icon(Icons.email, color: Colors.brown),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                        errorText: translations.translate('email_required')),
                    FormBuilderValidators.email(
                        errorText: translations.translate('email_invalid')),
                  ]),
                ),
                SizedBox(height: 16),

                // Campo Password con validazione
                FormBuilderTextField(
                  name: 'password',
                  obscureText: _settings.obscureText,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: Colors.brown),
                    hintText: translations.translate('password_hint'),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _settings.obscureText
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.brown,
                      ),
                      onPressed: _toggleVisibility,
                    ),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                        errorText: translations.translate('password_required')),
                    FormBuilderValidators.minLength(8,
                        errorText:
                            translations.translate('password_min_length')),
                  ]),
                ),
                SizedBox(height: 16),

                // Campo Confirm Password con validazione
                FormBuilderTextField(
                  name: 'confirm_password',
                  obscureText: _settings.obscureText,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: Colors.brown),
                    hintText: translations.translate('password_hint_conf'),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _settings.obscureText
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.brown,
                      ),
                      onPressed: _toggleVisibility,
                    ),
                  ),
                  validator: (val) {
                    if (val !=
                        _formKey.currentState?.fields['password']?.value) {
                      return translations.translate('password_required');
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                FullButtonTs(
                  onPressed: _settings.isLoading ? () => {} : _handleSignUp,
                  child: Text(translations.translate('register'),
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
