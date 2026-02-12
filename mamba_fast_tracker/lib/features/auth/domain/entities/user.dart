import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String name;
  final String role;
  final String avatar;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.avatar,
  });

  @override
  List<Object> get props => [id, email, name, role, avatar];
}
