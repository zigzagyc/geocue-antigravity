import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_storage/firebase_storage.dart';

part 'storage_service.g.dart';

abstract class StorageService {
  Future<String> uploadFile(File file, String path);
}

class FirebaseStorageService implements StorageService {
  final FirebaseStorage _storage;
  FirebaseStorageService(this._storage);

  @override
  Future<String> uploadFile(File file, String path) async {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}

class MockStorageService implements StorageService {
  @override
  Future<String> uploadFile(File file, String path) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'https://example.com/mock_audio.mp3';
  }
}

@Riverpod(keepAlive: true)
StorageService storageService(Ref ref) {
  // Return Mock for now until Firebase is setup completely
  // return MockStorageService();
  return FirebaseStorageService(FirebaseStorage.instance);
}
