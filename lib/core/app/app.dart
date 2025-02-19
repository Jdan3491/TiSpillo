import 'package:flutter/material.dart';
import '../../l10n/translations.dart';
import '../../utils/route/route_generator.dart';
import 'package:flutter/services.dart';
import '../ui/_style.dart';
import 'package:intl/intl_standalone.dart';

class TispilloApp extends StatefulWidget {
  final String initialLanguage;

  const TispilloApp({Key? key, required this.initialLanguage}) : super(key: key);

  @override
  State<TispilloApp> createState() => _TispilloAppState();
}

class _TispilloAppState extends State<TispilloApp> {
  @override
  void initState() {
    super.initState();
    _setStatusBarStyle();
  }

  void _setStatusBarStyle() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ),
      child: MaterialApp(
        title: 'TodoList App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
