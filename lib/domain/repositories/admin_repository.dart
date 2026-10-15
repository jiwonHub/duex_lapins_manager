import 'package:deux_lapins_manager/domain/models/admin_claim.dart';
import 'package:deux_lapins_manager/domain/models/admin_customer.dart';
import 'package:deux_lapins_manager/domain/models/admin_home_content.dart';
import 'package:deux_lapins_manager/domain/models/admin_inquiry.dart';
import 'package:deux_lapins_manager/domain/models/admin_journal.dart';
import 'package:deux_lapins_manager/domain/models/admin_order.dart';
import 'package:deux_lapins_manager/domain/models/admin_product.dart';
import 'package:deux_lapins_manager/domain/models/admin_store_settings.dart';

abstract interface class AdminRepository {
  List<AdminProduct> getProducts();
  AdminProduct? getProduct(String productId);
  void addProduct(AdminProduct product);
  void updateProduct(AdminProduct product);
  void updateInventory({
    required String productId,
    required String color,
    required String size,
    required int quantity,
  });

  Future<List<AdminProduct>> fetchProductsApi();
  Future<AdminProduct?> fetchProductApi(String productId);
  Future<AdminProduct> saveProductApi(AdminProduct product);
  Future<AdminProduct> updateInventoryApi({
    required String productId,
    required String color,
    required String size,
    required int quantity,
  });
  Future<void> deleteProductApi(String productId);

  Future<List<AdminOrder>> fetchOrdersApi();
  Future<AdminOrder?> fetchOrderApi(String orderId);
  Future<AdminOrder> saveOrderApi(AdminOrder order);
  Future<void> bulkShipOrdersApi({
    required List<String> orderIds,
    required String carrier,
    required Map<String, String> trackingNumbers,
  });

  Future<List<AdminClaim>> fetchClaimsApi();
  Future<AdminClaim> saveClaimApi(AdminClaim claim);
  Future<List<AdminInquiry>> fetchInquiriesApi();
  Future<AdminInquiry> answerInquiryApi(String inquiryId, String answer);

  List<AdminOrder> getOrders();
  AdminOrder? getOrder(String orderId);
  void addOrder(AdminOrder order);
  void updateOrder(AdminOrder order);
  void updateOrderStatus(String orderId, AdminOrderStatus status);
  void bulkShipOrders({
    required List<String> orderIds,
    required String carrier,
    required Map<String, String> trackingNumbers,
  });

  List<AdminClaim> getClaims();
  void updateClaim(AdminClaim claim);

  List<AdminCustomer> getCustomers();
  AdminCustomer? getCustomer(String customerId);
  List<AdminOrder> getOrdersForCustomer(String customerId);

  List<AdminInquiry> getInquiries();
  void answerInquiry(String inquiryId, String answer);

  Future<AdminHomeContent> fetchHomeContentApi();
  Future<AdminHomeContent> saveHomeContentApi(AdminHomeContent content);
  Future<List<AdminJournal>> fetchJournalsApi();
  Future<AdminJournal?> fetchJournalApi(String journalId);
  Future<AdminJournal> saveJournalApi(AdminJournal journal);
  Future<AdminStoreSettings> fetchSettingsApi();
  Future<AdminStoreSettings> saveSettingsApi(AdminStoreSettings settings);

  AdminHomeContent getHomeContent();
  void saveHomeContent(AdminHomeContent content);

  List<AdminJournal> getJournals();
  AdminJournal? getJournal(String journalId);
  void saveJournal(AdminJournal journal);

  AdminStoreSettings getSettings();
  void saveSettings(AdminStoreSettings settings);
}
