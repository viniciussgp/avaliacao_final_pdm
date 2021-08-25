class User {

  DateTime expiresIn = DateTime(0);
  String email       = '';
  String idToken     = '';
  String localId     = '';
  String nome        = '';
  String cpf         = '';
  String grauEscola  = '';
  String foto        = '';

  User({
    required this.expiresIn,
    required this.email,
    required this.idToken,
    required this.localId,
    required this.nome,
    required this.cpf,
    required this.grauEscola,
    required this.foto,
  });

  User.fromJson(Map<String, dynamic> json) {
    expiresIn  = DateTime.now().add(Duration(seconds: int.parse(json['expiresIn'])));
    email      = json['email']??"";
    idToken    = json['idToken']??"";
    localId    = json['localId']??"";
    nome       = json['nome']??"";
    cpf        = json['cpf']??"";
    grauEscola = json['grauEscola']??"";
    foto       = json['foto']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['expiresIn']  = this.expiresIn;
    data['email']      = this.email;
    data['idToken']    = this.idToken;
    data['localId']    = this.localId;
    data['nome']       = this.nome;
    data['cpf']        = this.cpf;
    data['grauEscola'] = this.grauEscola;
    data['foto']       = this.foto;
    return data;
  }

  User.clear(){
    expiresIn = DateTime(0);
    email      = "";
    idToken    = "";
    localId    = "";
    nome       = "";
    cpf        = "";
    grauEscola = "";
    foto       = "";
  }

}