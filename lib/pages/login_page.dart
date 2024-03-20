import 'package:flutter/material.dart';
import 'package:tna_toptan/AuthServeice.dart';
import 'package:tna_toptan/main.dart';
import 'package:tna_toptan/pages/Admin/Orders/OrdersListPage.dart';
import 'package:tna_toptan/pages/Client/Orders/AddOrder.dart';
// ignore_for_file: prefer_const_constructors

class LoginPage extends StatefulWidget {
  static String tag = 'login';

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    MyApp.changeLocale(context, 'en');
  }
  @override
  Widget build(BuildContext context) {

    final logo = Hero(
        tag: 'hero',
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 100,
          child: Image.asset(
            'assets/images/logo1.png',
            fit: BoxFit.fill,
          ),
        ));

    final name = TextFormField(
      keyboardType: TextInputType.text,
      controller: nameController,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Name',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );

    final password = TextFormField(
      autofocus: false,
      controller: passwordController,
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        } else if (value.length < 8) {
          return 'password min length 8 characters';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: ButtonTheme(
        minWidth: 200.0, // You can adjust the button width as needed
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.all(12),
          ),
          onPressed: () {
            final form = _formKey.currentState;
            if (form != null && form.validate()) {
              AuthService.login(nameController.text, passwordController.text).then((user) {
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    content: Container(
                      padding: const EdgeInsets.all(8),
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: const Center(
                        child:
                            Text('Please enter the correct name and password'),
                      ),
                    ),
                  ));
                } else {
                  bool isAdmin = user.isAdmin;
                  Widget next_page = isAdmin ? OrdersListPage() : AddOrder();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return next_page;
                      },
                    ),
                  );
                }
              });
            }
          },
          child: Text('Log In', style: TextStyle(color: Colors.white)),
        ),
      ),
    );

    return Scaffold(
      body: Center(
          child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            name,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 24.0),
            loginButton,
          ],
        ),
      )),
    );
  

  }
}
