import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';
import 'package:screenshot_memory/pages/edit_options/edit_options_bloc.dart';
import 'package:sqflite/sqflite.dart';

class ScreenshotMemory {
  ScreenshotMemory(this.name, this.path, this.description, this.tags,
      {this.id, DateTime createDate, DateTime lastUsedDate})
      : lastUsedDate = lastUsedDate ?? DateTime.now(),
        createDate = createDate ?? DateTime.now();

  final int id;
  final String name;
  final String path;
  final String description;
  final Set<Tag> tags;
  final DateTime createDate;
  final DateTime lastUsedDate;
}

abstract class DatabaseRepository {
  Future<int> insertScreenshotMemory(ScreenshotMemory screenshotMemory);
  Future<int> updateScreenshotMemory(int id,
      {String description, String name, Set<Tag> tags});

  Future<List<ScreenshotMemory>> screenshotMemories();

  Stream<List<ScreenshotMemory>> screenshotMemoriesStream();

  dispose();

  void onResume();

  Future<ScreenshotMemory> screenshotMemory(int screenshotId);
}

class SqLiteDatabaseRepository extends DatabaseRepository {
  static const _TABLE_NAME = 'memories';
  static const _COL_ID = 'id';
  static const _COL_NAME = 'name';
  static const _COL_PATH = 'path';
  static const _COL_DESCRIPTION = 'description';
  static const _COL_TAGS = 'tags';
  static const _COL_CREATED_DATE = 'created';
  static const _COL_LAST_USED_DATE = 'lastUsed';

  BehaviorSubject<List<ScreenshotMemory>> _allScreenshotsStream;
  bool _dirty = true;

  SqLiteDatabaseRepository() {
    this._allScreenshotsStream = BehaviorSubject(onListen: () {
      if (_dirty) {
        screenshotMemories().then((value) {
          // DO nothing all will be done by screenShotMemories method
        });
      }
    });
  }

  @override
  Future<int> insertScreenshotMemory(ScreenshotMemory screenshotMemory) async {
    final db = await _getDatabase();
    _dirty = true;
    return await db.insert(_TABLE_NAME, _dbValues(screenshotMemory));
  }

  @override
  Future<List<ScreenshotMemory>> screenshotMemories() async {
    _dirty = false;
    final db = await _getDatabase();
    final results =
        await db.query(_TABLE_NAME, orderBy: "$_COL_LAST_USED_DATE desc");

    final list = List.generate(results.length, (i) {
      return _fromQuery(results[i]);
    });
    _allScreenshotsStream.add(list);
    return list;
  }

  Future<Database> _getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'screenshot_memory.db'),
      onCreate: (db, version) {
        return db.execute(
            "create table $_TABLE_NAME($_COL_ID integer primary key, $_COL_NAME text, $_COL_PATH text, $_COL_DESCRIPTION text, $_COL_TAGS text, $_COL_CREATED_DATE biginteger, $_COL_LAST_USED_DATE biginteger)");
      },
      version: 1,
    );
  }

  Map<String, dynamic> _dbValues(ScreenshotMemory memory) {
    final head = memory.id != null ? {_COL_ID: memory.id} : {};

    return {
      ...head,
      _COL_NAME: memory.name ?? "",
      _COL_PATH: memory.path,
      _COL_DESCRIPTION: memory.description,
      _COL_CREATED_DATE: memory.createDate.millisecondsSinceEpoch,
      _COL_LAST_USED_DATE: memory.lastUsedDate.millisecondsSinceEpoch,
      _COL_TAGS: tagsToDbString(memory.tags)
    };
  }

  String tagsToDbString(Set<Tag> tags) {
    return tags.isEmpty
        ? ""
        : tags.map((tag) => tag.toDbString()).reduce((a, acc) => " $a , $acc");
  }

  ScreenshotMemory _fromQuery(Map<String, dynamic> result) {
    return ScreenshotMemory(result[_COL_NAME], result[_COL_PATH],
        result[_COL_DESCRIPTION], _parseTags(result[_COL_TAGS]),
        id: result[_COL_ID],
        lastUsedDate: _parseDate(result[_COL_LAST_USED_DATE]),
        createDate: _parseDate(result[_COL_CREATED_DATE]));
  }

  DateTime _parseDate(int result) {
    return DateTime.fromMillisecondsSinceEpoch(result);
  }

  Set<Tag> _parseTags(String result) {
    return result
        .split(',')
        .map((it) => Tag.parse(it))
        .where((it) => it != null)
        .toSet();
  }

  @override
  Stream<List<ScreenshotMemory>> screenshotMemoriesStream() {
    return _allScreenshotsStream.stream;
  }

  @override
  dispose() {
    _allScreenshotsStream.close();
  }

  @override
  void onResume() {
    screenshotMemories().then((value) {
      // DO nothing all will be done by screenShotMemories method
    });
  }

  @override
  Future<ScreenshotMemory> screenshotMemory(int screenshotId) async {
    final db = await _getDatabase();
    final results =
        await db.query(_TABLE_NAME, where: "$_COL_ID = $screenshotId");
    if (results.isEmpty) {
      throw "No such id($screenshotId) in $_TABLE_NAME";
    } else {
      return _fromQuery(results[0]);
    }
  }

  @override
  Future<int> updateScreenshotMemory(int id,
      {String description, String name, Set<Tag> tags}) async {
    final db = await _getDatabase();
    final values = {
      if (description != null) _COL_DESCRIPTION: description,
      if (name != null) _COL_NAME: name,
      if (tags != null) _COL_TAGS: tagsToDbString(tags),
      _COL_LAST_USED_DATE: DateTime.now().millisecondsSinceEpoch
    };
    _dirty = true;
    return await db.update(_TABLE_NAME, values, where: "$_COL_ID = '$id'");
  }
}
