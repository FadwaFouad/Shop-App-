import 'dart:async';
import 'dart:convert';

import 'package:Shop/models/http_exception.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  String _token;
  String _userId;
  DateTime _expireDate;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  get userId => _userId;

  String get token {
    if (_token != null &&
        _expireDate != null &&
        _expireDate.isAfter(DateTime.now()))
      return _token;
    else
      return null;
  }

  Future<void> _authSign(String email, String pass, String urlAccount) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlAccount?key=AIzaSyAq0OKYVF0gwFLRZHqttPiVrKUgl54bY5o';

    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': pass,
            'returnSecureToken': true,
          }));

      final resMap = json.decode(response.body);
      if (resMap['error'] == null) {
        _userId = resMap['localId'];
        _token = resMap['idToken'];
        _expireDate = DateTime.now().add(Duration(
          seconds: int.parse(resMap['expiresIn']),
        ));
        notifyListeners();
        _autoLogOut();
        final perfs = await SharedPreferences.getInstance();
        final userData = json.encode({
          'userId': _userId,
          'token': _token,
          'expireDate': _expireDate.toIso8601String(),
        });
        perfs.setString('userData', userData);
      } else
        throw HttpException(resMap['error']['message']);
    } catch (error) {
      throw error;
    }
    //print(response.body.toString());
  }

  Future<bool> tryLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;
    final userData=json.decode(prefs.getString('userData')) as Map <String,Object>;
    final expireDate =DateTime.parse(userData['expireDate']) ;
    if (expireDate.isBefore(DateTime.now())) return false;
      _userId = userData['userId'];
        _token = userData['token'];
        _expireDate =expireDate;
        notifyListeners();
        _autoLogOut(); 
        return true;
  }

  Future<void> signUp(String email, String pass) async {
    return _authSign(email, pass, 'signUp');
  }

  Future<void> login(String email, String pass) async {
    return _authSign(email, pass, 'signInWithPassword');
  }

  void logOut() async {
    _userId = null;
    _token = null;
    _expireDate = null;
    _authTimer.cancel();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogOut() {
    //if (_timer != null) _timer.cancel();
    final timeExpiry = _expireDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeExpiry), logOut);
  }
}
