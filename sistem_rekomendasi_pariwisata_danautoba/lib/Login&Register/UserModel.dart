class UserModel {
  String uid;
  String username;
  String email;
  String phone;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.phone,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      username: data['username'],
      email: data['email'],
      phone: data['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'phone': phone,
    };
  }
}
