import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/helpers.dart';
import '../../models/models.dart';

class Login extends ChangeNotifier {
  Login() {
    _carregarUserAtual(usuario: User.clear());
  }

  Dio dio = Dio();

  User user = User.clear();

  bool get autenticado => getToken.isNotEmpty;

  String get getToken {
    if (user.idToken.isNotEmpty && user.expiresIn.isAfter(DateTime.now())) {
      return user.idToken;
    } else {
      return "";
    }
  }

  GlobalKey<ScaffoldState> scaffoldKeyLogin =
      GlobalKey<ScaffoldState>(debugLabel: '_scaffoldKeyLogin');
  GlobalKey<ScaffoldState> scaffoldKeyCadastar =
      GlobalKey<ScaffoldState>(debugLabel: '_scaffoldKeySinup');

  bool _loading = false;

  bool get loading => _loading;

  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  //Pegar Imagem
  final imagemTemporaria = PickedFile;
  final _picker = ImagePicker();

  File _imagem = File("");

  File get imagem => _imagem;

  set imagem(File value) {
    _imagem = value;
    notifyListeners();
  }

  Future<void> pegarImagemGaleria(BuildContext context) async {
    PickedFile? imagemTemporaria =
        await _picker.getImage(source: ImageSource.camera, imageQuality: 80);
    if (imagemTemporaria != null) {
      imagem = File(imagemTemporaria.path);
    }
  }

  Future<String> salvarImagem() async {
    final firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child("usuarios/" + imagem.path.split('/').last);
    final uploadTask = firebaseStorageRef.putFile(imagem);

    final taskSnapshot = await uploadTask.whenComplete(() {});
    final urlDownload = await taskSnapshot.ref.getDownloadURL();

    return urlDownload;
  }

  Future<void> postLogin({
    required String email,
    required String senha,
    required Function(String) onFail,
    required Function(String) onSuccess,
  }) async {
    loading = true;

    var corpo = json
        .encode({"email": email, "password": senha, "returnSecureToken": true});

    try {
      final response = await Dio().post(
        login + key,
        data: corpo,
      );

      if (response.statusCode == 200) {
        final response2 = await dio.get(
          api_user_dados + response.data['localId'] + "/.json",
        );

        _carregarUserAtual(
          usuario: User(
            nome: response2.data['nome'],
            grauEscola: response2.data['grauEscola'],
            foto: response2.data['foto'],
            cpf: response2.data['cpf'],
            email: response.data['email'],
            expiresIn: DateTime.now()
                .add(Duration(seconds: int.parse(response.data['expiresIn']))),
            idToken: response.data['idToken'],
            localId: response.data['localId'],
          ),
        );

        await salvarDadosUser(
          usuario: User(
            nome: response2.data['nome'],
            grauEscola: response2.data['grauEscola'],
            foto: response2.data['foto'],
            cpf: response2.data['cpf'],
            email: response.data['email'],
            expiresIn: DateTime.now()
                .add(Duration(seconds: int.parse(response.data['expiresIn']))),
            idToken: response.data['idToken'],
            localId: response.data['localId'],
          ),
        );

        onSuccess("Login confirmado!");
      } else {
        onFail("Erro code");
      }
    } catch (e) {
      onFail("Erro ao realizar o login, tente novamente mais tarde!");
    }

    notifyListeners();
    loading = false;
  }

  Future<void> postCadastrarUser({
    required String email,
    required String senha,
    required User user,
    required Function(String) onFail,
    required Function(String) onSuccess,
  }) async {
    loading = true;

    try {
      var caminhoImagem = await salvarImagem();

      var corpo = json.encode(
          {"email": email, "password": senha, "returnSecureToken": true});

      final response = await dio.post(
        signUp + key,
        data: corpo,
      );

      var localId = response.data['localId'];

      if (response.statusCode == 200) {
        var corpo = json.encode({
          'nome': user.nome,
          'cpf': user.cpf,
          'grauEscola': user.grauEscola,
          'foto': caminhoImagem,
          "email": email
        });

        final response1 = await dio.patch(
          api_user_cadastrar + localId + ".json",
          data: corpo,
        );

        final response2 = await dio.get(
          api_user_dados + response.data['localId'] + "/.json",
        );

        _carregarUserAtual(
          usuario: User(
            nome: response2.data['nome'],
            grauEscola: response2.data['grauEscola'],
            foto: response2.data['foto'],
            cpf: response2.data['cpf'],
            email: response.data['email'],
            expiresIn: DateTime.now()
                .add(Duration(seconds: int.parse(response.data['expiresIn']))),
            idToken: response.data['idToken'],
            localId: response.data['localId'],
          ),
        );

        await salvarDadosUser(
          usuario: User(
            nome: response2.data['nome'],
            grauEscola: response2.data['grauEscola'],
            foto: response2.data['foto'],
            cpf: response2.data['cpf'],
            email: response.data['email'],
            expiresIn: DateTime.now()
                .add(Duration(seconds: int.parse(response.data['expiresIn']))),
            idToken: response.data['idToken'],
            localId: response.data['localId'],
          ),
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> data =
              new Map<String, dynamic>.from(response1.data);
          if (data.containsKey('email')) {
            onSuccess("Usuário cadastrado com sucesso!");
          } else {
            onFail("Erro ao cadastrar Usuário!");
          }
        } else {
          onFail("Erro ao cadastrar Usuário!");
        }
      } else {
        onFail("Erro code");
      }
    } catch (e) {
      onFail("Erro ao realizar o cadastro, tente novamente mais tarde!");
    }

    notifyListeners();
    loading = false;
  }

  void retornarMensagem({
    required BuildContext context,
    required String mensagem,
    required Color color,
    required bool voltarTela,
  }) {
    scaffoldKeyLogin.currentState!.showSnackBar(SnackBar(
      content: Text(
        mensagem,
        textAlign: TextAlign.center,
      ),
      backgroundColor: color,
      duration: Duration(seconds: 2),
    ));

    if (voltarTela) {
      Future.delayed(Duration(seconds: 2)).then((_) {
        Navigator.pop(context);
      });
    }
  }

  void retornarMensagemCadastrar({
    required BuildContext context,
    required String mensagem,
    required Color color,
    required bool voltarTela,
  }) {
    scaffoldKeyCadastar.currentState!.showSnackBar(SnackBar(
      content: Text(
        mensagem,
        textAlign: TextAlign.center,
      ),
      backgroundColor: color,
      duration: Duration(seconds: 2),
    ));

    if (voltarTela) {
      Future.delayed(Duration(seconds: 2)).then((_) {
        Navigator.pop(context);
      });
    }
  }

  salvarDadosUser({required User usuario}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('expiresIn', usuario.expiresIn.toString());
    prefs.setString('email', usuario.email);
    prefs.setString('idToken', usuario.idToken);
    prefs.setString('localId', usuario.localId);

    notifyListeners();
  }

  Future<void> _carregarUserAtual({required User usuario}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (usuario.idToken.isNotEmpty) {
      user = usuario;
    }

    if (prefs.getString('idToken') != null) {
      user = User(
        expiresIn: DateFormat("yyyy-MM-dd hh:mm:ss")
            .parse(prefs.getString('expiresIn') ?? ""),
        email: prefs.getString('email') ?? "",
        idToken: prefs.getString('idToken') ?? "",
        localId: prefs.getString('localId') ?? "",
        cpf: prefs.getString('cpf') ?? "",
        foto: prefs.getString('foto') ?? "",
        grauEscola: prefs.getString('grauEscola') ?? "",
        nome: prefs.getString('nome') ?? "",
      );
    }

    notifyListeners();
  }

  Future<void> sair() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove("expiresIn");
    prefs.remove("email");
    prefs.remove("idToken");
    prefs.remove("localId");

    user = User.clear();
    notifyListeners();
  }
}
