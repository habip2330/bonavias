import 'package:json_annotation/json_annotation.dart';
import 'menu_item.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  final String id;
  final List<OrderItem> items;
  final String status;
  final double totalAmount;
  final String customerName;
  final int? tableNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.items,
    required this.status,
    required this.totalAmount,
    required this.customerName,
    this.tableNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

@JsonSerializable()
class OrderItem {
  final MenuItem menuItem;
  final int quantity;
  final String? notes;

  OrderItem({
    required this.menuItem,
    required this.quantity,
    this.notes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
} 