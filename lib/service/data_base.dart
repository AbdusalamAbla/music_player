import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
Database _db;

///Quiet application database
Future<Database> getApplicationDatabase() async {
  if (_db != null) {
    return _db;
  }
  _db = await databaseFactoryIo.openDatabase(
      join((await getTemporaryDirectory()).path, 'database', 'app.db'));
  return _db;
}