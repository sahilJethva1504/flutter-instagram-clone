// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserModel {
  String email;
  String username;
  String bio;
  String profile;
  List followers;
  List following;
  UserModel({
    required this.email,
    required this.username,
    required this.bio,
    required this.profile,
    required this.followers,
    required this.following,
  });

  static fromMap(Map<String, dynamic> data) {}
}
