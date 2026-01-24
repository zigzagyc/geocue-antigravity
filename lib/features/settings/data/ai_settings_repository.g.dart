// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_settings_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(aiSettingsRepository)
const aiSettingsRepositoryProvider = AiSettingsRepositoryProvider._();

final class AiSettingsRepositoryProvider
    extends
        $FunctionalProvider<
          AiSettingsRepository,
          AiSettingsRepository,
          AiSettingsRepository
        >
    with $Provider<AiSettingsRepository> {
  const AiSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiSettingsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiSettingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<AiSettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AiSettingsRepository create(Ref ref) {
    return aiSettingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiSettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiSettingsRepository>(value),
    );
  }
}

String _$aiSettingsRepositoryHash() =>
    r'b376d54cbb477234a6d534af07339e71abaa378d';
