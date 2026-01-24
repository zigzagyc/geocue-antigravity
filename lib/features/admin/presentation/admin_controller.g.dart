// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AdminController)
const adminControllerProvider = AdminControllerProvider._();

final class AdminControllerProvider
    extends $AsyncNotifierProvider<AdminController, List<UserModel>> {
  const AdminControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminControllerHash();

  @$internal
  @override
  AdminController create() => AdminController();
}

String _$adminControllerHash() => r'40b28062704e4d1c754a8efa8485c6f27cf06a70';

abstract class _$AdminController extends $AsyncNotifier<List<UserModel>> {
  FutureOr<List<UserModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<UserModel>>, List<UserModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<UserModel>>, List<UserModel>>,
              AsyncValue<List<UserModel>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(lockedAreasStream)
const lockedAreasStreamProvider = LockedAreasStreamProvider._();

final class LockedAreasStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LockedAreaModel>>,
          List<LockedAreaModel>,
          Stream<List<LockedAreaModel>>
        >
    with
        $FutureModifier<List<LockedAreaModel>>,
        $StreamProvider<List<LockedAreaModel>> {
  const LockedAreasStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lockedAreasStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lockedAreasStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<LockedAreaModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LockedAreaModel>> create(Ref ref) {
    return lockedAreasStream(ref);
  }
}

String _$lockedAreasStreamHash() => r'45603f6f13fde68aa5b969d02f78c848dfeb1465';
