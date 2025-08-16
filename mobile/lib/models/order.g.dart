// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      customerName: json['customerName'] as String,
      tableNumber: (json['tableNumber'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'items': instance.items,
      'status': instance.status,
      'totalAmount': instance.totalAmount,
      'customerName': instance.customerName,
      'tableNumber': instance.tableNumber,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
      menuItem: MenuItem.fromJson(json['menuItem'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toInt(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
      'menuItem': instance.menuItem,
      'quantity': instance.quantity,
      'notes': instance.notes,
    };
