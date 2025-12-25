// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proximity_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProximityService)
const proximityServiceProvider = ProximityServiceProvider._();

final class ProximityServiceProvider
    extends $NotifierProvider<ProximityService, void> {
  const ProximityServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proximityServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proximityServiceHash();

  @$internal
  @override
  ProximityService create() => ProximityService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$proximityServiceHash() => r'3132ae9d8be62fbfcca339b61a1e3f8b2fd49698';

abstract class _$ProximityService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
