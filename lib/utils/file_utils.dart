import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:dio/dio.dart';

// Hulpfunctie om de aangepaste afbeeldingenmap in de Pictures map van de gebruiker te verkrijgen of aan te maken
Future<Directory> getCustomImagesDirectory() async {
  // Verkrijg de Pictures map van de gebruiker
  Directory? picturesDir;

  if (Platform.isWindows) {
    // Op Windows, verkrijg de Pictures map
    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile != null) {
      picturesDir = Directory('$userProfile\\Pictures');
    }
  } else if (Platform.isMacOS) {
    // Op macOS, verkrijg de Pictures map
    final homeDir = Platform.environment['HOME'];
    if (homeDir != null) {
      picturesDir = Directory('$homeDir/Pictures');
    }
  } else if (Platform.isLinux) {
    // Op Linux, verkrijg de Pictures map
    final homeDir = Platform.environment['HOME'];
    if (homeDir != null) {
      picturesDir = Directory('$homeDir/Pictures');
    }
  } else if (Platform.isIOS) {
    // Op iOS, gebruik de Documents map van de app omdat we niet direct toegang hebben tot de systeem Photos bibliotheek
    // Voor opslaan naar Photos bibliotheek gebruiken we het gal pakket in de opslagfuncties
    final appDocumentsDir = await getApplicationDocumentsDirectory();
    picturesDir = appDocumentsDir;
  } else if (Platform.isAndroid) {
    // Op Android, probeer eerst de externe opslagmap te verkrijgen, terugval naar app documents
    try {
      // Probeer de externe opslagmap te verkrijgen (meestal /storage/emulated/0)
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        // Maak Pictures map aan in externe opslag indien deze niet bestaat
        final androidPicturesDir = Directory('${externalDir.path}/Pictures');
        if (!await androidPicturesDir.exists()) {
          await androidPicturesDir.create(recursive: true);
        }
        picturesDir = androidPicturesDir;
      } else {
        // Terugval naar app documents map
        final appDocumentsDir = await getApplicationDocumentsDirectory();
        picturesDir = appDocumentsDir;
      }
    } catch (e) {
      // Als externe opslag niet beschikbaar is, gebruik app documents map
      final appDocumentsDir = await getApplicationDocumentsDirectory();
      picturesDir = appDocumentsDir;
    }
  }

  // Terugval naar documents map als Pictures map niet beschikbaar is
  if (picturesDir == null || !await picturesDir.exists()) {
    final appDocumentsDir = await getApplicationDocumentsDirectory();
    picturesDir = appDocumentsDir;
  }

  // Maak de "tuff image browser" map aan binnen Pictures
  final customDir = Directory('${picturesDir.path}${Platform.pathSeparator}tuff image browser');

  try {
    if (!await customDir.exists()) {
      await customDir.create(recursive: true);
    }
    return customDir;
  } catch (e) {
    // Als we niet kunnen aanmaken in Pictures, terugval naar documents map
    final appDocumentsDir = await getApplicationDocumentsDirectory();
    final fallbackDir = Directory('${appDocumentsDir.path}${Platform.pathSeparator}tuff image browser');
    if (!await fallbackDir.exists()) {
      await fallbackDir.create(recursive: true);
    }
    return fallbackDir;
  }
}

// Hulpfunctie om afbeelding/video automatisch op te slaan naar aangepaste map
Future<void> autoSaveMedia(String mediaUrl, {bool isVideo = false}) async {
  try {
    // Download media
    final dio = Dio();
    final response = await dio.get(
      mediaUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.data == null) {
      return;
    }

    // Verkrijg aangepaste map
    final customDir = await getCustomImagesDirectory();

    // Extraheer bestandsextensie uit URL
    final uri = Uri.parse(mediaUrl);
    final pathSegments = uri.pathSegments;
    String extension = isVideo ? '.mp4' : '.jpg'; // standaard extensies
    if (pathSegments.isNotEmpty) {
      final fileName = pathSegments.last;
      final dotIndex = fileName.lastIndexOf('.');
      if (dotIndex != -1) {
        extension = fileName.substring(dotIndex);
      }
    }

    // Maak unieke bestandsnaam aan
    final prefix = isVideo ? 'teto_video' : 'teto_image';
    final fileName = '${prefix}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final file = File('${customDir.path}/$fileName');

    // Sla bestand op naar aangepaste map
    await file.writeAsBytes(response.data);

    // Op mobiele platformen, sla ook op naar de fotogalerij van het apparaat met behulp van gal pakket
    if (Platform.isIOS || Platform.isAndroid) {
      try {
        if (isVideo) {
          // Sla video op naar galerij
          await Gal.putVideo(file.path);
        } else {
          // Sla afbeelding op naar galerij
          await Gal.putImage(file.path);
        }
      } catch (e) {
        // Misluk stil als galerij opslaan faalt (mogelijk vanwege permissies)
        // Het bestand wordt nog steeds opgeslagen in de app map
      }
    }
  } catch (e) {
    // Misluk stil voor auto-opslaan om gebruikerservaring niet te onderbreken
  }
}
