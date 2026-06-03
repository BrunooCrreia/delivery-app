import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_map/flutter_map.dart';

final _mapCacheManager = CacheManager(
  Config(
    'mapTilesCache',
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 2000,
  ),
);

class CachedTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return CachedNetworkImageProvider(
      getTileUrl(coordinates, options),
      cacheManager: _mapCacheManager,
    );
  }
}
