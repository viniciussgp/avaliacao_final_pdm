import 'package:flutter/material.dart';

import '../../../models/models.dart';

class CardUser extends StatelessWidget {
  final User user;

  CardUser({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: ListView(
        children: [
          ClipOval(
            child: Container(
              height: 280,
              width: 280,
              color: Colors.white,
              child: Image.network(
                user.foto,
                height: 280,
                width: 280,
                fit: BoxFit.fitHeight,
                errorBuilder: (context, url, error) => Container(
                    child: Icon(
                  Icons.close,
                  color: Colors.grey,
                )),
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            user.nome,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            "cpf: " + user.cpf,
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            'Grau escolar: ' + user.grauEscola,
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }
}
