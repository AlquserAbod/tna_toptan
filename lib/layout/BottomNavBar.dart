import 'package:custom_line_indicator_bottom_navbar/custom_line_indicator_bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:tna_toptan/Helpers/DialogHelper.dart';
import 'package:tna_toptan/main.dart';
import 'package:tna_toptan/pages/Admin/Accounts/Accounts.dart';
import 'package:tna_toptan/pages/Admin/Notifications/SendNotification.dart';
import 'package:tna_toptan/pages/Admin/Orders/OrdersListPage.dart';
import 'package:tna_toptan/pages/Client/Orders/AddOrder.dart';
import 'package:tna_toptan/pages/Client/Orders/MyOrders.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


// ignore: must_be_immutable
class ClientNavBar extends StatelessWidget {
  String current_page_tag;
  final l = AppLocalizations.of(navigatorKey.currentState!.context)!;

  ClientNavBar({required this.current_page_tag});
  
  @override
  Widget build(BuildContext context) {


    int currentIndex = 0; 
    List<String> pageTags = ['add-order', 'my-orders', 'logout'];
    List<String> labels = [l.add_order,l.my_orders,l.logout];

    if (pageTags.contains(current_page_tag)) {
      currentIndex = pageTags.indexOf(current_page_tag);
    }
    
    return CustomLineIndicatorBottomNavbar(
                selectedColor: Colors.lightBlue,
                unSelectedColor: Colors.black54,
                backgroundColor: Colors.white,
                currentIndex: currentIndex,
                onTap: (index) {
                  switch (index) {
                    case 0:
                      Navigator.of(context).push(  MaterialPageRoute( builder: (context) => AddOrder() ));
                      break;
                    case 1:
                      Navigator.of(context).push(  MaterialPageRoute( builder: (context) => MyOrders() ));
                      break;
                    case 2:
                      DialogHelper.logoutConfirmDialog(context).show();
                      break;
                  }
                },
                enableLineIndicator: true,
                lineIndicatorWidth: 3,
                indicatorType: IndicatorType.Top,

                customBottomBarItems: [
                CustomBottomBarItems(
                    label: labels[0],
                    icon: Icons.store,
                ),
                CustomBottomBarItems(
                    label: labels[1],
                    icon: Icons.storage,
                ),
                CustomBottomBarItems(
                    label: labels[2],
                    icon: Icons.logout,
                ),
                ],
            );

  }
}

// ignore: must_be_immutable
class AdminNavBar extends StatelessWidget {
  String current_page_tag;

  AdminNavBar({required this.current_page_tag});

  @override
  Widget build(BuildContext context) {
    int currentIndex = 0; 
    List<String> pageTags = ['orders', 'accounts','send-notification', 'logout'];
    List<String> labels = ['Orders', 'Accounts', 'Send Notification', "Logout"];

    if (pageTags.contains(current_page_tag)) {
      currentIndex = pageTags.indexOf(current_page_tag);
    }

    return CustomLineIndicatorBottomNavbar(
                selectedColor: Colors.lightBlue,
                unSelectedColor: Colors.black54,
                backgroundColor: Colors.white,
                currentIndex: currentIndex,
                onTap: (index) {
                  switch (index) {
                    case 0:
                      Navigator.of(context).push(  MaterialPageRoute( builder: (context) => OrdersListPage() ));
                      break;
                    case 1:
                      Navigator.of(context).push(  MaterialPageRoute( builder: (context) => AccountsPage() ));
                      break;
                    case 2:
                      Navigator.of(context).push(  MaterialPageRoute( builder: (context) => SendNotificationPage() ));
                      break;
                    case 3:
                      DialogHelper.logoutConfirmDialog(context).show();
                      break;
                  }
                },
                enableLineIndicator: true,
                lineIndicatorWidth: 3,
                indicatorType: IndicatorType.Top,

                customBottomBarItems: [
                CustomBottomBarItems(
                    label: labels[0],
                    icon: Icons.store,
                ),
                CustomBottomBarItems(
                    label: labels[1],
                    icon: Icons.storage,
                ),
                CustomBottomBarItems(
                    label: labels[2],
                    icon: Icons.notification_add,
                ),
                CustomBottomBarItems(
                    label: labels[3],
                    icon: Icons.logout,
                ),
                ],
            );
  }
}

