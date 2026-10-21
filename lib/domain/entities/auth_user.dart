import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String id;
  final String? email;
  final bool emailVerified;
  final String? displayName;
  final String? photoUrl;

  const AuthUser({
    required this.id,
    this.email,
    this.emailVerified = false,
    this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, email, emailVerified, displayName, photoUrl];
}
