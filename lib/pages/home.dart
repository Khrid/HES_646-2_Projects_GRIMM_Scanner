import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:grimm_scanner/assets/constants.dart';
import 'package:grimm_scanner/pages/accounts_admin.dart';
import 'package:grimm_scanner/pages/items_detail.dart';
import 'package:grimm_scanner/widgets/button_home.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'accounts_admin.dart';
import 'items_admin.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _qrCode = 'Unknown';

  String _connectionStatus = 'Unknown';
  bool connectionLost = false;
  late ConnectivityResult previousState;
  late final bool _firstLaunch;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  Future<bool> isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("first_time", true); // activer pour reset le first_time
    bool isFirstTime = prefs.getBool('first_time') ?? false;
    if (isFirstTime) {
      print('premier lancement, on switch la variable');
      setState(() {
        _firstLaunch = true;
      });
      prefs.setBool('first_time', false);
      // si on a internet lors du premier lancement
      bool hasInternet = await InternetConnectionChecker().hasConnection;
      if(!await InternetConnectionChecker().hasConnection) {
        print('First launch but no Internet, sync needed later');
        prefs.setBool("sync_needed", true);
      }
      forceLocalSync();
      return false;
    }
    return false;
  }

  void forceLocalSync() {
    print('Force sync Firebase');
    FirebaseFirestore.instance.collection("items").snapshots();
    FirebaseFirestore.instance.collection("category").snapshots();
    FirebaseFirestore.instance.collection("history").snapshots();
    FirebaseFirestore.instance.collection("users").snapshots();
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    initConnectivity();
    isFirstTime();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Menu"),
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
            child: SingleChildScrollView(
                child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CustomHomeButton(title: "SCANNER", onPressed: scanQR),
                const SizedBox(
                  height: 10.0,
                ),
                CustomHomeButton(
                    title: "Gérer les utilisateurs",
                    onPressed: navigateToUsersAdmin),
                const SizedBox(
                  height: 10.0,
                ),
                CustomHomeButton(
                    title: "Gérer l'inventaire",
                    onPressed: navigateToItemsAdmin)
              ],
            ),
          ],
        )))
        //drawer: const CustomDrawer(),
        );
  }

  Future<void> navigateToUsersAdmin() async {
    setState(() {
      Navigator.pushNamed(context, AccountsAdmin.routeName);
    });
  }

  Future<void> navigateToItemsAdmin() async {
    setState(() {
      Navigator.pushNamed(context, ItemsAdmin.routeName);
    });
  }

  Future<void> fakeScan() async {
    setState(() {
      _qrCode = Constants.grimmQrCodeStartsWith + "1VEx5uRRtuUVk8Bf7597";
      // on passe à l'écran de détail d'un objet, en transmettant le qr plus loin
      Navigator.pushNamed(context, ItemDetail.routeName, arguments: _qrCode);
    });
  }

  Future<void> scanQR() async {
    // La librairie QR n'est pas prévue pour le web, il faut informer au cas où
    if (!kIsWeb) {
      print("scanQR called");
      String barcodeScanRes;
      // Platform messages may fail, so we use a try/catch PlatformException.
      try {
        barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
            '#ff6666', 'Cancel', true, ScanMode.QR);
        print(barcodeScanRes);
      } on PlatformException {
        barcodeScanRes = 'Failed to get platform version.';
      }

      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;

      // Quand on reconnait un code QR
      setState(() {
        // S'il commence bien par la chaine "QRGRIMM_" (pour être sûr de ne
        // travailler uniquement avec un QR de notre application
        if (barcodeScanRes.startsWith(Constants.grimmQrCodeStartsWith)) {
          // on le stocke dans la variable du state
          _qrCode = barcodeScanRes;
          // on passe à l'écran de détail d'un objet, en transmettant le qr plus loin
          Navigator.pushNamed(context, ItemDetail.routeName,
              arguments: _qrCode);

          // Sinon s'il est égal à -1 (quand l'utilisateur appuie sur "annuler"
          // depuis l'écran de scannage
        } else if (barcodeScanRes == "-1") {
          // on affiche un message indiquant que l'action a été annulée
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Lecture QR annulée.")));

          // sinon
        } else {
          // on affiche un message indiquant qu'on ne gère pas ce code QR
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("QR code scanné non géré par cette application.")));
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "La lecture QR n'est possible que depuis l'application native Android / iOS.")));
    }
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    // si on a du réseau (mais pas forcément internet...)
    print("connection lost : " + connectionLost.toString());
    print("connectivity result : " + result.toString());
    if (result != ConnectivityResult.none) {
      // check si on a internet
      bool hasInternet = await InternetConnectionChecker().hasConnection;
      print("has internet : " + hasInternet.toString());
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (hasInternet && connectionLost) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool syncNeeded = prefs.getBool("sync_needed") ?? false;
        if(syncNeeded) {
          forceLocalSync();
          prefs.setBool("sync_needed", false);
        }
        connectionLost = false;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Connexion rétablie!",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 5),
          backgroundColor: Color(0xFF1CB731),
        ));
      }
    } else {
      connectionLost = true;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Pas de connexion disponible.",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        duration: Duration(days: 365),
        backgroundColor: Color(0xFFB71C1C),
      ));
    }
  }
}
