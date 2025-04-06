class BusinessInfo {
  int? id;
  String? businessName;
  String? address;
  String? phone;
  String? email;
  String? taxId;
  String? website;

  BusinessInfo({
    this.id,
     this.businessName,
     this.address,
    this.phone,
    this.email,
    this.taxId,
   this.website,
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
