import 'dart:async';
import 'package:alquran/sura/ui/sura_screen.dart';
import 'package:flutter/material.dart';

import 'config/asset.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _timer();
    super.initState();
  }

  void _timer(){
    Timer(Duration(seconds: 3), (){
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
          SuraScreen(title: "SURAT",)), (Route<dynamic> route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {

    var scaffold = Scaffold(
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 100),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(Asset.LOGO,),
                LinearProgressIndicator(
                  backgroundColor: Theme.of(context).primaryColorLight,
                  valueColor: AlwaysStoppedAnimation<Color>( Theme.of(context).primaryColorDark),
                ),
              ]
          ),
        )
    );

    return scaffold;
  }
}