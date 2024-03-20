import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tna_toptan/Crud/OrderCrud.dart';
import 'package:tna_toptan/Helpers/MessageingHelper.dart';
import 'package:tna_toptan/Crud/AccountsCrud.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OrdersHelper {
  String? id; // Remove the 'final' keyword to make it nullable
  String? accountId; // Remove the 'final' keyword to make it nullable
  final String? productName;
  final String? imagePath;
  final int? count;
  final String? notes;
  OrderState state;

  static CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');

  OrdersHelper(
      {this.productName,
      this.imagePath,
      this.count,
      this.notes,
      this.state = OrderState.inProcess,
      this.id});

  Future<void> updateState(OrderState state) async {
      await orders.doc(id).update({
        'state': state.orderValue,
      });
      final order = await orders.doc(id).get();
      final salary = await AccountsCrud.read(order.get('accountId'));

      if(order.get('state') != OrderState.inDistribution.orderValue){
        final stateChangedNotifiction = MessageingHelper( 
          title: "your order is moved !!",
          body: "your ${order.get('productName')} order ${OrderState.values[order['state']].orderText} "

        );
        stateChangedNotifiction.sendMessageToDevices(salary!.fcmTokens,NotificationType.orderStateUpdated,payload: {
          "orderId": order.id
        });

      }

  }

  Future<OrderCrud?> getOrderById(String orderId) async {
    try {
      DocumentSnapshot docSnapshot = await orders.doc(orderId).get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data =
            docSnapshot.data() as Map<String, dynamic>;
        return OrderCrud(
          productName: data['productName'],
          imagePath: data['imagePath'],
          count: data['count'],
          notes: data['notes'],
          state: data['state'],
        )..id = docSnapshot.id;
      } else {
        return null; // Document with the provided ID doesn't exist
      }
    } catch (e) {
      print('Error retrieving order data: $e');
      return null; // Handle error gracefully
    }
  }

  OrderState getStatebyName(stateName) {
    return OrderState.values.firstWhere(
        (state) => state.toString().split('.').last == stateName,
        orElse: () => OrderState.inProcess);
  }

  static dynamic filterDocuments(documents,
      {String searchText = '', bool currentUserOrders = false, String? currentUserId}) {
    final filteredDocuments = documents.where((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (currentUserOrders &&
          data['accountId'] != currentUserId) {
        return false;
      }
      final productName = data['productName'].toString().toLowerCase();
      return productName.startsWith(searchText.toLowerCase());
    }).toList();
    return filteredDocuments;
  }

  static OrderCrud createCrudObject(document) {
    return OrderCrud(
        productName: document['productName'],
        imagePath: document['productName'],
        count: document['count'],
        notes: document['notes'],
        accountId: document['accountId'],
        id: document.id,
        state: OrderState.values[document['state']]
    );
  }

    static String getStateTranslateText(OrderState state, BuildContext context) {
      final l = AppLocalizations.of(context);

      if (l == null) {
        return ''; // Return default value or handle null case
      }

      switch (state) {
        case OrderState.inProcess:
          return l.inProcess;
        case OrderState.received:
          return l.received;
        case OrderState.inDistribution:
          return l.inDistribution;
        case OrderState.rejected:
          return l.rejected;
        case OrderState.completed:
          return l.completed;
        default:
          return ''; // Default value for unknown state
      }
    }

}
