class User {
  
  final String email;
  final String password;
  final String uid;

  

  User({
    
    required this.email,
    required this.password,

    required this.uid,
    

  });

  Map<String, dynamic> toMap() {
    return {
      
      'email': email,
      'password': password,
      'uid': uid,
      
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      uid: map['uid'] ?? '',
      
    );
  }

  @override
  String toString() {
    return 'User(email: $email, password: $password, uid: $uid}';
  }
}