abstract final class AdminRoutePath {
  static const dashboard = '/';
  static const products = '/products';
  static const productCreate = '/products/new';
  static String productEdit(String productId) => '/products/$productId/edit';
  static const inventory = '/inventory';
  static const orders = '/orders';
  static String orderDetail(String orderId) => '/orders/$orderId';
  static const claims = '/claims';
  static const customers = '/customers';
  static const inquiries = '/inquiries';
  static const homeContent = '/home-content';
  static const journal = '/journal';
  static const journalCreate = '/journal/new';
  static String journalEdit(String journalId) => '/journal/$journalId/edit';
  static const settings = '/settings';
}
