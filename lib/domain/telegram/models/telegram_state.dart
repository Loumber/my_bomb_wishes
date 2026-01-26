import 'package:flutter/material.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

class TelegramState {
  final bool isSupported;
  final String? initData;
  final WebAppInitData? initDataUnsafe;
  final bool isVerticalSwipesEnabled;
  final String version;
  final String platform;
  final TelegramColorScheme colorScheme;
  final ThemeParams themeParams;
  final bool isActive;
  final bool isExpanded;
  final double viewportHeight;
  final double viewportStableHeight;
  final dynamic safeAreaInset;
  final dynamic contentSafeAreaInset;
  final Color headerColor;
  final Color backgroundColor;
  final Color bottomBarColor;

  TelegramState({
    required this.isSupported,
    this.initData,
    this.initDataUnsafe,
    required this.isVerticalSwipesEnabled,
    required this.version,
    required this.platform,
    required this.colorScheme,
    required this.themeParams,
    required this.isActive,
    required this.isExpanded,
    required this.viewportHeight,
    required this.viewportStableHeight,
    required this.safeAreaInset,
    required this.contentSafeAreaInset,
    required this.headerColor,
    required this.backgroundColor,
    required this.bottomBarColor,
  });

  TelegramState copyWith({
    bool? isSupported,
    String? initData,
    WebAppInitData? initDataUnsafe,
    bool? isVerticalSwipesEnabled,
    String? version,
    String? platform,
    TelegramColorScheme? colorScheme,
    ThemeParams? themeParams,
    bool? isActive,
    bool? isExpanded,
    double? viewportHeight,
    double? viewportStableHeight,
    dynamic safeAreaInset,
    dynamic contentSafeAreaInset,
    Color? headerColor,
    Color? backgroundColor,
    Color? bottomBarColor,
  }) {
    return TelegramState(
      isSupported: isSupported ?? this.isSupported,
      initData: initData ?? this.initData,
      initDataUnsafe: initDataUnsafe ?? this.initDataUnsafe,
      isVerticalSwipesEnabled: isVerticalSwipesEnabled ?? this.isVerticalSwipesEnabled,
      version: version ?? this.version,
      platform: platform ?? this.platform,
      colorScheme: colorScheme ?? this.colorScheme,
      themeParams: themeParams ?? this.themeParams,
      isActive: isActive ?? this.isActive,
      isExpanded: isExpanded ?? this.isExpanded,
      viewportHeight: viewportHeight ?? this.viewportHeight,
      viewportStableHeight: viewportStableHeight ?? this.viewportStableHeight,
      safeAreaInset: safeAreaInset ?? this.safeAreaInset,
      contentSafeAreaInset: contentSafeAreaInset ?? this.contentSafeAreaInset,
      headerColor: headerColor ?? this.headerColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      bottomBarColor: bottomBarColor ?? this.bottomBarColor,
    );
  }
}

