import 'package:deux_lapins_manager/core/di/providers.dart';
import 'package:deux_lapins_manager/domain/models/admin_home_content.dart';
import 'package:deux_lapins_manager/domain/models/admin_product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeContentState {
  const HomeContentState({
    required this.content,
    required this.products,
    this.loading = false,
    this.saving = false,
    this.errorMessage,
  });

  final AdminHomeContent content;
  final List<AdminProduct> products;
  final bool loading;
  final bool saving;
  final String? errorMessage;

  HomeContentState copyWith({
    AdminHomeContent? content,
    List<AdminProduct>? products,
    bool? loading,
    bool? saving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeContentState(
      content: content ?? this.content,
      products: products ?? this.products,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
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
    Future<void>.microtask(refresh);
    return HomeContentState(
      content: repository.getHomeContent(),
      products: repository.getProducts(),
    );
  }

  Future<void> refresh() async {
    if (state.saving || state.loading) return;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final repository = ref.read(adminRepositoryProvider);
      final content = await repository.fetchHomeContentApi();
      final products = await repository.fetchProductsApi();
      state = state.copyWith(content: content, products: products, loading: false);
    } catch (error) {
      state = state.copyWith(loading: false, errorMessage: '$error');
    }
  }

  Future<void> save(AdminHomeContent content) async {
    if (state.saving || state.loading) {
      throw StateError('홈페이지 콘텐츠 요청이 진행 중입니다.');
    }
    state = state.copyWith(saving: true, clearError: true);
    try {
      final saved = await ref.read(adminRepositoryProvider).saveHomeContentApi(content);
      state = state.copyWith(content: saved, saving: false);
    } catch (error) {
      state = state.copyWith(saving: false, errorMessage: '$error');
      rethrow;
    }
  }
}
