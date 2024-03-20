import 'package:flutter/material.dart';

class LogoutAlert extends StatelessWidget {
  final Function onLogout; // Callback function to execute on logout

  LogoutAlert({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Logout'),
      content: Text('Are you sure you want to logout?'),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
        TextButton(
          child: Text('Logout'),
          onPressed: () {
            onLogout(); // Call the logout function provided by the parent widget
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
      ],
    );
  }
}



