class BusinessInfo {
  final int? id;  // Can be null for new business info
  final String businessName;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String? taxId;  // Optional field
  final String createdBy;  // Username of the creator
  final String? logoBase64;  // Base64 encoded logo image, can be null

  BusinessInfo({
    this.id,
    required this.businessName,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    this.taxId,
    required this.createdBy,
    this.logoBase64,
  });

  // Create a copy of BusinessInfo with optional field updates
  BusinessInfo copyWith({
    int? id,
    String? businessName,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? taxId,
    String? createdBy,
    String? logoBase64,
  }) {
    return BusinessInfo(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      taxId: taxId ?? this.taxId,
      createdBy: createdBy ?? this.createdBy,
      logoBase64: logoBase64 ?? this.logoBase64,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'businessName': businessName,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      if (taxId != null) 'taxId': taxId,
      'createdBy': createdBy,
      if (logoBase64 != null) 'logoBase64': logoBase64,
    };
  }

  factory BusinessInfo.fromJson(Map<String, dynamic> json) {
    return BusinessInfo(
      id: json['id'] != null ? json['id'] as int : null,
      businessName: json['businessName'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      website: json['website'] as String? ?? '',
      taxId: json['taxId'] as String?,
      createdBy: json['createdBy'] as String? ?? '',
      logoBase64: json['logoBase64'] as String?,
    );
  }

}
