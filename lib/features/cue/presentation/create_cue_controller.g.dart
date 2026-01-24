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
    r'82332186ef886158a5b17dd76c1c1ec83cfbf00f';

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
