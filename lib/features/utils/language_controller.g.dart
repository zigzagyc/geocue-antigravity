// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PreferredLanguage)
const preferredLanguageProvider = PreferredLanguageProvider._();

final class PreferredLanguageProvider
    extends $AsyncNotifierProvider<PreferredLanguage, String> {
  const PreferredLanguageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferredLanguageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferredLanguageHash();

  @$internal
  @override
  PreferredLanguage create() => PreferredLanguage();
}

String _$preferredLanguageHash() => r'74046b3cd56d12923cb5ee7605dce227195cb2d2';

abstract class _$PreferredLanguage extends $AsyncNotifier<String> {
  FutureOr<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<String>, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String>, String>,
              AsyncValue<String>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
