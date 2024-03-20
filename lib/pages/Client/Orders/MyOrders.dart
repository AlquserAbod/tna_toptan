
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:tna_toptan/AuthServeice.dart';
import 'package:tna_toptan/Crud/OrderCrud.dart';
import 'package:tna_toptan/Helpers/DialogHelper.dart';
import 'package:tna_toptan/Helpers/OrderHelper.dart';
import 'package:tna_toptan/components/LoadingWidget.dart';
import 'package:tna_toptan/components/page_title.dart';
import 'package:tna_toptan/layout/bottomNavBar.dart';

import 'package:tna_toptan/pages/OrderDetailsPage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



// ignore: must_be_immutable
class MyOrders extends StatefulWidget {
  static String tag = 'my-orders';
  String? currentUserId = null;

  @override
  _MyOrdersState createState() => new _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  final TextEditingController nameSearchController = TextEditingController();

  late Stream<QuerySnapshot<Object?>> orders;
  List<String> data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    orders = OrderCrud.getOrders();
    AuthService.currentUserId().then((result) {
      setState(() {
        currentUserId = result;
      });
    });
  }

  String? currentUserId;



  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    Widget orderRow(document) {
      OrderCrud order = OrdersHelper.createCrudObject(document);
      return Column(
        children: [
          SizedBox(height: 30),
          ListTile(
            title: Text(order.productName),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l.order_state} : ' + OrdersHelper.getStateTranslateText(order.state,context)),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (order.state == OrderState.inProcess)
                  IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () => 
                    DialogHelper.orderDeleteConfirmationDialog(
                      context,order,
                      onDelete: () => {Navigator.of(context).pop()}
                      ).show(),
                  ),
                IconButton(
                  icon: Icon(Icons.info),
                  color: Colors.amber,
                  onPressed: () => {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (conext) {
                          return OrderDetailsPage(orderId: order.id ?? '');
                        },
                      )
                    )
                  },
                ),
              ],
            ),
          )
        ],
      );
    }
     

    
    return Scaffold(
       body: StreamBuilder<QuerySnapshot>(
        stream: orders,
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) return LoadingWidget();
          else if (snapshot.hasError) return Text('${l.error}');
          else if (!snapshot.hasData) return Text(l.no_data);
          else {
            final documents = snapshot.data!.docs;

            final filteredDocuments = OrdersHelper.filterDocuments(documents,
                searchText: nameSearchController.text,
                currentUserOrders: true,
                currentUserId: currentUserId);

            return Column(
              children: [
                PageTitle(title: l.my_orders),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    controller: nameSearchController,
                    decoration: InputDecoration(
                      labelText: l.search_by_productName,
                    ),
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    itemCount: filteredDocuments.length,
                    itemBuilder: (context, index) {
                      return orderRow(filteredDocuments[index]);
                    }
                  ),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: ClientNavBar(current_page_tag: MyOrders.tag) ,
    );
  }

}
