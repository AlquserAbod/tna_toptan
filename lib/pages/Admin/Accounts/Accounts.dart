import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tna_toptan/Helpers/DialogHelper.dart';
import 'package:tna_toptan/components/LoadingWidget.dart';
import 'package:tna_toptan/components/SearchNavBar.dart';
import 'package:tna_toptan/layout/bottomNavBar.dart';
import 'package:tna_toptan/pages/Admin/Accounts/AddUpdateAccountPage.dart';
import 'package:tna_toptan/Crud/AccountsCrud.dart';
// ignore_for_file: prefer_const_constructors

class AccountsPage extends StatefulWidget {
  static String tag = 'accounts';

  @override
  _AccountsPageState createState() => new _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  bool isAdmin = false; // Variable to track the switch state

  Widget accountRow(AccountsCrud user) {
    return Column(
      children: [
        SizedBox(
          height: 30,
        ),
        ListTile(
          title: Text(user.name),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.phonenumber),
                Text(user.address)
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return AddUpdateAccountPage(user: user); 
                      },
                    ),
                  );
                },
              ),
              IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () => DialogHelper.accountDeleteConfirmationDialog(context,user).show(),
                  ),
              IconButton(
                icon: Icon(Icons.info),
                color: Colors.amber,
                onPressed: () => DialogHelper.accountInfoDialogBuilder(context, user).show(),
              ),
            ],
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {

    Future<List<DocumentSnapshot<Object?>>>? accounts =
        AccountsCrud.getAccounts();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () => {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return AddUpdateAccountPage();
                    },
                  ),
                )
              },
          child: Icon(Icons.add)),
      body: FutureBuilder<List<DocumentSnapshot>>(
              future: accounts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return LoadingWidget();
                else if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                else if (!snapshot.hasData || snapshot.data!.isEmpty) return Text('No data available.');
                else {
                  List<DocumentSnapshot> documents = snapshot.data!;
                  return Column(children: [
                    SearchNavbar(
                      
                      title: 'Accounts ..'),
                    Expanded(
                        child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data =
                            documents[index].data() as Map<String, dynamic>;
                        return accountRow(
                          AccountsCrud(
                          id: documents[index].id,
                          name: data['name'],
                          password: data['password'], 
                          phonenumber: data['phonenumber'],
                          address: data['address'],
                          isAdmin: data['isadmin'],
                          language: languageMap[data['language']] ?? Language.en,
                          fcmTokens:[] ,

                          )
                        );
                      },
                    )),

                  ]);
                }
              },

      ),
      bottomNavigationBar: AdminNavBar(current_page_tag: AccountsPage.tag),
    );
  }
}
