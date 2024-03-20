
// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tna_toptan/Helpers/AccountsHelper.dart';
import 'package:tna_toptan/Helpers/MessageingHelper.dart';
import 'package:tna_toptan/main.dart';
import 'package:tna_toptan/Crud/AccountsCrud.dart';

class AuthService {
  static const userdocid_session_id = 'user_doc_id';
  static const isLoggedIn_session_id = 'isLoggedIn';

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  static Future<AccountsCrud?> login(String name, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseMessaging _firebaseMessaging = await FirebaseMessaging.instance;

    final QuerySnapshot<Map<String, dynamic>> docs  = await FirebaseFirestore.instance.collection('users')
        .where('name', isEqualTo: name.trim())
        .where('password',isEqualTo: password)
        .limit(1)
        .get();

      if(docs.docs.isNotEmpty){
        final user = docs.docs.first;

        String docid = user.id;
        prefs.setBool(isLoggedIn_session_id, true);
        prefs.setString(userdocid_session_id, docid);

        if(user['isadmin']){
          _firebaseMessaging.subscribeToTopic('admins');
        }else {
          _firebaseMessaging.subscribeToTopic('clients');
          _firebaseMessaging.subscribeToTopic('clients_${user['language']}');

        }
        // Set Phone Fcm Token 
        MessageingHelper.getFCMToken().then((fcmToken) {
          AccountsHelper(id: docid).saveTokenToDatabase(fcmToken!);
        });
        return AccountsCrud.read(docid);

      }else {
        return null;
      }

  }

  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedIn_session_id) ?? false;
  }

  static Future<AccountsCrud?> currentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user_doc_id = prefs.getString(userdocid_session_id);

    if (user_doc_id == null) return null;

    return AccountsCrud.read(user_doc_id);
  }

  static Future<void> sign_out() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseMessaging _firebaseMessaging = await FirebaseMessaging.instance;

    final user = await currentUser();
    if (user == null) return null;
    

    if(user.isAdmin){
      _firebaseMessaging.unsubscribeFromTopic('admins');
    }else {
      _firebaseMessaging.unsubscribeFromTopic('clients');
      _firebaseMessaging.unsubscribeFromTopic('clients_${user.language}');

    }
    prefs.setBool(isLoggedIn_session_id, false);
    prefs.remove(userdocid_session_id);

    navigatorKey.currentState
        ?.pushNamed('login'); // navigate to login, with null-aware check
        
    MessageingHelper.getFCMToken().then((fcmToken) {
      AccountsHelper(id: user.id).removeTokenFromDatabase(fcmToken!);
    });        

  }

  static Future<bool?> isAdminUser() async {
    final user = await AuthService.currentUser();
    if(user == null) return null;

    return user.isAdmin;
  }

  static Future<String?> currentUserId() async {
    final user = await AuthService.currentUser();
    if(user == null) return null;
    return user.id;
  }
}
