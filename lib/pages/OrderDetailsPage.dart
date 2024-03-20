import 'package:flutter/material.dart';
import 'package:tna_toptan/Crud/OrderCrud.dart';
import 'package:tna_toptan/Helpers/DialogHelper.dart';
import 'package:tna_toptan/components/LoadingWidget.dart';
import 'package:tna_toptan/components/page_title.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tna_toptan/layout/bottomNavBar.dart';
import 'package:tna_toptan/pages/Admin/Orders/OrdersListPage.dart';
import 'package:tna_toptan/pages/Client/Orders/MyOrders.dart';

// ignore: must_be_immutable
class OrderDetailsPage extends StatefulWidget {
  static String tag = 'orders_details';
  String? currentUserId = null;
  final String orderId;
  final bool isAdminPage;

  OrderDetailsPage({required this.orderId, this.isAdminPage = false});

  @override
  _OrderDetailsPageState createState() => new _OrderDetailsPageState(orderId: orderId,isAdminPage: isAdminPage);
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  
  String orderId;
  bool isAdminPage;
  late Future<OrderCrud?> futureOrder;
  
  _OrderDetailsPageState({required this.orderId, required this.isAdminPage});

  @override
  void initState() {
    super.initState();
    futureOrder = OrderCrud.getOrderById(orderId);
    isAdminPage =false;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    
    return Scaffold(
        bottomNavigationBar: isAdminPage ? 
          AdminNavBar(current_page_tag: OrdersListPage.tag,) :
          ClientNavBar(current_page_tag: MyOrders.tag,),
        body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: FutureBuilder(
          future:  futureOrder,
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) return LoadingWidget();
            else if (snapshot.hasError) return Center(child: Text('${l.error}: ${snapshot.error}'));
            else if (!snapshot.hasData) return Center(child: Text(l.no_data));
            else {
              OrderCrud order = snapshot.data!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageTitle(title: l.order_details),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        Image.network(
                          order.imagePath,
                          width: 283,
                          height: 200,
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            }
                          },
                          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                            return Text('Failed to load image'); // You can show any custom error message here
                          },
                          )
                    
                  ]),
                  SizedBox(height: 20),
                  Text('${l.product_name}: ${order.productName}'),
                  SizedBox(height: 10),
                  Text('${l.count}: ${order.count.toString()}'),
                  SizedBox(height: 10),
                  Text('${l.notes}: ${order.notes}'),
                  SizedBox(height: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    // Close Page Button\
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        shape: BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: Text(l.close)
                    ),

                    // Update State Page
                    isAdminPage ?
                      ElevatedButton(onPressed: () => DialogHelper.updateStateDialog(context, order).show(), 
                      style: ElevatedButton.styleFrom(
                        shape: BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: Text("Update State")) 
                    : SizedBox(),

                    //Delete Order Page
                    !isAdminPage  && order.state == OrderState.inProcess?
                      ElevatedButton(onPressed: () =>  DialogHelper.orderDeleteConfirmationDialog(context,order).show(), 
                      style: ElevatedButton.styleFrom(
                        shape: BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                        backgroundColor: Colors.red,
                      ),
                      child: Text(l.delete_order))
                    : SizedBox(),
                  ],)
                ],
              );
            }})));
        
        }
      }

