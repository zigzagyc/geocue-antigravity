// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlaybackService)
const playbackServiceProvider = PlaybackServiceProvider._();

final class PlaybackServiceProvider
    extends $AsyncNotifierProvider<PlaybackService, CueModel?> {
  const PlaybackServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playbackServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playbackServiceHash();

  @$internal
  @override
  PlaybackService create() => PlaybackService();
}

String _$playbackServiceHash() => r'70eb6276b4194093ce739c5eba80b06c6ca2f293';

abstract class _$PlaybackService extends $AsyncNotifier<CueModel?> {
  FutureOr<CueModel?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<CueModel?>, CueModel?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CueModel?>, CueModel?>,
              AsyncValue<CueModel?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
