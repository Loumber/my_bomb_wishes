class Wish {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? link;
  final double? price;
  final String? imageUrl;
  final bool isFulfilled;
  final bool isSecret;
  final String? reservedBy;

  Wish({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.link,
    this.price,
    this.imageUrl,
    this.isFulfilled = false,
    this.isSecret = false,
    this.reservedBy,
  });

  factory Wish.fromMap(Map<String, dynamic> map) {
    return Wish(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      link: map['link'] as String?,
      price: map['price'] != null ? (map['price'] as num).toDouble() : null,
      imageUrl: map['image_url'] as String?,
      isFulfilled: map['is_fulfilled'] as bool? ?? false,
      isSecret: map['is_secret'] as bool? ?? false,
      reservedBy: map['reserved_by'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'user_id': userId,
      'description': description,
      'link': link,
      'price': price,
      'image_url': imageUrl,
      'is_fulfilled': isFulfilled,
      'is_secret': isSecret,
      'reserved_by': reservedBy,
    };
  }

  Wish copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? link,
    double? price,
    String? imageUrl,
    bool? isFulfilled,
    bool? isSecret,
    String? reservedBy,
  }) {
    return Wish(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isFulfilled: isFulfilled ?? this.isFulfilled,
      isSecret: isSecret ?? this.isSecret,
      reservedBy: reservedBy ?? this.reservedBy,
    );
  }
}
