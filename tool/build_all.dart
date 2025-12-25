import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

const String appName = 'geocue'; // Should match pubspec.yaml name

void main() async {
  final distDir = Directory('dist');
  if (distDir.existsSync()) {
    print('Cleaning dist directory...');
    distDir.deleteSync(recursive: true);
  }
  distDir.createSync();

  print('Starting build process for $appName...');

  // 1. Build Android
  await buildAndroid(distDir);

  // 2. Build Web
  await buildWeb(distDir);

  // 3. Build Desktop (Current OS)
  if (Platform.isMacOS) {
    await buildMacOS(distDir);
    await buildIOS(distDir); // iOS only on Mac
  } else if (Platform.isWindows) {
    await buildWindows(distDir);
  } else if (Platform.isLinux) {
    await buildLinux(distDir);
  }

  print('Build process completed. Artifacts are in ${distDir.path}');
}

Future<void> runCommand(String command, List<String> args) async {
  print('Running: $command ${args.join(' ')}');
  final result = await Process.run(command, args, runInShell: true);
  if (result.exitCode != 0) {
    print('Error running $command:');
    print(result.stdout);
    print(result.stderr);
    exit(result.exitCode);
  }
}

Future<void> buildAndroid(Directory distDir) async {
  print('\n--- Building Android ---');
  try {
    await runCommand('flutter', ['build', 'apk', '--release']);
    await runCommand('flutter', ['build', 'appbundle', '--release']);

    final apkFile = File('build/app/outputs/flutter-apk/app-release.apk');
    if (apkFile.existsSync()) {
      apkFile.copySync(p.join(distDir.path, '$appName-android.apk'));
      print('Copied APK to dist.');
    }

    final aabFile = File('build/app/outputs/bundle/release/app-release.aab');
    if (aabFile.existsSync()) {
      aabFile.copySync(p.join(distDir.path, '$appName-android.aab'));
      print('Copied AppBundle to dist.');
    }
  } catch (e) {
    print('Skipping Android build: $e');
  }
}

Future<void> buildWeb(Directory distDir) async {
  print('\n--- Building Web ---');
  try {
    // Note: --release is default for build web
    await runCommand('flutter', ['build', 'web', '--release']);

    final webBuildDir = Directory('build/web');
    if (webBuildDir.existsSync()) {
      final zipFile = File(p.join(distDir.path, '$appName-web.zip'));
      final encoder = ZipFileEncoder();
      encoder.create(zipFile.path);
      await encoder.addDirectory(webBuildDir);
      encoder.close();
      print('Zipped Web build to dist.');
    }
  } catch (e) {
    print('Skipping Web build: $e');
  }
}

Future<void> buildMacOS(Directory distDir) async {
  print('\n--- Building macOS ---');
  try {
    await runCommand('flutter', ['build', 'macos', '--release']);

    final appBuildDir = Directory('build/macos/Build/Products/Release/$appName.app');
    if (appBuildDir.existsSync()) {
        // Zip the .app bundle
        // Note: Zipping .app directly with archive package might lose permissions/symlinks.
        // It's safer to use 'ditto' on macOS if possible, or 'zip' command.
        // But requested to use 'archive' package. 
        // A .app is a directory.
        
        // Actually, for macOS .app, it's best to create a DMG or zip it properly preserving metadata.
        // The standard usually is just the .app or a zip of it.
        // We will try using standard zip for now.
        
        final zipPath = p.join(distDir.path, '$appName-macos.zip');
        print('Zipping macOS app...');
        
        // Using system zip to preserve attributes for macOS apps is preferred, 
        // as Dart's archive package might not fully handle executable bits/symlinks perfectly in all versions.
        // However, I will use archive if possible or fallback.
        // Let's stick to 'archive' package as requested, but if it fails for execution we might need system zip.
        // To be safe for macOS apps, 'ditto -c -k --keepParent' is best.
        
        // But adhering to "portable build script", using 'archive' is the request.
        // Let's use `archive`.
        final encoder = ZipFileEncoder();
        encoder.create(zipPath);
        // We need to add the directory properly so it expands as appName.app
        await encoder.addDirectory(appBuildDir); 
        encoder.close();
        print('Zipped macOS app to dist.');
    }
  } catch (e) {
    print('Skipping macOS build: $e');
  }
}

Future<void> buildIOS(Directory distDir) async {
  print('\n--- Building iOS ---');
  try {
    // 'flutter build ipa' produces an Xcode archive and a .ipa
    // This requires a provisioning profile.
    // If we just want .app for simulator, we use 'flutter build ios'.
    // Assuming we want a release build. 
    // 'flutter build ipa --export-options-plist=...' is often needed for fully automated interaction,
    // or just 'flutter build ios --release --no-codesign' if valid.
    
    // We will try 'flutter build ipa --release --no-codesign' to avoid extensive signing setup issues if just testing,
    // or just 'flutter build ipa' and let it fail if not set up.
    // Let's try standard:
    await runCommand('flutter', ['build', 'ipa', '--release', '--no-codesign']); 

    final ipaDir = Directory('build/ios/archive/Runner.xcarchive'); // This might vary
    // Actually flutter build ipa usually puts output in build/ios/ipa
    final ipaFile = File('build/ios/ipa/$appName.ipa');
    
    if (ipaFile.existsSync()) {
         ipaFile.copySync(p.join(distDir.path, '$appName-ios.ipa'));
         print('Copied IPA to dist.');
    } else {
        // Fallback or check for Payload directory if no signing
        print('IPA file not found. Ensure signing is configured or check build output.');
    }
  } catch (e) {
    print('Skipping iOS build: $e');
  }
}

Future<void> buildWindows(Directory distDir) async {
  print('\n--- Building Windows ---');
  try {
    await runCommand('flutter', ['build', 'windows', '--release']);
    
    final buildDir = Directory('build/windows/runner/Release');
    if (buildDir.existsSync()) {
        final zipFile = File(p.join(distDir.path, '$appName-windows.zip'));
        final encoder = ZipFileEncoder();
        encoder.create(zipFile.path);
        // Windows release folder contains .exe and data folders
        // We should zip the contents of Release
        
        // Add all files in directory
        List<FileSystemEntity> files = buildDir.listSync(recursive: true);
        for (var file in files) {
           if (file is File) {
             final relPath = p.relative(file.path, from: buildDir.path);
             encoder.addFile(file, relPath);
           }
        }
        encoder.close();
        print('Zipped Windows build to dist.');
    }
  } catch (e) {
     print('Skipping Windows build: $e');
  }
}

Future<void> buildLinux(Directory distDir) async {
  print('\n--- Building Linux ---');
  try {
    await runCommand('flutter', ['build', 'linux', '--release']);
    
    final buildDir = Directory('build/linux/x64/release/bundle');
    if (buildDir.existsSync()) {
        final zipFile = File(p.join(distDir.path, '$appName-linux.zip'));
        final encoder = ZipFileEncoder();
        encoder.create(zipFile.path);
        
        // Add all files in directory
        List<FileSystemEntity> files = buildDir.listSync(recursive: true);
        for (var file in files) {
           if (file is File) {
             final relPath = p.relative(file.path, from: buildDir.path);
             encoder.addFile(file, relPath);
           }
        }
        encoder.close();
        print('Zipped Linux build to dist.');
    }
  } catch (e) {
     print('Skipping Linux build: $e');
  }
}
