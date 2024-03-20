

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tna_toptan/Helpers/AccountsHelper.dart';

enum Language {
  ar,
  en,
  tr,
}

Map<String, Language> languageMap = {
  'ar': Language.ar,
  'en': Language.en,
  'tr': Language.tr,
};


extension OrderStateExtension on Language {
  String get languageText {
    switch (this) {
      case Language.en:
        return 'English';
      case Language.ar:
        return 'Arabic';
      case Language.tr:
        return 'Turkish';
      default:
        return 'Unknown';
    }
  }

}

class AccountsCrud {

  String? id; // Remove the 'final' keyword to make it nullable
  String name;
  String password;
  String address;
  String phonenumber;
  bool isAdmin;
  Language language;
  List<dynamic> fcmTokens = [];
 
  AccountsCrud(
    
      {required this.name,
      required this.password,
      required this.phonenumber,
      required this.address,
      required this.isAdmin,
      this.fcmTokens = const [],

      this.language = Language.en,
      this.id});

  static CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  Future<void> create() async {

    AccountsHelper.findUserByName(name).then((data) {
      if(data!.exists) {
        print('error : $name is already exsists');
        return null;
      }
    });



    final docRef = await users.add({
      'name': name,
      'password': password,
      'phonenumber': phonenumber,
      'address': address,
      'language': language.name,
      'isadmin': isAdmin,

    });

    id = docRef.id;
  }

  static Future<List<DocumentSnapshot>> getAccounts() async {
    try {
      QuerySnapshot querySnapshot = await users.get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error fetching documents: $e");
      return [];
  }
    }

  Future<AccountsCrud> update(Map<Object, Object> new_data) async {
    try {
      await users.doc(id).update(new_data);
      new_data.forEach((key, value) {
        if (key == 'name') name = value as String;
        if (key == 'password') password = value as String;
        if (key == 'phonenumber') phonenumber = value as String;
        if (key == 'address') address = value as String;
        if (key == 'language') language = languageMap[value] ?? Language.en;
        if (key == 'isadmin') isAdmin = value as bool;
        if (key == 'fcmTokens') fcmTokens = fcmTokens;
      });
      return this;
    } catch (e) {
      print('Error updating account: $e');
      rethrow;
    }
  }

  Future delete() async {
    await users.doc(id).delete();
  }





 static Future<AccountsCrud?> read(String documentId) async {
    try {
      final data =await users.doc(documentId).get();

      if (data.exists) {
        return AccountsCrud(
          id: documentId,
          name: data.get('name'),
          password: data.get('password'),
          phonenumber: data.get('phonenumber'),
          address: data.get('address'),
          isAdmin: data.get('isadmin') ?? false,
          language: languageMap[data.get('language')] ?? Language.en,
          fcmTokens: data.get('fcmTokens') ?? [],
        );
      }
    } catch (e) {
      print('Error fetching document: $e');
    }
    return null;
  }


}
