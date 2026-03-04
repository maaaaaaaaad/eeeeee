import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef MapWidgetBuilder = Widget Function(double latitude, double longitude);

Widget _defaultMapBuilder(double latitude, double longitude) {
  final position = NLatLng(latitude, longitude);
  return NaverMap(
    options: NaverMapViewOptions(
      initialCameraPosition: NCameraPosition(
        target: position,
        zoom: 16,
      ),
      scrollGesturesEnable: false,
      zoomGesturesEnable: false,
      rotationGesturesEnable: false,
      tiltGesturesEnable: false,
    ),
    onMapReady: (controller) {
      controller.addOverlay(
        NMarker(id: 'selected', position: position),
      );
    },
  );
}

final mapWidgetBuilderProvider = Provider<MapWidgetBuilder>(
  (ref) => _defaultMapBuilder,
);

class MapPreview extends ConsumerWidget {
  final double latitude;
  final double longitude;

  const MapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final builder = ref.watch(mapWidgetBuilderProvider);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 200,
        child: builder(latitude, longitude),
      ),
    );
  }
}
