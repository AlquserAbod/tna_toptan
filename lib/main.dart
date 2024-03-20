import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tna_toptan/AuthServeice.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:tna_toptan/firebase_options.dart';
import 'package:tna_toptan/pages/Admin/Accounts/Accounts.dart';
import 'package:tna_toptan/Helpers/MessageingHelper.dart';
import 'package:tna_toptan/pages/Admin/Accounts/AddUpdateAccountPage.dart';
import 'package:tna_toptan/pages/Admin/Notifications/SendNotification.dart';
import 'package:tna_toptan/pages/Admin/Orders/OrdersListPage.dart';
import 'package:tna_toptan/pages/Client/Orders/AddOrder.dart';
import 'package:tna_toptan/pages/Client/Orders/MyOrders.dart';
import 'package:tna_toptan/pages/OrderDetailsPage.dart';

import 'package:tna_toptan/pages/login_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Map<int, Color> primarycolorMap = {
  50: Color(0xFFE1F1FF),
  100: Color(0xFFB4DCFF),
  200: Color(0xFF82C9FF),
  300: Color(0xFF4EB4FF),
  400: Color(0xFF29A6FF),
  500: Color(0xFF00A7FD), // This is the main color
  600: Color(0xFF009CFC),
  700: Color(0xFF008DF9),
  800: Color(0xFF007EF6),
  900: Color(0xFF005DEE),
};


MaterialColor materialPrimaryColor = MaterialColor(0xFF00A7FD, primarycolorMap);


 
 onMessageOpenedApp(RemoteMessage? message) async{
  Map<String, dynamic> payload = json.decode(message!.data["payload"]);

  String notefictionType = message.data['notification-type'];

  if (notefictionType == NotificationType.orderStateUpdated.name) {
    try {
      String orderId = payload['orderId'];
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => OrderDetailsPage(orderId: orderId),
          ),
        );

    } catch (e) {
      print('Error while handling notification: $e');
    }
  }
 }

Future<Widget> get_home_page() async {
  final isLoggedin = await AuthService.isLoggedIn();
  final isAdminUser = await AuthService.isAdminUser();

  return !isLoggedin
      ? LoginPage()
      : isAdminUser!
          ? OrdersListPage()
          : AddOrder();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  MessageingHelper _messageingHelper = MessageingHelper();
  
  FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
//  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

  FirebaseMessaging.onMessage.listen(_messageingHelper.showFlutterNotification);

  await _messageingHelper.initNotification();

  print(await FirebaseMessaging.instance.getToken());
  // Get Language Code

  runApp(MyApp(
    home: await get_home_page(),
  ));

}

// ignore: must_be_immutable
class MyApp extends StatefulWidget {
  static Color primarycolor = Color(0xFF00A7FD); // This directly returns the primary color as a Color object

  Widget home;

  MyApp({required this.home});


  @override
  _MyAppState createState() =>   _MyAppState(home: home);

   static void changeLocale(BuildContext context, String newLocaleCode) {
    

    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    
    state?.changeLocale(newLocaleCode);
  }
}



// ignore: must_be_immutable
class _MyAppState extends State<MyApp> {
  Widget home;
  bool? isAdmin;
  Locale selectedLanguage = Locale('en');

  _MyAppState({required this.home});




  void changeLocale(String newLocaleCode) async{
    Future.delayed(Duration.zero, () {
      setState(() {
        selectedLanguage = Locale(newLocaleCode);
      });
    });
  }

  final routes = <String, WidgetBuilder>{
    AccountsPage.tag: (context) => AccountsPage(),
    LoginPage.tag: (context) => LoginPage(),
    AddUpdateAccountPage.tag: (context) => AddUpdateAccountPage(),
    OrdersListPage.tag: (context) => OrdersListPage(),
    MyOrders.tag: (context) => MyOrders(),
    AddOrder.tag: (context) => AddOrder(),
    SendNotificationPage.tag: (context) => SendNotificationPage(),
  };

  @override
  Widget build(BuildContext context) {

    
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('tr', ''),
        const Locale('ar', ''),
      ],
      locale: selectedLanguage,
      title: 'tna-toptan',
      theme: ThemeData(
      brightness: Brightness.light,
      primarySwatch: materialPrimaryColor,
      scaffoldBackgroundColor: Color.fromRGBO(238, 238, 238, 1),
      fontFamily: 'Nunito',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: materialPrimaryColor,
        scaffoldBackgroundColor: Color.fromRGBO(45, 45, 45, 1),
        fontFamily: 'Nunito',
      ),
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      home: home,
      navigatorKey: navigatorKey,
      routes: routes,
    );
  }
}
