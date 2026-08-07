class User {
  int id;
  String firstName;
  String lastName;
  String phone;
  String image;
  User(
      {required this.id,
        required this.firstName,
        required this.lastName,
        required this.phone,
        required this.image,}
      );
  factory User.fromJson(Map<String,dynamic> json){
    return User(
        id: json['id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        phone: json['phone'],
        image: json['image']
    );
  }
}