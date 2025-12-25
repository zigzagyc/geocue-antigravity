// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_cue_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateCueController)
const createCueControllerProvider = CreateCueControllerProvider._();

final class CreateCueControllerProvider
    extends $AsyncNotifierProvider<CreateCueController, void> {
  const CreateCueControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createCueControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createCueControllerHash();

  @$internal
  @override
  CreateCueController create() => CreateCueController();
}

String _$createCueControllerHash() =>
    r'60c6239b2b2644a09a326729278867711c3b5b57';

abstract class _$CreateCueController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
