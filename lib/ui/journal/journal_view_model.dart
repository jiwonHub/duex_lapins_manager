import 'package:deux_lapins_manager/core/di/providers.dart';
import 'package:deux_lapins_manager/domain/models/admin_home_content.dart';
import 'package:deux_lapins_manager/domain/models/admin_journal.dart';
import 'package:deux_lapins_manager/domain/models/admin_product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JournalState {
  const JournalState({
    required this.all,
    required this.products,
    this.query = '',
    this.category = 'ALL',
    this.publish = 'ALL',
    this.loading = false,
    this.saving = false,
    this.errorMessage,
  });

  final bool loading;
  final bool saving;
  final String? errorMessage;
  final List<AdminJournal> all;
  final List<AdminProduct> products;
  final String query;
  final String category;
  final String publish;

  List<AdminJournal> get visible {
    final normalized = query.trim().toLowerCase();
    return all.where((journal) {
      final queryOk = normalized.isEmpty ||
          journal.title.toLowerCase().contains(normalized) ||
          journal.body.toLowerCase().contains(normalized);
      final categoryOk = category == 'ALL' || journal.category == category;
      final publishOk = publish == 'ALL' || journal.publishStatus.label == publish;
      return queryOk && categoryOk && publishOk;
    }).toList();
  }

  JournalState copyWith({
    List<AdminJournal>? all,
    List<AdminProduct>? products,
    String? query,
    String? category,
    String? publish,
    bool? loading,
    bool? saving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return JournalState(
      all: all ?? this.all,
      products: products ?? this.products,
      query: query ?? this.query,
      category: category ?? this.category,
      publish: publish ?? this.publish,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final journalViewModelProvider =
    NotifierProvider<JournalViewModel, JournalState>(JournalViewModel.new);

class JournalViewModel extends Notifier<JournalState> {
  @override
  JournalState build() {
    final repository = ref.read(adminRepositoryProvider);
    Future<void>.microtask(refresh);
    return JournalState(
      all: repository.getJournals(),
      products: repository.getProducts(),
    );
  }

  void search(String value) => state = state.copyWith(query: value);
  void selectCategory(String value) => state = state.copyWith(category: value);
  void selectPublish(String value) => state = state.copyWith(publish: value);

  AdminJournal? getById(String journalId) {
    return ref.read(adminRepositoryProvider).getJournal(journalId);
  }

  Future<void> save(AdminJournal journal) async {
    if (state.saving || state.loading) {
      throw StateError('저널 저장 요청이 진행 중입니다.');
    }
    state = state.copyWith(saving: true, clearError: true);
    try {
      final repository = ref.read(adminRepositoryProvider);
      await repository.saveJournalApi(journal);
      final journals = await repository.fetchJournalsApi();
      state = state.copyWith(all: journals, saving: false);
    } catch (error) {
      state = state.copyWith(saving: false, errorMessage: '$error');
      rethrow;
    }
  }

  Future<void> refresh() async {
    if (state.saving || state.loading) return;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final repository = ref.read(adminRepositoryProvider);
      final journals = await repository.fetchJournalsApi();
      final products = await repository.fetchProductsApi();
      state = state.copyWith(all: journals, products: products, loading: false);
    } catch (error) {
      state = state.copyWith(loading: false, errorMessage: '$error');
    }
  }
}
