import 'package:linkup/feature/chat/data/user_item_model.dart';

abstract class AllUsersState {
  const AllUsersState();

  List<Object?> get props => [];
}

class AllUsersLoading extends AllUsersState {}

class AllUsersLoaded extends AllUsersState {
  final List<UserItem> users;

  const AllUsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class AllUsersError extends AllUsersState {
  final String errorMessage;

  const AllUsersError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
