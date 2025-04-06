class Client {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? nid;
  String? address;

  Client({
    this.id,
     this.name,
     this.email,
     this.phone,
     this.nid,
     this.address,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      nid: json['nid'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'nid': nid,
        'address': address,
      };
}
