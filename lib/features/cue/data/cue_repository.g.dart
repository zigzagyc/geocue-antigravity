// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cue_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cueRepository)
const cueRepositoryProvider = CueRepositoryProvider._();

final class CueRepositoryProvider
    extends $FunctionalProvider<CueRepository, CueRepository, CueRepository>
    with $Provider<CueRepository> {
  const CueRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cueRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cueRepositoryHash();

  @$internal
  @override
  $ProviderElement<CueRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CueRepository create(Ref ref) {
    return cueRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CueRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CueRepository>(value),
    );
  }
}

String _$cueRepositoryHash() => r'9f8eedda07440a349a93aa50717766e0aa1c5123';
