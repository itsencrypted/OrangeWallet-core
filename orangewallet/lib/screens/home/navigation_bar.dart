/*
 *    Copyright 2019 Pedro Massango
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * A few modifications made to save have all expanded tabs.
 */

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:orangewallet/theme_data.dart';

class BottomNavBar extends StatelessWidget {
  BottomNavBar({
    Key key,
    this.selectedIndex = 0,
    this.showElevation = true,
    this.iconSize = 24,
    this.backgroundColor,
    this.itemCornerRadius = 40,
    this.containerHeight = 70,
    this.animationDuration = const Duration(milliseconds: 270),
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    @required this.items,
    @required this.onItemSelected,
    this.curve = Curves.linear,
  })  : assert(items != null),
        assert(items.length >= 2 && items.length <= 5),
        assert(onItemSelected != null),
        assert(animationDuration != null),
        assert(curve != null),
        super(key: key);

  /// The selected item is index. Changing this property will change and animate
  /// the item being selected. Defaults to zero.
  final int selectedIndex;

  /// The icon size of all items. Defaults to 24.
  final double iconSize;

  /// The background color of the navigation bar. It defaults to
  /// [Theme.bottomAppBarColor] if not provided.
  final Color backgroundColor;

  /// Whether this navigation bar should show a elevation. Defaults to true.
  final bool showElevation;

  /// Use this to change the item's animation duration. Defaults to 270ms.
  final Duration animationDuration;

  /// Defines the appearance of the buttons that are displayed in the bottom
  /// navigation bar. This should have at least two items and five at most.
  final List<BottomNavBarItem> items;

  /// A callback that will be called when a item is pressed.
  final ValueChanged<int> onItemSelected;

  /// Defines the alignment of the items.
  /// Defaults to [MainAxisAlignment.spaceBetween].
  final MainAxisAlignment mainAxisAlignment;

  /// The [items] corner radius, if not set, it defaults to 50.
  final double itemCornerRadius;

  /// Defines the bottom navigation bar height. Defaults to 56.
  final double containerHeight;

  /// Used to configure the animation curve. Defaults to [Curves.linear].
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final bgColor = (backgroundColor == null)
        ? Theme.of(context).bottomAppBarColor
        : backgroundColor;

    return Container(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            decoration: BoxDecoration(
                color: bgColor,
                boxShadow: [
                  if (showElevation)
                    const BoxShadow(
                      color: Colors.white24,
                      blurRadius: 20,
                    ),
                ],
                borderRadius: BorderRadius.circular(itemCornerRadius)),
            height: containerHeight,
            child: Center(
              child: Container(
                width: double.infinity,
                height: 70,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                child: Row(
                  mainAxisAlignment: mainAxisAlignment,
                  children: items.map((item) {
                    var index = items.indexOf(item);
                    return GestureDetector(
                      onTap: () => onItemSelected(index),
                      child: _ItemWidget(
                        item: item,
                        iconSize: iconSize,
                        isSelected: index == selectedIndex,
                        backgroundColor: bgColor,
                        itemCornerRadius: itemCornerRadius,
                        animationDuration: animationDuration,
                        curve: curve,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemWidget extends StatelessWidget {
  final double iconSize;
  final bool isSelected;
  final BottomNavBarItem item;
  final Color backgroundColor;
  final double itemCornerRadius;
  final Duration animationDuration;
  final Curve curve;

  const _ItemWidget({
    Key key,
    @required this.item,
    @required this.isSelected,
    @required this.backgroundColor,
    @required this.animationDuration,
    @required this.itemCornerRadius,
    @required this.iconSize,
    this.curve = Curves.linear,
  })  : assert(isSelected != null),
        assert(item != null),
        assert(backgroundColor != null),
        assert(animationDuration != null),
        assert(itemCornerRadius != null),
        assert(iconSize != null),
        assert(curve != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      selected: isSelected,
      child: AnimatedContainer(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width * 0.29,
        height: double.maxFinite,
        duration: animationDuration,
        curve: curve,
        decoration: BoxDecoration(
          color: isSelected ? item.activeColor.withOpacity(1) : backgroundColor,
          borderRadius: BorderRadius.circular(itemCornerRadius),
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.29,
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconTheme(
                    data: IconThemeData(
                      size: iconSize,
                      color: isSelected ? AppTheme.white : item.inactiveColor,
                    ),
                    child: item.icon,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        color: isSelected ? AppTheme.white : item.inactiveColor,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      textAlign: item.textAlign,
                      child: item.title,
                    ),
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

/// The [BottomNavBar.items] definition.
class BottomNavBarItem {
  BottomNavBarItem({
    @required this.icon,
    @required this.title,
    this.activeColor = AppTheme.primaryColor,
    this.textAlign,
    this.inactiveColor = Colors.black,
  })  : assert(icon != null),
        assert(title != null);

  /// Defines this item's icon which is placed in the right side of the [title].
  final Widget icon;

  /// Defines this item's title which placed in the left side of the [icon].
  final Widget title;

  /// The [icon] and [title] color defined when this item is selected. Defaults
  /// to [Colors.blue].
  final Color activeColor;

  /// The [icon] and [title] color defined when this item is not selected.
  final Color inactiveColor;

  /// The alignment for the [title].
  ///
  /// This will take effect only if [title] it a [Text] widget.
  final TextAlign textAlign;
}
