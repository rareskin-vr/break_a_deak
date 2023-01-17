class Product {
  final String p_name;
  final int p_id;
  final int p_cost;
  final int p_availability;
  final String p_details;
  final String p_category;
  int quantity = 0;
  Product(
      {required this.p_category,
      required this.p_name,
      required this.p_id,
      required this.p_cost,
      required this.p_availability,
      required this.p_details});
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        p_category: json["p_category"] ?? '',
        p_name: json["p_name"] ?? '',
        p_id: json["p_id"] ?? '',
        p_cost: json["p_cost"] ?? '',
        p_availability: json["p_availability"] ?? '',
        p_details: json["p_details"] ?? '');
  }
  Map<dynamic, dynamic> toJson() {
    return {
      "p_category": p_category,
      "p_name": p_name,
      "p_id": p_id,
      "p_cost": p_cost,
      "p_availability": p_availability,
      "p_details": p_details,
      "quantity":quantity
    };
  }

}
