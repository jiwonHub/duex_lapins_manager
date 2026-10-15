import 'package:deux_lapins_manager/core/di/providers.dart';
import 'package:deux_lapins_manager/domain/models/admin_customer.dart';
import 'package:deux_lapins_manager/domain/models/admin_order.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomersState {
  const CustomersState({required this.all, this.query = ''});

  final List<AdminCustomer> all;
  final String query;

  List<AdminCustomer> get visible {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return all;
    return all.where((customer) {
      return customer.name.toLowerCase().contains(normalized) ||
          customer.email.toLowerCase().contains(normalized) ||
          customer.phone.toLowerCase().contains(normalized);
    }).toList();
  }

  CustomersState copyWith({String? query}) {
    return CustomersState(all: all, query: query ?? this.query);
  }
}

final customersViewModelProvider =
    NotifierProvider<CustomersViewModel, CustomersState>(CustomersViewModel.new);

class CustomersViewModel extends Notifier<CustomersState> {
  @override
  CustomersState build() {
    return CustomersState(all: ref.read(adminRepositoryProvider).getCustomers());
  }

  void search(String value) => state = state.copyWith(query: value);

  List<AdminOrder> ordersFor(String customerId) {
    return ref.read(adminRepositoryProvider).getOrdersForCustomer(customerId);
  }
}
