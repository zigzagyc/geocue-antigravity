// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cue_list_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cuesStream)
const cuesStreamProvider = CuesStreamProvider._();

final class CuesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CueModel>>,
          List<CueModel>,
          Stream<List<CueModel>>
        >
    with $FutureModifier<List<CueModel>>, $StreamProvider<List<CueModel>> {
  const CuesStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cuesStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cuesStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<CueModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CueModel>> create(Ref ref) {
    return cuesStream(ref);
  }
}

String _$cuesStreamHash() => r'7f2bf2e8cfa99ea046379a40dc35723c15c41f6b';
