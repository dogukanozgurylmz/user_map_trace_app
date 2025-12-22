import 'package:flutter_cache_manager/flutter_cache_manager.dart';

final class NetworkImageCacheManager extends CacheManager {
  static final NetworkImageCacheManager instance =
      NetworkImageCacheManager._internal();

  /// default cache key
  static const String _defaultKey = 'customCacheKey';

  NetworkImageCacheManager._internal()
      : super(
          Config(
            _defaultKey,
            stalePeriod: const Duration(days: 3),
            maxNrOfCacheObjects: 190,
          ),
        );

  /// Creates cache manager with custom configuration
  factory NetworkImageCacheManager.custom({
    String key = _defaultKey,
    Duration stalePeriod = const Duration(days: 3),
    int maxNrOfCacheObjects = 190,
  }) {
    return NetworkImageCacheManager._customConfig(
      key: key,
      stalePeriod: stalePeriod,
      maxNrOfCacheObjects: maxNrOfCacheObjects,
    );
  }

  /// Private constructor with custom configuration
  NetworkImageCacheManager._customConfig({
    required String key,
    required Duration stalePeriod,
    required int maxNrOfCacheObjects,
  }) : super(
          Config(
            key,
            stalePeriod: stalePeriod,
            maxNrOfCacheObjects: maxNrOfCacheObjects,
          ),
        );

  /// Clears cache
  Future<void> clearCache() async {
    await emptyCache();
  }
}
