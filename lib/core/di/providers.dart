import 'package:duex_lapins_manager/data/repositories/admin_mock_repository.dart';
import 'package:duex_lapins_manager/domain/repositories/admin_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminMockRepository(),
);
