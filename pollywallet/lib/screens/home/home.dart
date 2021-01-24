import 'package:flutter/material.dart';
import 'package:pollywallet/screens/home/app_bar.dart';

class Home extends StatefulWidget{
  @override
  _HomeState createState() => _HomeState();
}
class _HomeState extends State<Home>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(),
      body: Container()

    );
  }

}