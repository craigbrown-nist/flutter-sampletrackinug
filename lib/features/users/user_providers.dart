import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/User.dart';
import 'data/users_repository.dart';

/// Provider for the [UsersRepository].
final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository(ref);
});

/// Provider to fetch the list of all users.
/// This now delegates the fetching logic to the [UsersRepository].
final allUsersProvider = FutureProvider<List<User>>((ref) async {
  final usersRepository = ref.watch(usersRepositoryProvider);
  return usersRepository.getUsers();
});
