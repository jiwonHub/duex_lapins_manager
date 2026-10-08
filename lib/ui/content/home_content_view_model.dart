import 'package:duex_lapins_manager/core/di/providers.dart';
import 'package:duex_lapins_manager/domain/models/admin_home_content.dart';
import 'package:duex_lapins_manager/domain/models/admin_product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeContentState {
  const HomeContentState({
    required this.content,
    required this.products,
  });

  final AdminHomeContent content;
  final List<AdminProduct> products;

  HomeContentState copyWith({
    AdminHomeContent? content,
    List<AdminProduct>? products,
  }) {
    return HomeContentState(
      content: content ?? this.content,
      products: products ?? this.products,
    );
  }
}

final homeContentViewModelProvider =
    NotifierProvider<HomeContentViewModel, HomeContentState>(
  HomeContentViewModel.new,
);

class HomeContentViewModel extends Notifier<HomeContentState> {
  @override
  HomeContentState build() {
    final repository = ref.read(adminRepositoryProvider);
    return HomeContentState(
      content: repository.getHomeContent(),
      products: repository.getProducts(),
    );
  }

  void save(AdminHomeContent content) {
    final repository = ref.read(adminRepositoryProvider);
    repository.saveHomeContent(content);
    state = state.copyWith(content: repository.getHomeContent());
  }
}
