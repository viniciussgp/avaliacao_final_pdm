import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../api/api.dart';
import '../../helpers/helpers.dart';

import './componenes/card_user.dart';
import '../login/login_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Login>(
      builder: (_, login, __) {
        return Scaffold(
          backgroundColor: colorFundo,
          appBar: AppBar(
            title: Text(
              "Avaliação Final",
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 22,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () async {
                  await login.sair();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                },
                tooltip: 'Sair',
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
            ],
          ),
          body: login.loading
              ? Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.redAccent,
                    color: Colors.white,
                  ),
                )
              : Center(
                  child: CardUser(user: login.user),
                ),
        );
      },
    );
  }
}
