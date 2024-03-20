
import 'package:flutter/material.dart';
import 'package:tna_toptan/Helpers/DialogHelper.dart';
import 'package:tna_toptan/components/page_title.dart';
import 'package:tna_toptan/layout/bottomNavBar.dart';
import 'package:tna_toptan/pages/Admin/Accounts/Accounts.dart';
import 'package:tna_toptan/Crud/AccountsCrud.dart';


class AddUpdateAccountPage extends StatefulWidget {
  static String tag = 'add-account';
  final AccountsCrud? user;

  AddUpdateAccountPage({this.user});

  @override
  _AddUpdateAccountPageState createState() =>
      new _AddUpdateAccountPageState(user: user);
}

class _AddUpdateAccountPageState extends State<AddUpdateAccountPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool isAdmin = false;
  Language selectedLanguage = Language.en;

  AccountsCrud? user;

  _AddUpdateAccountPageState({this.user});

  String? nameError;
  String? phoneNumberError;
  String? passwordError;

  void _cancel() {
    // Implement the action to go to the previous page or cancel the form here.
    Navigator.pop(context);
  }

  void _submitForm(){

    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      if (user == null) {
        AccountsCrud(
            name:  nameController.value.text,
            password: passwordController.value.text,
            phonenumber: phoneNumberController.value.text,
            address: addressController.value.text,
            isAdmin: isAdmin,
            language: selectedLanguage).create();
        DialogHelper.accountCreatedDialog(context).show();
      } else {

          user!.update({
              "name": nameController.value.text,
              "password": passwordController.value.text,
              "phonenumber": phoneNumberController.value.text,
              "address":addressController.value.text,
              "isadmin": isAdmin,
              "language": selectedLanguage.toString()}
          );

        DialogHelper.accountUpdatedDialog(context).show();

      }

    
    } else {
      setState(() {
        nameError = _validateName(nameController.text);
        phoneNumberError = _validatePhoneNumber(phoneNumberController.text);
      });
    }
  }

  String? _validateName(String? value) {
    if (value!.isEmpty) {
      return 'Name is required';
    } else if (value.length > 50) {
      return 'Name must not exceed 50 characters';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value!.isEmpty) {
      return 'Phone Number is required';
    } else if (value.length > 20) {
      return 'Phone Number must not exceed 20 characters';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value!.isEmpty) {
      return 'password is required';
    } else if (value.length > 50) {
      return 'password must not exceed 50 characters';
    } else if (value.length < 8) {
      return 'password min length 8 characters';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    if (user != null) {
      Language? language = languageMap[user!.language] ?? Language.en; 

      nameController.text = user!.name;
      passwordController.text = user!.password;
      phoneNumberController.text = user!.phonenumber;
      addressController.text = user!.address;
      isAdmin = user!.isAdmin;
      selectedLanguage = language;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            PageTitle(title: user == null ? 'Add Account' : 'Update Account'),
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      validator: _validateName,
                      decoration: InputDecoration(
                        labelText: 'Name (Max 50 characters)',
                        errorText: nameError,
                      ),
                      maxLength: 50,
                    ),
                    TextFormField(
                      controller: passwordController,
                      validator: _validatePassword,
                      decoration: InputDecoration(
                        labelText: 'Password (Min 8 characters)',
                        errorText: passwordError,
                      ),
                      maxLength: 50,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: phoneNumberController,
                      validator: _validatePhoneNumber,
                      decoration: InputDecoration(
                        labelText: 'Phone Number (Max 20 characters)',
                        errorText: phoneNumberError,
                      ),
                      maxLength: 20,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'Address (Max 300 characters)',
                      ),
                      maxLength: 300,
                      maxLines: 4, // Text area with 4 lines
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text('Is Admin:'),
                        SizedBox(width: 10),
                        Switch(
                          value: isAdmin,
                          onChanged: (value) {
                            setState(() {
                              isAdmin = value;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text('Language:'),
                        SizedBox(width: 10),
                        DropdownButton<Language>(
                          value: selectedLanguage,
                          items: Language.values.map((lang) {
                            return DropdownMenuItem<Language>(
                              value: lang,
                              child: Text(lang.languageText),
                            );
                          }).toList(),
                          onChanged: (Language? newValue) {
                            setState(() {
                              selectedLanguage = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                )),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _cancel,
                  child: Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _submitForm(),
                  child:
                      Text(user == null ? 'Create Account' : "Update Account"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        )),
      ),
      bottomNavigationBar: AdminNavBar(current_page_tag: AccountsPage.tag),
    );
  }
}
