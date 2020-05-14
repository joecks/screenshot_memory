import 'package:path/path.dart';
import 'package:screenshot_memory/pages/edit_options_page.dart';
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

  Future<List<ScreenshotMemory>> screenshotMemories();

  dispose();
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

  @override
  Future<int> insertScreenshotMemory(ScreenshotMemory screenshotMemory) async {
    final db = await _getDatabase();
    return await db.insert(_TABLE_NAME, _dbValues(screenshotMemory));
  }

  @override
  Future<List<ScreenshotMemory>> screenshotMemories() async {
    final db = await _getDatabase();
    final results = await db.query(_TABLE_NAME);

    return List.generate(results.length, (i) {
      return _fromQuery(results[i]);
    });
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
      _COL_TAGS: memory.tags.isEmpty
          ? ""
          : memory.tags
              .map((tag) => tag.toDbString())
              .reduce((a, acc) => " $a , $acc")
    };
  }

  ScreenshotMemory _fromQuery(Map<String, dynamic> result) {
    return ScreenshotMemory(result[_COL_NAME], result[_COL_PATH],
        result[_COL_DESCRIPTION], _parseTags(result[_COL_TAGS]),
        id: result[_COL_ID],
        lastUsedDate: _parseDate(result[_COL_LAST_USED_DATE]),
        createDate: _parseDate(result[_COL_CREATED_DATE]));
  }

  DateTime _parseDate(int result) {
    return DateTime(result);
  }

  Set<Tag> _parseTags(String result) {
    return result
        .split(',')
        .map((it) => Tag.parse(it))
        .where((it) => it != null)
        .toSet();
  }

  @override
  dispose() {}
}
