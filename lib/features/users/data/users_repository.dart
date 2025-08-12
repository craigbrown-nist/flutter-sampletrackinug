import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/User.dart';
import '../../../providers.dart';
import '../../auth/auth_repository.dart';

/// Repository for user-related data operations.
class UsersRepository {
  final Ref _ref;
  UsersRepository(this._ref);

  /// Fetches a list of all users.
  Future<List<User>> getUsers() async {
    final apiClient = _ref.read(apiClientProvider);
    final jwt = _ref.read(authStateProvider);

    if (jwt == null) {
      // If there's no JWT, we can't fetch users.
      return [];
    }
    return apiClient.getUsers(jwt);
  }
}
