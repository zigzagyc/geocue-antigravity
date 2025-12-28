// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MapController)
const mapControllerProvider = MapControllerProvider._();

final class MapControllerProvider
    extends $AsyncNotifierProvider<MapController, Set<Marker>> {
  const MapControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapControllerHash();

  @$internal
  @override
  MapController create() => MapController();
}

String _$mapControllerHash() => r'6e0b07e252dd13cb72aabf3262393a724dad8f9a';

abstract class _$MapController extends $AsyncNotifier<Set<Marker>> {
  FutureOr<Set<Marker>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<Set<Marker>>, Set<Marker>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<Marker>>, Set<Marker>>,
              AsyncValue<Set<Marker>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
