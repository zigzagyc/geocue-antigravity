import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hearhere/features/cue/domain/cue_model.dart';

part 'cue_repository.g.dart';

abstract class CueRepository {
  Future<void> createCue(CueModel cue);
  Future<List<CueModel>> getCues();
  Future<CueModel?> getCue(String id);
  Future<void> updateCue(CueModel cue);
  Future<void> deleteCue(String cueId);
  Stream<List<CueModel>> watchCues();
}

class FirestoreCueRepository implements CueRepository {
  final FirebaseFirestore _firestore;
  FirestoreCueRepository(this._firestore);

  @override
  Future<void> createCue(CueModel cue) async {
    await _firestore.collection('cues').doc(cue.id).set(cue.toJson());
  }

  @override
  Future<List<CueModel>> getCues() async {
    final snapshot = await _firestore.collection('cues').get();
    return snapshot.docs.map((doc) => CueModel.fromJson(doc.data())).toList();
  }

  @override
  Future<CueModel?> getCue(String id) async {
    final doc = await _firestore.collection('cues').doc(id).get();
    if (doc.exists) {
      return CueModel.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<void> updateCue(CueModel cue) async {
    await _firestore.collection('cues').doc(cue.id).update(cue.toJson());
  }

  @override
  Future<void> deleteCue(String cueId) async {
    await _firestore.collection('cues').doc(cueId).delete();
  }

  @override
  Stream<List<CueModel>> watchCues() {
    return _firestore.collection('cues').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => CueModel.fromJson(doc.data())).toList());
  }
}

// Mock Repository for development without Firebase
class MockCueRepository implements CueRepository {
    List<CueModel> _cues = [];

    @override
    Future<void> createCue(CueModel cue) async {
        _cues.add(cue);
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 500));
    }
    
    @override
    Future<List<CueModel>> getCues() async {
        await Future.delayed(const Duration(milliseconds: 500));
        return _cues;
    }

    @override
    Future<CueModel?> getCue(String id) async {
        try {
          return _cues.firstWhere((c) => c.id == id);
        } catch (e) {
          return null;
        }
    }

    @override
    Future<void> updateCue(CueModel cue) async {
        final index = _cues.indexWhere((c) => c.id == cue.id);
        if (index != -1) {
            _cues[index] = cue;
        }
    }

    @override
    Future<void> deleteCue(String cueId) async {
        _cues.removeWhere((c) => c.id == cueId);
    }

    @override
    Stream<List<CueModel>> watchCues() {
        return Stream.value(_cues); // Simple single emit flow for mock
    }
}

@Riverpod(keepAlive: true)
CueRepository cueRepository(Ref ref) {
    // Return MockCueRepository for now until Firebase is configured
    return FirestoreCueRepository(FirebaseFirestore.instance);
    // return MockCueRepository();
}
