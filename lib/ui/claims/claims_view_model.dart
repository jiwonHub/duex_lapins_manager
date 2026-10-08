import 'package:duex_lapins_manager/core/di/providers.dart';
import 'package:duex_lapins_manager/domain/models/admin_claim.dart';
import 'package:duex_lapins_manager/ui/dashboard/dashboard_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClaimsState {
  const ClaimsState({
    required this.all,
    this.type,
    this.status,
    this.page = 1,
    this.pageSize = 20,
  });

  final List<AdminClaim> all;
  final AdminClaimType? type;
  final AdminClaimProcessStatus? status;
  final int page;
  final int pageSize;

  List<AdminClaim> get visible {
    return all.where((claim) {
      final typeOk = type == null || claim.type == type;
      final statusOk = status == null || claim.processStatus == status;

      return typeOk && statusOk;
    }).toList();
  }

  int get totalItems => visible.length;

  int get totalPages {
    if (totalItems == 0) {
      return 1;
    }

    return ((totalItems - 1) ~/ pageSize) + 1;
  }

  int get effectivePage {
    if (page < 1) {
      return 1;
    }

    if (page > totalPages) {
      return totalPages;
    }

    return page;
  }

  List<AdminClaim> get paged {
    final items = visible;

    if (items.isEmpty) {
      return const [];
    }

    final start = (effectivePage - 1) * pageSize;

    final end = start + pageSize > items.length
        ? items.length
        : start + pageSize;

    return items.sublist(
      start,
      end,
    );
  }

  ClaimsState copyWith({
    List<AdminClaim>? all,
    AdminClaimType? type,
    bool clearType = false,
    AdminClaimProcessStatus? status,
    bool clearStatus = false,
    int? page,
    int? pageSize,
  }) {
    return ClaimsState(
      all: all ?? this.all,
      type: clearType ? null : type ?? this.type,
      status: clearStatus ? null : status ?? this.status,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

final claimsViewModelProvider =
    NotifierProvider<ClaimsViewModel, ClaimsState>(ClaimsViewModel.new);

class ClaimsViewModel extends Notifier<ClaimsState> {
  @override
  ClaimsState build() {
    return ClaimsState(all: ref.read(adminRepositoryProvider).getClaims());
  }

  void selectType(AdminClaimType? type) {
    state = type == null
        ? state.copyWith(
      clearType: true,
      page: 1,
    )
        : state.copyWith(
      type: type,
      page: 1,
    );
  }

  void selectStatus(AdminClaimProcessStatus? status) {
    state = status == null
        ? state.copyWith(
      clearStatus: true,
      page: 1,
    )
        : state.copyWith(
      status: status,
      page: 1,
    );
  }

  void setPage(int value) {
    if (value < 1 || value > state.totalPages) {
      return;
    }

    state = state.copyWith(
      page: value,
    );
  }

  void setPageSize(int value) {
    state = state.copyWith(
      pageSize: value,
      page: 1,
    );
  }

  void updateClaim(AdminClaim claim) {
    final repository = ref.read(adminRepositoryProvider);
    repository.updateClaim(claim);
    state = state.copyWith(all: repository.getClaims());
    ref.invalidate(dashboardViewModelProvider);
  }
}
