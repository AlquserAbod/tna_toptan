import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tna_toptan/Crud/AccountsCrud.dart';

class AccountsHelper{
  final String? id; 
  final String? name;
  final String? password;
  final String? address;
  final String? phonenumber;
  final bool isAdmin;
  final Language language;
  final List<String> fcmTokens= [];

  AccountsHelper(
      {this.name,
      this.password,
      this.phonenumber,
      this.address,
      this.isAdmin = false,
      this.language = Language.en,
      this.id});

  static CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  static Future<QueryDocumentSnapshot<Object?>?> findUserByName(
      String name) async {
    try {
      final user_doc = await users.where('name', isEqualTo: name).get();

      if (!user_doc.docs.isEmpty) return user_doc.docs.first;

      return null;
    } catch (e) {
      print('Error : $e');
      return null;
    }
  }

  Future<void> removeTokenFromDatabase(String token) async {

    if(token == "") return;

    await users
      .doc(id)
        .update({
          'fcmTokens': FieldValue.arrayRemove([token]),
        });

  }

  Future<void> saveTokenToDatabase(String token) async {

     if(token == "") return;

    await users
      .doc(id)
      .update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
  }


}
