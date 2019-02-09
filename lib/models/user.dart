class User {
  User(
    this._username,
    this._token,
    this._emrals,
    this._id,
    this._picture,
    this._xp,
    this._emralsaddress,
  );

  User.map(dynamic obj) {
    this._username = obj["username"];
    this._token = obj["token"];
    this._emrals = double.parse(obj["emrals"].toString());
    this._picture = obj["picture"];
    this._xp = obj["xp"];
    this._id = obj["id"];
    this._emralsaddress = obj["emrals_address"];
  }

  double _emrals = 0;
  int _id;
  String _picture;
  String _token;
  String _username;
  String _emralsaddress;

  int _xp;

  String get username => _username;

  String get token => _token;

  String get picture => _picture;

  int get id => _id;

  int get xp => _xp;

  String get emralsaddress => _emralsaddress;

  double get emrals => _emrals;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["username"] = _username;
    map["token"] = _token;
    map["picture"] = _picture;
    map["id"] = _id;
    map["xp"] = _xp;
    map["emrals"] = _emrals;
    map["emralsaddress"] = _emralsaddress;
    return map;
  }

  User.fromMap(Map<String, dynamic> map) {
    this._username = map["username"];
    this._token = map["token"];
    this._emrals = map["emrals"];
    this._picture = map["picture"];
    this._xp = map["xp"];
    this._id = map["id"];
    this._emralsaddress = map["emralsaddress"];
  }
}
