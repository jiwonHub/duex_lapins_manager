import 'package:duex_lapins_manager/core/di/providers.dart';
import 'package:duex_lapins_manager/domain/models/admin_home_content.dart';
import 'package:duex_lapins_manager/domain/models/admin_journal.dart';
import 'package:duex_lapins_manager/domain/models/admin_product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JournalState {
  const JournalState({
    required this.all,
    required this.products,
    this.query = '',
    this.category = 'ALL',
    this.publish = 'ALL',
  });

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
  }) {
    return JournalState(
      all: all ?? this.all,
      products: products ?? this.products,
      query: query ?? this.query,
      category: category ?? this.category,
      publish: publish ?? this.publish,
    );
  }
}

final journalViewModelProvider =
    NotifierProvider<JournalViewModel, JournalState>(JournalViewModel.new);

class JournalViewModel extends Notifier<JournalState> {
  @override
  JournalState build() {
    final repository = ref.read(adminRepositoryProvider);
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

  void save(AdminJournal journal) {
    final repository = ref.read(adminRepositoryProvider);
    repository.saveJournal(journal);
    state = state.copyWith(all: repository.getJournals());
  }
}
