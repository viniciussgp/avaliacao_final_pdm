import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import './api/api.dart';
import './helpers/helpers.dart';
import './widgets/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Login(),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        title: 'Avaliação Final',
        theme: ThemeData(
          primaryColor: colorSmokyBlack,
        ),
        home: ValidarTela(),
      ),
    );
  }
}
