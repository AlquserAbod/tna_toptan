import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tna_toptan/Crud/OrderCrud.dart';
import 'package:tna_toptan/Helpers/DialogHelper.dart';
import 'package:tna_toptan/Helpers/OrderHelper.dart';
import 'package:tna_toptan/components/LoadingWidget.dart';
import 'package:tna_toptan/components/page_title.dart';
import 'package:tna_toptan/layout/bottomNavBar.dart';
import 'package:tna_toptan/Crud/AccountsCrud.dart';
import 'package:tna_toptan/pages/OrderDetailsPage.dart';

class OrdersListPage extends StatefulWidget {
  static String tag = 'orders';

  @override
  _OrdersListPageState createState() => new _OrdersListPageState();
}

class _OrdersListPageState extends State<OrdersListPage> {
  final TextEditingController nameSearchController = TextEditingController();

  Stream<QuerySnapshot<Object?>> orders = OrderCrud.getOrders();
  
  Widget orderRow(OrderCrud? order) {
    return Column(
      children: [
        SizedBox(height: 30),
        ListTile(
          title: Text(order!.productName),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder(
                    future: AccountsCrud.read(order.accountId ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Text(
                            'Salary :' + snapshot.data!.name);
                      }
                      return SizedBox();
                    }),
                Text('Order state : ' + order.state.orderText),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => 
                  DialogHelper.updateStateDialog(context, order).show(),
              ),
              IconButton(
                icon: Icon(Icons.info),
                color: Colors.amber,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                    return OrderDetailsPage(orderId: order.id ?? "",isAdminPage: true);
                  }));
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Bottom Nav Bar

    return Scaffold(
      body: StreamBuilder(
        stream: orders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return LoadingWidget();
          else if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          else if (!snapshot.hasData) return Text('No data available.');
          else {
            final documents = snapshot.data!.docs;
            final filteredDocuments = OrdersHelper.filterDocuments(
                documents, searchText:  nameSearchController.text);

            return Column(
              children: [
                PageTitle(title: 'Orders'),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15), // Adjust the horizontal padding as needed
                  child: TextField(
                    controller: nameSearchController,
                    decoration: InputDecoration(
                      labelText: 'Search by name',
                    ),
                    onChanged: (text) {
                      setState(() {
                      });
                    },
                  ),
                ),
                    
              
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  itemCount: filteredDocuments.length,
                  itemBuilder: (context, index) {
                    final document = filteredDocuments[index];
                    return FutureBuilder(
                      future: OrderCrud.getOrderById(document.id),
                      builder: (BuildContext context, snapshot) {

                         if (snapshot.connectionState == ConnectionState.done) {
                           return orderRow(snapshot.data);
                        }
                        return SizedBox();
                      });
                  },
                ),
              ),
            ],
            );
          }
        },
      ),
      bottomNavigationBar: AdminNavBar(current_page_tag: OrdersListPage.tag),
    );
  }


}
