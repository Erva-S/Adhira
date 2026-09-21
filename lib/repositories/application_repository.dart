import '../../core/enums/app_enums.dart';
import '../../shared/models/models.dart';
import '../../services/database/relational_data_store.dart';
import 'base_repository.dart';

abstract class ApplicationRepository {
  Future<List<ScholarshipApplication>> getApplicationsForUser(String userId);
  Future<ScholarshipApplication?> getApplicationById(String applicationId, String userId);
  Future<List<ApplicationStatusHistory>> getStatusHistory(String applicationId);
  Future<List<ApplicationAction>> getPendingActions(String userId, {bool onlyOpen = false});
  Future<ApplicationAction?> resolveAction(String actionId, String userId);
  Future<ScholarshipApplication> submitApplication({
    required String userId,
    required String scholarshipId,
    required String scholarshipName,
    required ScholarshipType scholarshipType,
    required String academicYear,
    double? requestedAmount,
    String? remarks,
    List<String> reusedDocumentIds = const [],
  });
}

class AppApplicationRepository extends BaseRepository implements ApplicationRepository {
  final RelationalDataStore _dataStore;

  AppApplicationRepository({RelationalDataStore? dataStore})
      : _dataStore = dataStore ?? RelationalDataStore();

  @override
  Future<List<ScholarshipApplication>> getApplicationsForUser(String userId) async {
    return safeCall(() async {
      return _dataStore.getApplicationsForUser(userId);
    });
  }

  @override
  Future<ScholarshipApplication?> getApplicationById(String applicationId, String userId) async {
    return safeCall(() async {
      return _dataStore.getApplicationById(applicationId, userId: userId);
    });
  }

  @override
  Future<List<ApplicationStatusHistory>> getStatusHistory(String applicationId) async {
    return safeCall(() async {
      return _dataStore.getStatusHistory(applicationId);
    });
  }

  @override
  Future<List<ApplicationAction>> getPendingActions(String userId, {bool onlyOpen = false}) async {
    return safeCall(() async {
      return _dataStore.getActionsForUser(userId, onlyOpen: onlyOpen);
    });
  }

  @override
  Future<ApplicationAction?> resolveAction(String actionId, String userId) async {
    return safeCall(() async {
      return _dataStore.resolveAction(actionId, userId);
    });
  }

  @override
  Future<ScholarshipApplication> submitApplication({
    required String userId,
    required String scholarshipId,
    required String scholarshipName,
    required ScholarshipType scholarshipType,
    required String academicYear,
    double? requestedAmount,
    String? remarks,
    List<String> reusedDocumentIds = const [],
  }) async {
    return safeCall(() async {
      return _dataStore.createApplication(
        userId: userId,
        scholarshipId: scholarshipId,
        scholarshipName: scholarshipName,
        scholarshipType: scholarshipType,
        academicYear: academicYear,
        requestedAmount: requestedAmount,
        remarks: remarks,
        reusedDocumentIds: reusedDocumentIds,
      );
    });
  }
}
