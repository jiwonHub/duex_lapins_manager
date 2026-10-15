import 'package:deux_lapins_manager/core/di/providers.dart';
import 'package:deux_lapins_manager/domain/models/admin_inquiry.dart';
import 'package:deux_lapins_manager/ui/dashboard/dashboard_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InquiriesState {
  const InquiriesState({
    required this.all,
    this.query = '',
    this.type,
    this.status,
    this.loading = false,
    this.saving = false,
    this.errorMessage,
  });

  final bool loading;
  final bool saving;
  final String? errorMessage;
  final List<AdminInquiry> all;
  final String query;
  final AdminInquiryType? type;
  final AdminInquiryStatus? status;

  List<AdminInquiry> get visible {
    final normalized = query.trim().toLowerCase();
    return all.where((inquiry) {
      final queryOk = normalized.isEmpty ||
          inquiry.title.toLowerCase().contains(normalized) ||
          inquiry.customerName.toLowerCase().contains(normalized) ||
          inquiry.question.toLowerCase().contains(normalized);
      final typeOk = type == null || inquiry.type == type;
      final statusOk = status == null || inquiry.status == status;
      return queryOk && typeOk && statusOk;
    }).toList();
  }

  InquiriesState copyWith({
    List<AdminInquiry>? all,
    String? query,
    AdminInquiryType? type,
    bool clearType = false,
    AdminInquiryStatus? status,
    bool clearStatus = false,
    bool? loading,
    bool? saving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InquiriesState(
      all: all ?? this.all,
      query: query ?? this.query,
      type: clearType ? null : type ?? this.type,
      status: clearStatus ? null : status ?? this.status,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final inquiriesViewModelProvider =
    NotifierProvider<InquiriesViewModel, InquiriesState>(InquiriesViewModel.new);

class InquiriesViewModel extends Notifier<InquiriesState> {
  @override
  InquiriesState build() {
    Future<void>.microtask(refresh);
    return InquiriesState(all: ref.read(adminRepositoryProvider).getInquiries());
  }

  void search(String value) => state = state.copyWith(query: value);
  void selectType(AdminInquiryType? type) => state = type == null
      ? state.copyWith(clearType: true)
      : state.copyWith(type: type);
  void selectStatus(AdminInquiryStatus? status) => state = status == null
      ? state.copyWith(clearStatus: true)
      : state.copyWith(status: status);

  Future<void> answer(String inquiryId, String answer) async {
    if (state.saving || state.loading) {
      throw StateError('다른 문의 요청이 진행 중입니다.');
    }
    state = state.copyWith(saving: true, clearError: true);
    try {
      await ref.read(adminRepositoryProvider).answerInquiryApi(inquiryId, answer);
      final inquiries = await ref.read(adminRepositoryProvider).fetchInquiriesApi();
      state = state.copyWith(all: inquiries, saving: false);
      ref.invalidate(dashboardViewModelProvider);
    } catch (error) {
      state = state.copyWith(saving: false, errorMessage: '$error');
      rethrow;
    }
  }

  Future<void> refresh() async {
    if (state.saving || state.loading) return;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final inquiries = await ref.read(adminRepositoryProvider).fetchInquiriesApi();
      state = state.copyWith(all: inquiries, loading: false);
    } catch (error) {
      state = state.copyWith(loading: false, errorMessage: '$error');
    }
  }
}
