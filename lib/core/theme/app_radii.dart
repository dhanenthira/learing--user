import 'package:flutter/material.dart';

class AppRadii {
  static const double badge = 6.0;
  static const double input = 10.0;
  static const double button = 10.0;
  static const double cardSmall = 12.0;
  static const double cardStandard = 16.0;
  static const double cardLarge = 20.0;
  static const double modal = 20.0;
  static const double bottomSheet = 24.0;

  static const BorderRadius badgeRadius = BorderRadius.all(Radius.circular(badge));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(input));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(button));
  static const BorderRadius cardSmallRadius = BorderRadius.all(Radius.circular(cardSmall));
  static const BorderRadius cardStandardRadius = BorderRadius.all(Radius.circular(cardStandard));
  static const BorderRadius cardLargeRadius = BorderRadius.all(Radius.circular(cardLarge));
  static const BorderRadius modalRadius = BorderRadius.all(Radius.circular(modal));
  static const BorderRadius bottomSheetRadius = BorderRadius.only(
    topLeft: Radius.circular(bottomSheet),
    topRight: Radius.circular(bottomSheet),
  );
}
