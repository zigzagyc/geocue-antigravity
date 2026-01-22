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
    r'c16c87e83d11d5cc9392e7d9e19579f2a0178d2e';

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
