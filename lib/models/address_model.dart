/// User address from GET /api/users/address/
class AddressModel {
  final String? id;
  final String? area;
  final String? houseNo;
  final String? town;
  final String? state;
  final String? pincode;
  final String? landmark;
  final String addressType; // home | work
  final bool isCurrent;

  AddressModel({
    this.id,
    this.area,
    this.houseNo,
    this.town,
    this.state,
    this.pincode,
    this.landmark,
    this.addressType = 'home',
    this.isCurrent = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString(),
      area: json['area']?.toString(),
      houseNo: json['house_no']?.toString(),
      town: json['town']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
      landmark: json['landmark']?.toString(),
      addressType: json['address_type']?.toString() ?? 'home',
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    if (area != null) 'area': area,
    if (houseNo != null) 'house_no': houseNo,
    if (town != null) 'town': town,
    if (state != null) 'state': state,
    if (pincode != null) 'pincode': pincode,
    if (landmark != null) 'landmark': landmark,
    'address_type': addressType,
    'is_current': isCurrent,
  };
}
