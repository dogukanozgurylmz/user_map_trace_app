enum AppIcons { test }

extension AppIconsExtension on AppIcons {
  String get fileName {
    switch (this) {
      case AppIcons.test:
        return 'test';
    }
  }

  String get assetPath => 'assets/icon/$fileName.svg';
}
