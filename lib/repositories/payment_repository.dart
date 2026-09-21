import '../../shared/models/payment.dart';
import '../../services/database/relational_data_store.dart';
import 'base_repository.dart';

abstract class PaymentRepository {
  Future<List<Payment>> getPaymentsForUser(String userId);
  Future<List<Payment>> getPaymentsForApplication(String applicationId, String userId);
}

class AppPaymentRepository extends BaseRepository implements PaymentRepository {
  final RelationalDataStore _dataStore;

  AppPaymentRepository({RelationalDataStore? dataStore})
      : _dataStore = dataStore ?? RelationalDataStore();

  @override
  Future<List<Payment>> getPaymentsForUser(String userId) async {
    return safeCall(() async {
      return _dataStore.getPaymentsForUser(userId);
    });
  }

  @override
  Future<List<Payment>> getPaymentsForApplication(String applicationId, String userId) async {
    return safeCall(() async {
      return _dataStore.getPaymentsForApplication(applicationId, userId: userId);
    });
  }
}
