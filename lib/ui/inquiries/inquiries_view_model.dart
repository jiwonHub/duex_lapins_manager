import 'package:duex_lapins_manager/core/di/providers.dart';
import 'package:duex_lapins_manager/domain/models/admin_inquiry.dart';
import 'package:duex_lapins_manager/ui/dashboard/dashboard_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InquiriesState {
  const InquiriesState({
    required this.all,
    this.query = '',
    this.type,
    this.status,
  });

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
  }) {
    return InquiriesState(
      all: all ?? this.all,
      query: query ?? this.query,
      type: clearType ? null : type ?? this.type,
      status: clearStatus ? null : status ?? this.status,
    );
  }
}

final inquiriesViewModelProvider =
    NotifierProvider<InquiriesViewModel, InquiriesState>(InquiriesViewModel.new);

class InquiriesViewModel extends Notifier<InquiriesState> {
  @override
  InquiriesState build() {
    return InquiriesState(all: ref.read(adminRepositoryProvider).getInquiries());
  }

  void search(String value) => state = state.copyWith(query: value);
  void selectType(AdminInquiryType? type) => state = type == null
      ? state.copyWith(clearType: true)
      : state.copyWith(type: type);
  void selectStatus(AdminInquiryStatus? status) => state = status == null
      ? state.copyWith(clearStatus: true)
      : state.copyWith(status: status);

  void answer(String inquiryId, String answer) {
    final repository = ref.read(adminRepositoryProvider);
    repository.answerInquiry(inquiryId, answer);
    state = state.copyWith(all: repository.getInquiries());
    ref.invalidate(dashboardViewModelProvider);
  }
}
