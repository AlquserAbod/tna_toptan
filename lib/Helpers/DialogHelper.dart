import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tna_toptan/AuthServeice.dart';
import 'package:tna_toptan/Crud/OrderCrud.dart';
import 'package:tna_toptan/Helpers/OrderHelper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tna_toptan/pages/Admin/Accounts/Accounts.dart';
import 'package:tna_toptan/pages/Admin/Accounts/AddUpdateAccountPage.dart';
import 'package:tna_toptan/Crud/AccountsCrud.dart';
import 'package:tna_toptan/pages/Client/Orders/MyOrders.dart';

class DialogHelper {

  static AwesomeDialog orderDeleteConfirmationDialog(
      BuildContext context, OrderCrud order, {Function? onDelete }) {
    final l = AppLocalizations.of(context)!;

    return AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: l.confirm_deletion,
      desc: l.order_deletion_confirm_message(order.productName),
      btnCancelOnPress: () {},
      btnCancelText: l.cancel,
      btnOkText: l.ok,
      btnOkOnPress: () {
        OrderCrud.deleteOrder(order.id);
        onDelete != null ? onDelete() : null;
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
          return MyOrders();
          } ));
      },
    );
  }

  static AwesomeDialog updateStateDialog(BuildContext context, OrderCrud order, {Function(OrderState)? onStateChange}) {
    OrdersHelper orderHelper = OrdersHelper(id: order.id);
    OrderState selectedOrderState = orderHelper.getStatebyName(order.state);

    return AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
  
      body: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("current order state is : ${order.state.orderText}"),
              SizedBox(height: 10,),
              DropdownButton<OrderState>(
                value: selectedOrderState,
                onChanged: (OrderState? newValue) {
                  setState(() {
                    selectedOrderState = newValue!;
                  });
                },
                items: OrderState.values.map((state) {
                  return DropdownMenuItem<OrderState>(
                    value: state,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: orderStateColors[state.index],
                          radius: 5,
                        ),
                        SizedBox(width: 10),
                        Text(state.toString().split('.').last),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        orderHelper.updateState(selectedOrderState);
        onStateChange != null ? onStateChange(selectedOrderState) : null;
      },
      btnCancelText: 'Close',
      btnOkText: 'Save',
    );
  }

  static AwesomeDialog uploadImageDialog(BuildContext context,Function(File)? onImagePicked) {
    final l = AppLocalizations.of(context)!;

    return AwesomeDialog(
        context: context,
        dialogType: DialogType.noHeader,
        body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (pickedImage == null) return;

                final File selectedImage = File(pickedImage.path);
                onImagePicked?.call(selectedImage);
                Navigator.of(context).pop();
              },
              child: Text(l.upload_from_gallery),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async{
                final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
                if (pickedImage == null) return;

                final File selectedImage = File(pickedImage.path);
                onImagePicked?.call(selectedImage);
                Navigator.of(context).pop();
              },
              child: Text(l.upload_from_camera),
            ),
          ],
        ),

      ),
      btnCancelText: l.cancel,
      btnCancelOnPress: () {},);
    }

  static AwesomeDialog orderCreatedDialog(BuildContext context,{Function()? onPressOk}){
    final l = AppLocalizations.of(context)!;

    return AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: l.order_complated,
        desc: l.order_complated_message,
        btnOkText: l.ok,
        btnOkOnPress: () {
          onPressOk != null ? onPressOk() : null;
        });
  }

  static AwesomeDialog notificationSendedDialog(BuildContext context,{Function()? onPressOk}){

    return AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: 'Notification Sended',
        desc: "Notifications were sent successfully",
        btnOkText: "ok",
        btnOkOnPress: () {
          onPressOk != null ? onPressOk() : null;
        });
  }
  
  static AwesomeDialog logoutConfirmDialog(BuildContext context,{Function()? onPressOk}){
    final l = AppLocalizations.of(context)!;

    return AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.scale,
        title: l.confirm_logout,
        desc: l.confirm_logout_message,
        btnCancelText: l.cancel,
        btnCancelColor: Colors.green,
        btnCancelOnPress: () {},
        btnOkText: l.ok,
        btnOkColor: Colors.red,
        btnOkOnPress: () {
          AuthService.sign_out();
          onPressOk != null ? onPressOk() : null;
        });
  }

  static AwesomeDialog accountDeleteConfirmationDialog(
      BuildContext context, AccountsCrud user, {Function? onDelete }) {

    return AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: "Confirm Deletion",
      desc: "Are you sure you want to delete the  ${user.name} Account ??",
      btnCancelOnPress: () {},
      btnCancelText:  "cancle",
      btnOkText: "ok",
      btnOkOnPress: () {
        user.delete();
        onDelete != null ? onDelete() : null;
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => AccountsPage(),));

      },
    );
  }

  static AwesomeDialog accountInfoDialogBuilder(
      BuildContext context, AccountsCrud user) {

    return AwesomeDialog(
    context: context,
    dialogType: DialogType.noHeader,
    animType: AnimType.scale,

    body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("${user.name} info", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('Password: ${user.password}'),
          Text('Phone Number: ${user.phonenumber}'),
          Text('Language: ${user.language.languageText}'),
          Text('Address: ${user.address}'),
          Row(
            children: [
              Text('is Admin :'),
              Icon(
                user.isAdmin ? Icons.check : Icons.cancel,
                color: user.isAdmin ? Colors.green : Colors.red,
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.bodyLarge,
                  backgroundColor: Colors.red, // Change color as needed
                  
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.bodyLarge,
                  backgroundColor: Colors.blue, // Change color as needed
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return AddUpdateAccountPage( user: user);
                      },
                    ),
                  );
                },
                child: const Text('Edit'),
              ),
            ],
          ),
        ],
      ),
    );

  }

  static AwesomeDialog accountCreatedDialog(BuildContext context){
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: "Account Created",
      desc: "Account successfully created.",
      btnOkOnPress: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => AccountsPage(),))
    );
  }

  static AwesomeDialog accountUpdatedDialog(BuildContext context){
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: "Account Updated",
      desc: "Account successfully updated.",
      btnOkOnPress: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => AccountsPage(),))
        ,
    );
  }
}