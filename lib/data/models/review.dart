import 'package:uuid/uuid.dart';

class Review {
  final String id;
  final String productId;
  final String user;
  final String userId;
  final double rating;
  final String title;
  final String comment;
  final DateTime date;
  final bool verifiedPurchase;

  Review({
    String? id,
    required this.productId,
    required this.user,
    required this.userId,
    required this.rating,
    required this.title,
    required this.comment,
    DateTime? date,
    this.verifiedPurchase = false,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String? ?? const Uuid().v4(),
      productId: json['productId'] as String,
      user: json['user'] as String,
      userId: json['userId'] as String,
      rating: (json['rating'] as num).toDouble(),
      title: json['title'] as String,
      comment: json['comment'] as String,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : null,
      verifiedPurchase: json['verifiedPurchase'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'user': user,
        'userId': userId,
        'rating': rating,
        'title': title,
        'comment': comment,
        'date': date.toIso8601String(),
        'verifiedPurchase': verifiedPurchase,
      };
}
