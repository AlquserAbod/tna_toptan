import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tna_toptan/AuthServeice.dart';
import 'package:tna_toptan/Crud/OrderCrud.dart';
import 'package:tna_toptan/Helpers/DialogHelper.dart';
import 'package:tna_toptan/components/page_title.dart';
import 'package:tna_toptan/layout/bottomNavBar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tna_toptan/main.dart';

class AddOrder extends StatefulWidget {
  static String tag = 'add-order';

  @override
  _AddOrderPageState createState() => new _AddOrderPageState();
}

class _AddOrderPageState extends State<AddOrder> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController countController = TextEditingController(text: '1');
  File? _selectedImage;

  String? productNameError;
  String? notesError;
  String? countError;

  _deleteSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  void initState() {
    super.initState();
    setLocale();
  }

  Future<void> setLocale() async {
    final user = await AuthService.currentUser();
    MyApp.changeLocale(context, user!.language.name);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
  
    void _createOrder() async {
      String? image_url = '';
      if(!_formKey.currentState!.validate()) return;
      if (_selectedImage != null) {
        image_url = await OrderCrud.saveImageOnStorage(_selectedImage!);
      }

      OrderCrud ordercrud = OrderCrud(
          productName: productNameController.text,
          imagePath: image_url,
          count: int.parse(countController.text),
          notes: notesController.text
      );

      ordercrud.createOrder();
      
      DialogHelper.orderCreatedDialog(context,onPressOk: () {
        setState(() {
          _formKey.currentState?.reset();
          productNameController.clear(); // Clears the specific field value
          notesController.clear(); // Clears the specific field value
          countController.clear(); // Clears the specific field value
        });
        _deleteSelectedImage();
      }).show();
    }
      
  Widget upload_image_field() {
      final upload_photo_button = ElevatedButton(
        onPressed: () => DialogHelper.uploadImageDialog(context,(File pickedImage) {
          setState(() {
            _selectedImage = File(pickedImage.path);
          });
        }).show(),
        child: Text(_selectedImage == null
            ? l.upload_product_image
            : l.edit_product_image),
      );

      final delete_photo_button = ElevatedButton(
        onPressed: () => _deleteSelectedImage(),
        
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
        ),
        child: Text(l.delete_product_image),
      );

      List<Widget> buttons_components() {
        return _selectedImage == null
            ? [upload_photo_button]
            : [
                upload_photo_button,
                SizedBox(
                  width: 10,
                ),
                delete_photo_button
              ];
      }

      return Container(
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: buttons_components(),
              )),
              
              SizedBox(
                height: 5,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _selectedImage == null
                      ? Text(l.no_image_selected)
                      : Image.file(
                          _selectedImage!,
                          width: 200,
                          height: 200,
                        )
                ],
              )
            ],
          ),
        ),
      );
    }


  String? _validateProductName(String? value) {
    int max_characters = 100;
    if (value!.isEmpty) {
      return l.field_required(l.product_name);
    } else if (value.length > max_characters) {
      return l.field_max_characters_error(l.product_name, max_characters);
    }
    return null;
  }

  String? _validateNotes(String? value) {
    int max_characters = 300;
    if (value!.isEmpty) {
      return l.field_required(l.notes);
    } else if (value.length > max_characters) {
      return l.field_max_characters_error(l.notes, max_characters);
    }
    return null;
  }

  String? _validateCount(String? value) {
    int max_characters = 5;
    if (int.parse(value!) <= 0) {
      return l.min_count(1);
    } else if (value.length > max_characters) {
      return l.field_max_count_error(l.count, max_characters);
    }
    return null;
  }

  return Scaffold(
      body: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
              child: Column(children: <Widget>[
            PageTitle(title: l.place_order),
            Form(
                key: _formKey,
                child: Column(children: [
                  // Product Name Field
                  TextFormField(
                    controller: productNameController,
                    validator: _validateProductName,
                    decoration: InputDecoration(
                      labelText:
                          '${l.product_name}, ${l.enter_details}  (${l.max_characters(100)})',
                      errorText: productNameError,
                    ),
                    maxLength: 100,
                    maxLines: 3,
                  ),

                  SizedBox(height: 10),

                  upload_image_field(),

                  SizedBox(height: 10),

                  // Count Field
                  TextFormField(
                    controller: countController,
                    validator: _validateCount,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(
                      labelText: '${l.count} (${l.min_count(1)})',
                    ),
                    maxLength: 5,
                  ),

                  TextFormField(
                    controller: notesController,
                    validator: _validateNotes,
                    decoration: InputDecoration(
                      labelText: '${l.notes} (${l.max_characters(300)})',
                      errorText: notesError,
                    ),
                    maxLength: 300,
                    maxLines: 7,
                  ),

                  SizedBox(height: 10),
                ])),
            SizedBox(height: 10),
            Center(
                child: ElevatedButton(
              onPressed: _createOrder,
              child: Text(l.create_order),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ))
          ]))),
      bottomNavigationBar: ClientNavBar(current_page_tag: AddOrder.tag),
    );
  }
}
