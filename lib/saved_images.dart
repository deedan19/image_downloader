
import 'dart:io';
import 'package:flutter/material.dart';
import 'sqflite_database.dart';

class SavedImages extends StatefulWidget {
  const SavedImages({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _SavedImagesState createState() => _SavedImagesState();
}
class _SavedImagesState extends State<SavedImages> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder<List<ImageModel>>(
            future: DatabaseHelper.instance.getImages(),
            builder: (BuildContext context,
                AsyncSnapshot<List<ImageModel>> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: Text('Loading...'));
              }
              return snapshot.data!.isEmpty
                  ? Center(child: Text('No Images saved.'),)
                  : GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                children: snapshot.data!.map((image) {
                  return Container(
                    margin: EdgeInsets.all(10.0),
                    child: Image.file(
                        File(image.imageFilePath),),
                  );
                }).toList(),
              );
            }),
      )
    );
  }
}




