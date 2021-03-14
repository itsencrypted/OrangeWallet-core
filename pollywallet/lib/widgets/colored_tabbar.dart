import 'package:flutter/material.dart';
import 'package:pollywallet/theme_data.dart';

class ColoredTabBar extends StatelessWidget implements PreferredSizeWidget {
  final double tabbarMargin;
  final double tabbarPadding;
  final double borderRadius;
  final Color color;
  final TabBar tabBar;
  ColoredTabBar(
      {this.color = AppTheme.grey,
      @required this.tabBar,
      this.tabbarMargin = AppTheme.paddingHeight,
      this.borderRadius = AppTheme.cardRadius,
      this.tabbarPadding = AppTheme.paddingHeight / 2});

  // @override
  // Size get preferredSize => Size(tabBar.preferredSize.width,
  //     tabBar.preferredSize.height + tabbarMargin + tabbarPadding);
  @override
  Size get preferredSize => Size(tabBar.preferredSize.width * 1,
      tabBar.preferredSize.height * 1.2 + tabbarMargin + tabbarPadding);

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.all(tabbarMargin),
        padding: EdgeInsets.all(tabbarPadding),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius), color: color),
        child: tabBar,
      );
}
