import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import 'package:device_info_plus/device_info_plus.dart';

class MyAppA extends StatefulWidget {
  const MyAppA({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyAppA> {
  bool loading = false;
  Dio dio = Dio();
  String filePath = "";

  @override
  void initState() {
    download();
    super.initState();
  }

  Future<void> fetchAndroidVersion() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      int sdkInt = androidInfo.version.sdkInt ?? 0;

      if (sdkInt >= 33) {
        await startDownload();
      } else {
        final PermissionStatus status = await Permission.storage.request();
        if (status == PermissionStatus.granted) {
          await startDownload();
        } else {
          await Permission.storage.request();
        }
      }

      print("ANDROID VERSION (SDK): $sdkInt");
    }
  }

  download() async {
    if (Platform.isIOS) {
      final PermissionStatus status = await Permission.storage.request();
      if (status == PermissionStatus.granted) {
        await startDownload();
      } else {
        await Permission.storage.request();
      }
    } else if (Platform.isAndroid) {
      await fetchAndroidVersion();
    } else {
      throw PlatformException(code: '500', message: 'Unsupported platform');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Vocsy Plugin E-pub example'),
        ),
        body: Center(
          child: loading
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Text('Downloading.... E-pub'),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  if (filePath == "") {
                    download();
                  } else {
                    VocsyEpub.setConfig(
                      themeColor: Theme.of(context).primaryColor,
                      identifier: "iosBook",
                      scrollDirection:
                      EpubScrollDirection.ALLDIRECTIONS,
                      allowSharing: true,
                      enableTts: true,
                      nightMode: true,
                    );

                    VocsyEpub.locatorStream.listen((locator) {
                      print('LOCATOR: $locator');
                    });

                    VocsyEpub.open(
                      filePath,
                      lastLocation: EpubLocator.fromJson({
                        "bookId": "2239",
                        "href": "/OEBPS/ch06.xhtml",
                        "created": 1539934158390,
                        "locations": {
                          "cfi":
                          "epubcfi(/0!/4/4[simple_book]/2/2/6)"
                        }
                      }),
                    );
                  }
                },
                child: Text('Open Online E-pub'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    VocsyEpub.setConfig(
                      themeColor: Theme.of(context).primaryColor,
                      identifier: "iosBook",
                      scrollDirection:
                      EpubScrollDirection.ALLDIRECTIONS,
                      allowSharing: true,
                      enableTts: true,
                      nightMode: true,
                    );
                    VocsyEpub.locatorStream.listen((locator) {
                      print('LOCATOR: $locator');
                    });
                    await VocsyEpub.openAsset(
                      'assets/Flutter.epub',
                      lastLocation: EpubLocator.fromJson({
                        "bookId": "2239",
                        "href": "/OEBPS/ch06.xhtml",
                        "created": 1539934158390,
                        "locations": {
                          "cfi":
                          "epubcfi(/0!/4/4[simple_book]/2/2/6)"
                        }
                      }),
                    );
                  } catch (e) {
                    print("Error loading asset: $e");
                  }
                },
                child: Text('Open Assets E-pub'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  startDownload() async {
    setState(() {
      loading = true;
    });
    Directory? appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    String path = '${appDocDir!.path}/sample.epub';
    File file = File(path);

    if (!file.existsSync()) {
      await file.create();
      await dio
          .download(
        "https://vocsyinfotech.in/envato/cc/flutter_ebook/uploads/22566_The-Racketeer---John-Grisham.epub",
        path,
        deleteOnError: true,
        onReceiveProgress: (receivedBytes, totalBytes) {
          print('Download --- ${(receivedBytes / totalBytes) * 100}');
          setState(() {
            loading = true;
          });
        },
      )
          .whenComplete(() {
        setState(() {
          loading = false;
          filePath = path;
        });
      });
    } else {
      setState(() {
        loading = false;
        filePath = path;
      });
    }
  }
}
