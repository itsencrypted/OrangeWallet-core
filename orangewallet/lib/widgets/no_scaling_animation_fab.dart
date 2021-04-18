import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class NoScalingAnimation extends FloatingActionButtonAnimator {
  @override
  Offset getOffset({Offset begin, Offset end, double progress}) {
    return end;
  }

  @override
  Animation<double> getRotationAnimation({Animation<double> parent}) {
    return Tween<double>(begin: 5, end: 5).animate(parent);
  }

  @override
  Animation<double> getScaleAnimation({Animation<double> parent}) {
    return Tween<double>(begin: 5, end: 5).animate(parent);
  }
}
