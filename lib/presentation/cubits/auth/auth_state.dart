import 'package:veyra/domain/entities/auth_user.dart';
import 'package:veyra/presentation/cubits/auth/auth_status.dart';

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? message;
  
  const AuthState({this.status = AuthStatus.initial, this.user, this.message});
  bool get isLoading => status == AuthStatus.loading;
}

//aslında bu model değil mi?