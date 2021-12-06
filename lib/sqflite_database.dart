import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ImageModel {
  final int? id;
  final String imageFilePath;

  ImageModel({this.id, required this.imageFilePath});

  factory ImageModel.fromMap(Map<String, dynamic> json) => new ImageModel(
    id: json['id'],
    imageFilePath: json['imageFilePath'],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageFilePath': imageFilePath,
    };
  }
}

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase('images.db');
    return _database!;
  }

  Future<Database> _initDatabase(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE images (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          imageFilePath TEXT
      )
      ''');
  }

  Future<List<ImageModel>> getImages() async {
    Database db = await instance.database;
    var listOfImages = await db.query('images',);
    List<ImageModel> groceryList = listOfImages.isNotEmpty
        ? listOfImages.map((c) => ImageModel.fromMap(c)).toList()
        : [];
    return groceryList;
  }

  Future<int> add(ImageModel image) async {
    Database db = await instance.database;
    return await db.insert('images', image.toMap());
  }

  Future<int> remove(int id) async {
    Database db = await instance.database;
    return await db.delete('images', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(ImageModel image) async {
    Database db = await instance.database;
    return await db.update('images', image.toMap(),
        where: "id = ?", whereArgs: [image.id]);
  }
}

