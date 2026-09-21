import '../../shared/models/student.dart';
import '../../services/database/relational_data_store.dart';
import 'base_repository.dart';

abstract class UserRepository {
  Future<Student?> getUserProfile(String userId);
  Future<Student> updateUserProfile(Student student);
  Future<Student> getOrCreateUser({required String phoneNumber, String? fullName});
}

class AppUserRepository extends BaseRepository implements UserRepository {
  final RelationalDataStore _dataStore;

  AppUserRepository({RelationalDataStore? dataStore})
      : _dataStore = dataStore ?? RelationalDataStore();

  @override
  Future<Student?> getUserProfile(String userId) async {
    return safeCall(() async {
      return _dataStore.getUser(userId);
    });
  }

  @override
  Future<Student> updateUserProfile(Student student) async {
    return safeCall(() async {
      return _dataStore.updateUser(student);
    });
  }

  @override
  Future<Student> getOrCreateUser({required String phoneNumber, String? fullName}) async {
    return safeCall(() async {
      return _dataStore.createOrFindUser(
        phoneNumber: phoneNumber,
        fullName: fullName,
      );
    });
  }
}
