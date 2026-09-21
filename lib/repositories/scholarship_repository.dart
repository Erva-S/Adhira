import '../../core/enums/app_enums.dart';
import '../../shared/models/scholarship.dart';
import '../../services/database/relational_data_store.dart';
import 'base_repository.dart';

abstract class ScholarshipRepository {
  Future<List<Scholarship>> getScholarships();
  Future<Scholarship?> getScholarshipById(String id);
  Future<Scholarship?> getScholarshipByType(ScholarshipType type);
}

class AppScholarshipRepository extends BaseRepository implements ScholarshipRepository {
  final RelationalDataStore _dataStore;

  AppScholarshipRepository({RelationalDataStore? dataStore})
      : _dataStore = dataStore ?? RelationalDataStore();

  @override
  Future<List<Scholarship>> getScholarships() async {
    return safeCall(() async {
      return _dataStore.getScholarships();
    });
  }

  @override
  Future<Scholarship?> getScholarshipById(String id) async {
    return safeCall(() async {
      return _dataStore.getScholarshipById(id);
    });
  }

  @override
  Future<Scholarship?> getScholarshipByType(ScholarshipType type) async {
    return safeCall(() async {
      final list = _dataStore.getScholarships();
      try {
        return list.firstWhere((s) => s.type == type);
      } catch (_) {
        return null;
      }
    });
  }
}
