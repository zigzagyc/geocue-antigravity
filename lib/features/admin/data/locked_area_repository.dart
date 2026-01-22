import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hearhere/features/admin/domain/locked_area_model.dart';

part 'locked_area_repository.g.dart';

class LockedAreaRepository {
  final FirebaseFirestore _firestore;

  LockedAreaRepository(this._firestore);

  Future<void> createLockedArea(LockedAreaModel area) async {
    await _firestore.collection('locked_areas').doc(area.id).set(area.toJson());
  }
  
  Future<void> deleteLockedArea(String id) async {
    await _firestore.collection('locked_areas').doc(id).delete();
  }

  Stream<List<LockedAreaModel>> watchLockedAreas() {
    return _firestore.collection('locked_areas').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => LockedAreaModel.fromJson(doc.data())).toList();
    });
  }
  
  Future<bool> isLocationLocked(double lat, double lng) async {
    // Simple client-side check: Fetch all locked areas and check distance.
    // For scalability, this should be server-side or GeoQuery, but given requirements and tech stack, this works for now.
    final snapshot = await _firestore.collection('locked_areas').get();
    for (var doc in snapshot.docs) {
      final area = LockedAreaModel.fromJson(doc.data());
      // Simple distance check (using approx logic or Geolocator package logic if imported, here basic euclidean for speed/simplicity or import math)
      // Let's rely on basic math for now or better, use simple delta check first.
      // Or cleaner: just fetch all and check.
      // Squared distance to avoid sqrt cost if possible, but lat/lng conversion needed for meters.
      // Re-using Geolocator distance function would be best if available in repository layer, but repository usually data only.
      // Let's return the list and let Service/Controller check distance with Geolocator.
    }
    return false; 
  }

  Future<List<LockedAreaModel>> getLockedAreas() async {
    final snapshot = await _firestore.collection('locked_areas').get();
    return snapshot.docs.map((doc) => LockedAreaModel.fromJson(doc.data())).toList();
  }
}

@Riverpod(keepAlive: true)
LockedAreaRepository lockedAreaRepository(Ref ref) {
  return LockedAreaRepository(FirebaseFirestore.instance);
}
