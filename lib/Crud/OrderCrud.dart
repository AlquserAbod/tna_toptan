import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tna_toptan/AuthServeice.dart';
import 'package:tna_toptan/Helpers/MessageingHelper.dart';
import 'package:tna_toptan/extentions/file_extensions.dart';

enum OrderState { inProcess, received, rejected, inDistribution,  completed }

List<Color> orderStateColors = [
  HexColor('#FF8C00'),
  HexColor('##008000'),
  HexColor('#FF0000'),
  HexColor('#4169E1'),
  HexColor('#4CAF50'),
];

extension OrderStateExtension on OrderState {
  int get orderValue {
    switch (this) {
      case OrderState.inProcess:
        return 0;
      case OrderState.received:
        return 1;
      case OrderState.rejected:
        return 2;
      case OrderState.inDistribution:
        return 3;
      case OrderState.completed:
        return 4;
      default:
        return 0; // Default value for unknown state
    }
  }

  String get orderText {

    switch (this) {
      case OrderState.inProcess:
        return 'in Process';
      case OrderState.received:
        return 'is Received';
      case OrderState.inDistribution:
        return 'in Distribution';
      case OrderState.rejected:
        return 'rejected';
      case OrderState.completed:
        return 'completed';
    }
  }
}

class OrderCrud {
  String? id; // Remove the 'final' keyword to make it nullable
  String? accountId; // Remove the 'final' keyword to make it nullable
  final String productName;
  final String imagePath;
  final int count;
  final String notes;
  OrderState state;

  OrderCrud(
      {required this.productName,
      required this.imagePath,
      required this.count,
      required this.notes,
      this.state = OrderState.inProcess,
      this.id,
      this.accountId});

  static CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');

  MessageingHelper _createOrderMessageingHelper = MessageingHelper(
      title: "طلب جديد",
      body: "الحمدالله! لقد نم طلب منتج ما 🤩");

  Future<void> createOrder() async {
    try {
      final account = await AuthService.currentUser();

      final docRef = await orders.add({
        'productName': productName,
        'imagePath': imagePath,
        'count': count,
        'notes': notes,
        'state': state.orderValue,
        'accountId': account!.id,
      });

      _createOrderMessageingHelper.sendMessageToTopic('admins',NotificationType.newOrder);
      // Get the ID after the document is created and set it to the 'id' field
      id = docRef.id;
      accountId = account.id;
    } catch (e) {
      print('Error creating order: $e');
    }
  }

  static Stream<QuerySnapshot<Object?>> getOrders() {
    final query = orders.orderBy('state');

    final querySnapshot = query.snapshots();

    return querySnapshot;
  }

  Future<void> updateOrder() async {
    try {
      await orders.doc(id).update({
        'productName': productName,
        'imagePath': imagePath,
        'count': count,
        'notes': notes,
      });
    } catch (e) {
      print('Error updating order: $e');
    }
  }

  static Future<void> deleteOrder(id) async {
    try {
      await orders.doc(id).delete();
    } catch (e) {
      print('Error deleting order: $e');
    }
  }

  static Future<String> saveImageOnStorage(File image) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');

    Reference reference = storage.ref().child('productImages/${image.name}');;
    UploadTask uploadTask = reference.putFile(image,metadata);
    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    return imageUrl;
  }

  static Future<OrderCrud?> getOrderById(String id) async {
      DocumentSnapshot orderSnapshot = await orders.doc(id).get();

      if (orderSnapshot.exists) {
        // Create an OrderCrud object from the document snapshot
        OrderCrud order = OrderCrud(
          id: orderSnapshot.id,
          accountId: orderSnapshot['accountId'],
          productName: orderSnapshot['productName'],
          imagePath: orderSnapshot['imagePath'],
          count: orderSnapshot['count'],
          notes: orderSnapshot.get('notes'),
          state: OrderState.values[orderSnapshot['state']],
          
        );

        return order;
      }
      return null;

  }
  // Function to get order data by document ID
}
