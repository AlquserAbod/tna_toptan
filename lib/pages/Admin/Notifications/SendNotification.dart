import 'package:flutter/material.dart';
import 'package:tna_toptan/Helpers/DialogHelper.dart';
import 'package:tna_toptan/Helpers/MessageingHelper.dart';
import 'package:tna_toptan/components/page_title.dart';
import 'package:tna_toptan/layout/BottomNavBar.dart';

class SendNotificationPage extends StatefulWidget {
  static String tag = 'send-notification';

  @override
  _SendNotificationPageState createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController titleEnController = TextEditingController();
  final TextEditingController titleArController = TextEditingController();
  final TextEditingController titleTrController = TextEditingController();
  final TextEditingController bodyEnController = TextEditingController();
  final TextEditingController bodyTrController = TextEditingController();
  final TextEditingController bodyArController = TextEditingController();

  String? validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter the $fieldName.';
    }
    return null;
  }

  void sendNotification() {
    if (_formKey.currentState!.validate()) {
      // Push Notifiction
        //English
        MessageingHelper(
          title: titleEnController.text,
          body: bodyEnController.text,
        ).sendMessageToTopic("clients_en", NotificationType.reminder);

        //Arabic 
        MessageingHelper(
          title: titleArController.text,
          body: bodyArController.text,
        ).sendMessageToTopic("clients_ar", NotificationType.reminder);

        //Turkish 
        MessageingHelper(
          title: titleTrController.text,
          body: bodyTrController.text,
        ).sendMessageToTopic("clients_tr", NotificationType.reminder);



      DialogHelper.notificationSendedDialog(context).show();

      // Clear all controllers
        titleEnController.clear();
        titleTrController.clear();
        titleArController.clear();
        bodyEnController.clear();
        bodyTrController.clear();
        bodyArController.clear();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageTitle(title: 'Send Notification'),

              SizedBox(height: 24.0),
              TextFormField(
                controller: titleEnController,
                decoration: InputDecoration(
                  labelText: 'Title (English)',
                ),
                validator: (value) => validateField(value, 'En title'),
              ),

              SizedBox(height: 16.0),
              TextFormField(
                controller: titleArController,
                decoration: InputDecoration(
                  labelText: 'Title (Arabic)',
                ),
                validator: (value) => validateField(value, 'Ar title'),
              ),

              SizedBox(height: 16.0),
              TextFormField(
                controller: titleTrController,
                decoration: InputDecoration(
                  labelText: 'Title (Turkish)',
                ),
                validator: (value) => validateField(value, 'Tr title'),
              ),


              SizedBox(height: 24.0),
              TextFormField(
                controller: bodyEnController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Body (English)',
                ),
                validator: (value) => validateField(value, 'En Body'),
              ),

              
              SizedBox(height: 16.0),
              TextFormField(
                controller: bodyArController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Body (Arabic)',
                ),
                validator: (value) => validateField(value, 'Ar Body'),
              ),

              SizedBox(height: 16.0),
              TextFormField(
                controller: bodyTrController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Body (Turkish)',
                ),
                validator: (value) => validateField(value, 'Tr Body'),
              ),



              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: sendNotification,
                child: Text('Send Message'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AdminNavBar(current_page_tag: SendNotificationPage.tag),
    );
  }
}

