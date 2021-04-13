import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/theme_data.dart';

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.paddingHeight12),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SvgPicture.asset(appLandingSvg),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
