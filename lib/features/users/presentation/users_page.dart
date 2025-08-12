import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../user_providers.dart';
import '../../../models/User.dart';
import '../../../UI/UserAddPage.dart';
import '../../../UI/UserEditPage.dart';
import '../../../UI/adminNavDrawer.dart';

// --- State Management for UsersPage ---

enum UserSortType { name, admin }

class UsersPageState {
  final UserSortType sortType;
  UsersPageState({this.sortType = UserSortType.name});
}

class UsersPageController extends StateNotifier<UsersPageState> {
  UsersPageController() : super(UsersPageState());

  void setSortType(UserSortType sortType) {
    state = UsersPageState(sortType: sortType);
  }
}

final usersPageControllerProvider =
    StateNotifierProvider<UsersPageController, UsersPageState>((ref) {
  return UsersPageController();
});

final sortedUsersProvider = Provider<List<User>>((ref) {
  final usersAsync = ref.watch(allUsersProvider);
  final sortType = ref.watch(usersPageControllerProvider).sortType;

  return usersAsync.when(
    data: (users) {
      final sorted = List<User>.from(users);
      sorted.sort((a, b) {
        if (sortType == UserSortType.admin) {
          return (b.manager ?? '0').compareTo(a.manager ?? '0');
        }
        return (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase());
      });
      return sorted;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// --- UI ---

class UsersPage extends ConsumerWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);
    final sortedUsers = ref.watch(sortedUsersProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("Users"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(allUsersProvider.future),
        child: usersAsync.when(
          data: (_) => _buildUserList(context, sortedUsers),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text(err.toString())),
        ),
      ),
      bottomNavigationBar: _buildBottomAppBar(ref),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserAddPage()),
        ),
      ),
    );
  }

  Widget _buildUserList(BuildContext context, List<User> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isArchived = user.archived == "1";
        final isAdmin = user.manager == "1";
        final textColor = isArchived ? Colors.grey[400] : Colors.black;

        return ListTile(
          title: Text(user.name ?? 'No Name', style: TextStyle(color: textColor)),
          subtitle: Text(user.email ?? 'No Email', style: TextStyle(color: textColor)),
          leading: Icon(
            isAdmin ? Icons.fingerprint : Icons.person_outline,
            color: isAdmin ? Colors.blue[200] : null,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserEditPage(user: user)),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomAppBar(WidgetRef ref) {
    final pageController = ref.read(usersPageControllerProvider.notifier);
    final currentSort = ref.watch(usersPageControllerProvider).sortType;

    return BottomAppBar(
      color: const Color.fromRGBO(158, 166, 186, 1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.fingerprint,
              color: currentSort == UserSortType.admin ? Colors.amber : Colors.white,
            ),
            onPressed: () => pageController.setSortType(UserSortType.admin),
          ),
          IconButton(
            icon: Icon(
              MdiIcons.orderAlphabeticalDescending,
              color: currentSort == UserSortType.name ? Colors.amber : Colors.white,
            ),
            onPressed: () => pageController.setSortType(UserSortType.name),
          ),
          IconButton(
            icon:  Icon(MdiIcons.recycle, color: Colors.white),
            onPressed: () => ref.invalidate(allUsersProvider),
          ),
        ],
      ),
    );
  }
}
