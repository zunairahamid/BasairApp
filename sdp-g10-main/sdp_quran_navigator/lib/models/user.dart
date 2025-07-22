

class User {
  
  final String email;
  final String password;
  final String uid;

  final String userType;
  final String userPay;

  User({
    
    required this.email,
    required this.password,

    required this.uid,
    required this.userType,
    required this.userPay,

  });

  Map<String, dynamic> toMap() {
    return {
      
      'email': email,
      'password': password,
      'uid': uid,
      'userType':userType,
      'userPay':userPay
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      uid: map['uid'] ?? '',
      userType: map['userType'] ?? '',
      userPay: map['userPay'] ?? '',
    );
  }

  @override
  String toString() {
    return 'User(email: $email, password: $password, uid: $uid}';
  }
}