class BusinessInfo {
  int? id;
  String businessName;
  String address;
  String phone;
  String email;
  String taxId;
  String website;

  BusinessInfo({
    this.id,
    required this.businessName,
    required this.address,
    required this.phone,
    required this.email,
    required this.taxId,
    required this.website,
  });

  factory BusinessInfo.fromJson(Map<String, dynamic> json) {
    return BusinessInfo(
      id: json['id'],
      businessName: json['businessName'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      taxId: json['taxId'],
      website: json['website'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'businessName': businessName,
        'address': address,
        'phone': phone,
        'email': email,
        'taxId': taxId,
        'website': website,
      };
}
