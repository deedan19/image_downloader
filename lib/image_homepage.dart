
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_downloader/saved_images.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'sqflite_database.dart';


class ImageHomePage extends StatefulWidget {
  ImageHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _ImageHomePageState createState() => _ImageHomePageState();
}

class _ImageHomePageState extends State<ImageHomePage> {

  final urlController = TextEditingController();
  final imageNameController = TextEditingController();

Image _displayImage = Image(
  image: AssetImage('images/placeholderImage.png'),
);

  bool _imageIsShown = false;
  final Dio dio = Dio();
  bool loading = false;
  double progress = 0;

  String imagePath = '';

  Future<bool> saveVideo(String url, String fileName) async {
    Directory? directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = await getExternalStorageDirectory();
          String newPath = "";
          List<String> paths = directory!.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          newPath = newPath + "/ImageDownloaderApp";
          directory = Directory(newPath);
          setState(() {
            imagePath = "${directory!.path}" + "/$fileName";
          });
        } else {
          return false;
        }
      } else {
        if (Platform.isIOS) {
          if (await _requestPermission(Permission.photos)) {
            directory = await getTemporaryDirectory();
          } else {
            return false;
          }
        }
      }
      if (!await directory!.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        File saveFile = File(directory.path + "/$fileName");
        await dio.download(url, saveFile.path,
            onReceiveProgress: (value1, value2) {
              setState(() {
                progress = value1 / value2;
              });
            });
        if (Platform.isIOS) {
          await ImageGallerySaver.saveFile(saveFile.path,
              isReturnPathOfIOS: true);
          setState(() {
            imagePath = "${directory!.path}" + "/$fileName";
          });
        }
        return true;
      }
    } catch (e) {
      print('Can\'t save file:: $e');
    }
    return false;
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future<void> downloadImage(String imageURL, String imageName) async {
    setState(() {
      loading = true;
      progress = 0;
    });
    bool downloaded = await saveVideo(imageURL, imageName);

    if (downloaded) {
      print("File Downloaded");
      DatabaseHelper.instance.add(
        ImageModel(imageFilePath: imagePath)
      );
    } else {
      print("Problem Downloading File");
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    DatabaseHelper.instance.database;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'Enter image URL',
                    contentPadding: EdgeInsets.all(20),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(23),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(23),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    suffix: GestureDetector(
                      onTap: (){
                        urlController.clear();
                      },
                      child: Icon(Icons.clear),
                    ),
                  ),
                  controller: urlController,
                ),
                SizedBox(
                  height: 10,
                ),
                TextButton(
                  style:
                      TextButton.styleFrom(backgroundColor: Colors.blueAccent),
                  onPressed: () {
                    if (urlController.text.isNotEmpty) {
                      setState(() {
                        _displayImage = Image(
                            image: NetworkImage(urlController.text),);
                      });
                      _imageIsShown = true;
                    } else {
                      _imageIsShown = false;
                      print('Error:: Invalid Image URL, Please input a valid URL');
                    }
                  },
                  child: Text(
                    'Show Image',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                child: _displayImage
              ),
            ),
            SizedBox(height: 10,),
            Column(
              children: [
                _imageIsShown ?
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'Enter name',
                    contentPadding: EdgeInsets.all(20),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(23),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(23),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    suffix: GestureDetector(
                      onTap: (){
                        imageNameController.clear();
                      },
                      child: Icon(Icons.clear),
                    ),
                  ),
                  controller: imageNameController,
                ) : Text('Download Image when shown'),
                TextButton(
                  style:
                          TextButton.styleFrom(backgroundColor: Colors.blueAccent),
                  child: Text('Download Image',
                  style: TextStyle(color: Colors.white),),
                  onPressed: () async {
                    if (urlController.text.isNotEmpty) {
                      if (imageNameController.text.isEmpty) {
                        print('Please enter a name');
                      }
                      else {
                        await downloadImage(urlController.text, '${imageNameController.text.toLowerCase()}.jpg');
                      }
                    } 
                  },
                ),
              ],
            ),
            SizedBox(
              height: 5.0,
            ),
            SizedBox(
              height: 40.0,
              width: double.infinity,
              child: TextButton(
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SavedImages(
                            title: 'Saved Images'),
                      ),
                    );
                  },
                  child: Text('Show saved Images',),
                style: TextButton.styleFrom(
                  primary: Colors.white60,
                  backgroundColor: Colors.black87
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
