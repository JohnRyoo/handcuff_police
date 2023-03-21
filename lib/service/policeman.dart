class Policeman {
  String _id = '';
  String _password = '';
  String _name = '';
  String _department = '';

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get password => _password;

  set password(String value) {
    _password = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get department => _department;

  set department(String value) {
    _department = value;
  }
}