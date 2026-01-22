// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locked_area_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lockedAreaRepository)
const lockedAreaRepositoryProvider = LockedAreaRepositoryProvider._();

final class LockedAreaRepositoryProvider
    extends
        $FunctionalProvider<
          LockedAreaRepository,
          LockedAreaRepository,
          LockedAreaRepository
        >
    with $Provider<LockedAreaRepository> {
  const LockedAreaRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lockedAreaRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lockedAreaRepositoryHash();

  @$internal
  @override
  $ProviderElement<LockedAreaRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LockedAreaRepository create(Ref ref) {
    return lockedAreaRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LockedAreaRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LockedAreaRepository>(value),
    );
  }
}

String _$lockedAreaRepositoryHash() =>
    r'36e3bfbdc10df04570659cb086422d3ef8cc7a24';
