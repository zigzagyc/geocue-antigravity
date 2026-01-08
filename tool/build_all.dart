import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

const String appName = 'hearhere';

void main() async {
  final distDir = Directory('dist');
  if (distDir.existsSync()) {
    print('Cleaning dist directory...');
    distDir.deleteSync(recursive: true);
  }
  distDir.createSync();

  print('Starting comprehensive release build for $appName...');

  // 1. Android
  await buildAndroid(distDir);

  // 2. Web
  await buildWeb(distDir);

  // 3. Desktop & iOS (Host dependent)
  if (Platform.isMacOS) {
    await buildMacOS(distDir);
    await buildIOS(distDir);
  } else if (Platform.isWindows) {
    await buildWindows(distDir);
  } else if (Platform.isLinux) {
    await buildLinux(distDir);
  }

  print('\n----------------------------------------------------------------');
  print('Build process completed successfully.');
  print('Artifacts are available in: ${distDir.absolute.path}');
  print('----------------------------------------------------------------');
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
  final androidDist = Directory(p.join(distDir.path, 'android'))..createSync();
  
  try {
    await runCommand('flutter', ['build', 'apk', '--release']);
    await runCommand('flutter', ['build', 'appbundle', '--release']);

    _copyFile('build/app/outputs/flutter-apk/app-release.apk', 
              p.join(androidDist.path, '$appName-release.apk'));
              
    _copyFile('build/app/outputs/bundle/release/app-release.aab', 
              p.join(androidDist.path, '$appName-release.aab'));
              
  } catch (e) {
    print('Skipping Android build: $e');
  }
}

Future<void> buildWeb(Directory distDir) async {
  print('\n--- Building Web ---');
  final webDist = Directory(p.join(distDir.path, 'web'))..createSync();
  try {
    await runCommand('flutter', ['build', 'web', '--release']);
    final webBuildDir = Directory('build/web');
    if (webBuildDir.existsSync()) {
      final zipPath = p.join(webDist.path, '$appName-web.zip');
      final encoder = ZipFileEncoder();
      encoder.create(zipPath);
      await encoder.addDirectory(webBuildDir);
      encoder.close();
      print('Zipped Web build: $zipPath');
    }
  } catch (e) {
    print('Skipping Web build: $e');
  }
}

Future<void> buildMacOS(Directory distDir) async {
  print('\n--- Building macOS ---');
  // macOS doesn't easily support distinct "AdHoc" vs "Store" via flutter build command
  // without Schemes, but normally --release builds a notarizable .app.
  // We will package the release build into two folders for clarity in dist.
  
  final macDist = Directory(p.join(distDir.path, 'macos'))..createSync();
  
  try {
    await runCommand('flutter', ['build', 'macos', '--release']);

    final appBuildPath = 'build/macos/Build/Products/Release/$appName.app';
    final appBuildDir = Directory(appBuildPath);
    
    if (appBuildDir.existsSync()) {
        // Zip for distribution
        final zipPath = p.join(macDist.path, '$appName-macos.zip');
        // NOTE: For macOS apps, system zip is preferred to preserve symlinks/perms reliably
        // runCommand('zip', ['-r', '-y', zipPath, appName.app], workingDirectory: ...);
        // But using archive package as requested/consistent for now, 
        // acknowledging potential permission bits limitation if not handled by package.
        
        final encoder = ZipFileEncoder();
        encoder.create(zipPath);
        await encoder.addDirectory(appBuildDir);
        encoder.close();
        print('Created macOS archive: $zipPath');
    }
  } catch (e) {
    print('Skipping macOS build: $e');
  }
}

Future<void> buildIOS(Directory distDir) async {
  print('\n--- Building iOS ---');
  final iosDist = Directory(p.join(distDir.path, 'ios'))..createSync();
  
  // 1. App Store Build
  print('Creating App Store IPA...');
  final storeDist = Directory(p.join(iosDist.path, 'store'))..createSync();
  
  try {
    await runCommand('flutter', ['build', 'ipa', '--release', 
      '--export-options-plist=ios/ExportOptionsStore.plist']);
      
    // Flutter puts the output in build/ios/ipa
    // We move it to our specific store dist folder
    final ipaFile = File('build/ios/ipa/$appName.ipa');
    if (ipaFile.existsSync()) {
        ipaFile.copySync(p.join(storeDist.path, '$appName.ipa'));
        print('Store IPA created.');
    } else {
        print('Warning: Store IPA not found at expected path.');
    }
  } catch (e) {
    print('Store build failed or skipped: $e');
  }

  // 2. Ad-Hoc Build (for OTA)
  print('Creating Ad-Hoc IPA...');
  final adhocDist = Directory(p.join(iosDist.path, 'adhoc'))..createSync();
  
  try {
    await runCommand('flutter', ['build', 'ipa', '--release', 
      '--export-options-plist=ios/ExportOptionsAdHoc.plist']);
      
    final ipaFile = File('build/ios/ipa/$appName.ipa');
    if (ipaFile.existsSync()) {
        final targetIpaPath = p.join(adhocDist.path, '$appName.ipa');
        ipaFile.copySync(targetIpaPath);
        print('Ad-Hoc IPA created.');
        
        // Generate OTA Files
        _generateOTAFiles(adhocDist, '$appName.ipa');
    }
  } catch (e) {
    print('Ad-Hoc build failed or skipped: $e');
  }
}

void _generateOTAFiles(Directory dir, String ipaName) {
  final manifestContent = '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>items</key>
	<array>
		<dict>
			<key>assets</key>
			<array>
				<dict>
					<key>kind</key>
					<string>software-package</string>
					<key>url</key>
					<string>YOUR_HTTPS_URL_HERE/$ipaName</string>
				</dict>
			</array>
			<key>metadata</key>
			<dict>
				<key>bundle-identifier</key>
				<string>com.hearhere.hearhere</string>
				<key>bundle-version</key>
				<string>1.0.0</string>
				<key>kind</key>
				<string>software</string>
				<key>title</key>
				<string>$appName</string>
			</dict>
		</dict>
	</array>
</dict>
</plist>
''';

  File(p.join(dir.path, 'manifest.plist')).writeAsStringSync(manifestContent);

  final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Install $appName</title>
</head>
<body>
    <h1>Install $appName</h1>
    <p><a href="itms-services://?action=download-manifest&url=YOUR_HTTPS_URL_HERE/manifest.plist" style="font-size: 20px; padding: 15px; background: #007aff; color: white; text-decoration: none; border-radius: 8px;">Install App</a></p>
</body>
</html>
''';

  File(p.join(dir.path, 'index.html')).writeAsStringSync(htmlContent);
  
  print('Generated manifest.plist and index.html for OTA.');
}

Future<void> buildWindows(Directory distDir) async {
  print('\n--- Building Windows ---');
  final winDist = Directory(p.join(distDir.path, 'windows'))..createSync();
  try {
    await runCommand('flutter', ['build', 'windows', '--release']);
    final buildDir = Directory('build/windows/runner/Release');
    if (buildDir.existsSync()) {
      final zipPath = p.join(winDist.path, '$appName-windows.zip');
      final encoder = ZipFileEncoder();
      encoder.create(zipPath);
      List<FileSystemEntity> files = buildDir.listSync(recursive: true);
        for (var file in files) {
           if (file is File) {
             final relPath = p.relative(file.path, from: buildDir.path);
             encoder.addFile(file, relPath);
           }
        }
      encoder.close();
      print('Zipped Windows build: $zipPath');
    }
  } catch (e) {
    print('Skipping Windows build: $e');
  }
}

Future<void> buildLinux(Directory distDir) async {
  print('\n--- Building Linux ---');
  final linuxDist = Directory(p.join(distDir.path, 'linux'))..createSync();
  try {
    await runCommand('flutter', ['build', 'linux', '--release']);
    final buildDir = Directory('build/linux/x64/release/bundle');
    if (buildDir.existsSync()) {
      final zipPath = p.join(linuxDist.path, '$appName-linux.zip');
      final encoder = ZipFileEncoder();
      encoder.create(zipPath);
      List<FileSystemEntity> files = buildDir.listSync(recursive: true);
        for (var file in files) {
           if (file is File) {
             final relPath = p.relative(file.path, from: buildDir.path);
             encoder.addFile(file, relPath);
           }
        }
      encoder.close();
    }
  } catch (e) {
     print('Skipping Linux build: $e');
  }
}

void _copyFile(String source, String dest) {
  final s = File(source);
  if (s.existsSync()) {
    s.copySync(dest);
    print('Copied to ${p.basename(dest)}');
  } else {
    print('Warning: Source file not found: $source');
  }
}
