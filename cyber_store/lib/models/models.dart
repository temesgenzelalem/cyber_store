// ─────────────────────────────────────────────────────────────────────────────
//  Models
// ─────────────────────────────────────────────────────────────────────────────

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String role;
  final bool isEmailVerified;
  final int loyaltyPoints;
  final String rank;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.role = 'customer',
    this.isEmailVerified = false,
    this.loyaltyPoints = 0,
    this.rank = 'Silver',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'].toString(),
    name: json['name'],
    email: json['email'],
    avatar: json['avatar'],
    role: json['role'] ?? 'customer',
    isEmailVerified: json['email_verified_at'] != null,
    loyaltyPoints: json['loyalty_points'] ?? 0,
    rank: json['rank'] ?? 'Silver',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatar': avatar,
    'role': role,
    'is_email_verified': isEmailVerified,
  };

  bool get isAdmin => role == 'admin';
}

class CouponModel {
  final String id;
  final String code;
  final String type; // fixed | percent
  final double value;
  final double minOrderValue;
  final DateTime? expiresAt;

  CouponModel({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.minOrderValue,
    this.expiresAt,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) => CouponModel(
    id: json['id'].toString(),
    code: json['code'],
    type: json['type'],
    value: (json['value'] as num).toDouble(),
    minOrderValue: (json['min_order_value'] as num).toDouble(),
    expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
  );
}

class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String? description;
  final String category;
  final double price;
  final double? originalPrice;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final String sku;
  final bool featured;
  final bool inStock;
  final Map<String, dynamic> specs;     // screen, cpu, memory…
  final List<String> colors;
  final List<String> storageOptions;
  final DateTime createdAt;
  final String? arModelUrl;

  const ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    this.description,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.images,
    required this.rating,
    required this.reviewCount,
    required this.sku,
    this.featured = false,
    this.inStock = true,
    this.specs = const {},
    this.colors = const [],
    this.storageOptions = const [],
    required this.createdAt,
    this.arModelUrl,
    this.variants = const [],
  });
}

class ProductVariantModel {
  final String id;
  final String? color;
  final String? storage;
  final double? price;
  final int stock;

  ProductVariantModel({
    required this.id,
    this.color,
    this.storage,
    this.price,
    required this.stock,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) => ProductVariantModel(
    id: json['id'].toString(),
    color: json['color'],
    storage: json['storage'],
    price: json['price'] != null ? (json['price'] as num).toDouble() : null,
    stock: json['stock'] ?? 0,
  );
}

  factory ProductModel.fromFirestore(String id, Map<String, dynamic> data) {
    return ProductModel(
      id:             id,
      name:           data['name']           ?? '',
      brand:          data['brand']          ?? '',
      category:       data['category']       ?? '',
      price:          (data['price'] as num).toDouble(),
      originalPrice:  data['original_price'] != null
          ? (data['original_price'] as num).toDouble()
          : null,
      images:         List<String>.from(data['images'] ?? []),
      rating:         (data['rating'] as num? ?? 0).toDouble(),
      reviewCount:    data['review_count']   ?? 0,
      sku:            data['sku']            ?? '',
      description:    data['description'],
      featured:       data['featured']       ?? false,
      inStock:        data['in_stock']       ?? true,
      specs:          Map<String, dynamic>.from(data['specs'] ?? {}),
      colors:         List<String>.from(data['colors'] ?? []),
      storageOptions: List<String>.from(data['storage_options'] ?? []),
      arModelUrl:     data['ar_model_url'],
      createdAt: data['created_at'] != null
          ? (data['created_at'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id:             json['id'].toString(),
      name:           json['name']           ?? '',
      brand:          json['brand']          ?? '',
      category:       json['category'] != null ? (json['category'] is String ? json['category'] : json['category']['name'] ?? '') : '',
      price:          (json['price'] as num).toDouble(),
      originalPrice:  json['original_price'] != null
          ? (json['original_price'] as num).toDouble()
          : null,
      images:         List<String>.from(json['images'] ?? []),
      rating:         (json['rating'] as num? ?? 0).toDouble(),
      reviewCount:    json['review_count']   ?? 0,
      sku:            json['sku']            ?? '',
      description:    json['description'],
      arModelUrl:     json['ar_model_url'],
      featured:       json['featured']       ?? false,
      inStock:        json['in_stock']       ?? true,
      specs:          Map<String, dynamic>.from(json['specs'] ?? {}),
      colors:         List<String>.from(json['colors'] ?? []),
      storageOptions: List<String>.from(json['storage_options'] ?? []),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      variants: json['variants'] != null
          ? (json['variants'] as List).map((e) => ProductVariantModel.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name':           name,
    'brand':          brand,
    'description':    description,
    'category':       category,
    'price':          price,
    'original_price': originalPrice,
    'images':         images,
    'rating':         rating,
    'review_count':   reviewCount,
    'sku':            sku,
    'featured':       featured,
    'in_stock':       inStock,
    'specs':          specs,
    'colors':         colors,
    'storage_options':storageOptions,
    'created_at':     createdAt,
    'ar_model_url':   arModelUrl,
  };
}

// ─────────────────────────────────────────────────────────────────────────────

class CartItem {
  final String productId;
  final String name;
  final double price;
  final String image;
  int qty;
  final String sku;
  final String? color;
  final String? storage;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.image,
    required this.qty,
    required this.sku,
    this.color,
    this.storage,
  });

  double get subtotal => price * qty;

  Map<String, dynamic> toMap() => {
    'product_id': productId,
    'name':       name,
    'price':      price,
    'image':      image,
    'qty':        qty,
    'sku':        sku,
    'color':      color,
    'storage':    storage,
  };

  factory CartItem.fromMap(Map<String, dynamic> m) => CartItem(
    productId: m['product_id'] ?? '',
    name:      m['name']       ?? '',
    price:     (m['price'] as num).toDouble(),
    image:     m['image']      ?? '',
    qty:       m['qty']        ?? 1,
    sku:       m['sku']        ?? '',
    color:     m['color'],
    storage:   m['storage'],
  );

  CartItem copyWith({int? qty}) => CartItem(
    productId: productId, name: name, price: price,
    image: image, qty: qty ?? this.qty, sku: sku,
    color: color, storage: storage,
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class AddressModel {
  final String id;
  final String label; // HOME | OFFICE | OTHER
  final String street;
  final String city;
  final String state;
  final String zip;
  final String phone;
  final double? latitude;
  final double? longitude;

  const AddressModel({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
    required this.phone,
    this.latitude,
    this.longitude,
  });

  String get fullAddress => '$street, $city, $state $zip';

  factory AddressModel.fromFirestore(String id, Map<String, dynamic> d) =>
      AddressModel(
        id:     id,
        label:  d['label']  ?? 'HOME',
        street: d['street'] ?? '',
        city:   d['city']   ?? '',
        state:  d['state']  ?? '',
        zip:    d['zip']    ?? '',
        phone:  d['phone']  ?? '',
        latitude: d['latitude'],
        longitude: d['longitude'],
      );

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json['id'].toString(),
        label: json['label'] ?? 'HOME',
        street: json['street'] ?? '',
        city: json['city'] ?? '',
        state: json['state'] ?? '',
        zip: json['zip'] ?? '',
        phone: json['phone'] ?? '',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toFirestore() => {
    'label': label, 'street': street, 'city': city,
    'state': state, 'zip': zip, 'phone': phone,
    'latitude': latitude, 'longitude': longitude,
  };
}

// ─────────────────────────────────────────────────────────────────────────────

class ReviewModel {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(String id, Map<String, dynamic> d) =>
      ReviewModel(
        id:         id,
        userName:   d['user_name']   ?? 'Anonymous',
        userAvatar: d['user_avatar'] ?? '',
        rating:     (d['rating'] as num? ?? 5).toDouble(),
        comment:    d['comment']     ?? '',
        createdAt: d['created_at'] != null
            ? (d['created_at'] as dynamic).toDate()
            : DateTime.now(),
      );

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      ReviewModel(
        id:         json['id'].toString(),
        userName:   json['user']?['name'] ?? 'Anonymous',
        userAvatar: json['user']?['avatar'] ?? '',
        rating:     (json['rating'] as num? ?? 5).toDouble(),
        comment:    json['comment'] ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class OrderModel {
  final String id;
  final List<CartItem> items;
  final String addressId;
  final String shippingMethod;
  final String paymentMethod;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final String status;
  final DateTime createdAt;
  final double discountAmount;
  final double walletDeduction;
  final List<Map<String, dynamic>> trackingSteps;

  const OrderModel({
    required this.id,
    required this.items,
    required this.addressId,
    required this.shippingMethod,
    required this.paymentMethod,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    required this.status,
    required this.createdAt,
    this.discountAmount = 0,
    this.walletDeduction = 0,
    this.trackingSteps = const [],
  });
}

// ─────────────────────────────────────────────────────────────────────────────

class CategoryModel {
  final String id;
  final String name;
  final String icon; // URL or asset name
  final int productCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.productCount,
  });

  factory CategoryModel.fromFirestore(String id, Map<String, dynamic> d) =>
      CategoryModel(
        id:           id,
        name:         d['name']          ?? '',
        icon:         d['icon']          ?? '',
        productCount: d['product_count'] ?? 0,
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String ctaLabel;
  final String? productId;
  final String? category;

  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.ctaLabel,
    this.productId,
    this.category,
  });

  factory BannerModel.fromFirestore(String id, Map<String, dynamic> d) =>
      BannerModel(
        id:        id,
        title:     d['title']     ?? '',
        subtitle:  d['subtitle']  ?? '',
        imageUrl:  d['image_url'] ?? '',
        ctaLabel:  d['cta_label'] ?? 'Shop Now',
        productId: d['product_id'],
        category:  d['category'],
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class ProductFilter {
  final double? minPrice;
  final double? maxPrice;
  final List<String> brands;
  final List<String> memories;
  final String? protectionClass;
  final String? screenDiagonal;
  final String? screenType;
  final String? batteryCapacity;
  final String sortBy; // rating | price_asc | price_desc | newest

  const ProductFilter({
    this.minPrice,
    this.maxPrice,
    this.brands = const [],
    this.memories = const [],
    this.protectionClass,
    this.screenDiagonal,
    this.screenType,
    this.batteryCapacity,
    this.sortBy = 'rating',
  });

  ProductFilter copyWith({
    double? minPrice,
    double? maxPrice,
    List<String>? brands,
    List<String>? memories,
    String? protectionClass,
    String? screenDiagonal,
    String? screenType,
    String? batteryCapacity,
    String? sortBy,
  }) => ProductFilter(
    minPrice:        minPrice        ?? this.minPrice,
    maxPrice:        maxPrice        ?? this.maxPrice,
    brands:          brands          ?? this.brands,
    memories:        memories        ?? this.memories,
    protectionClass: protectionClass ?? this.protectionClass,
    screenDiagonal:  screenDiagonal  ?? this.screenDiagonal,
    screenType:      screenType      ?? this.screenType,
    batteryCapacity: batteryCapacity ?? this.batteryCapacity,
    sortBy:          sortBy          ?? this.sortBy,
  );

  bool get hasFilters =>
      minPrice != null || maxPrice != null ||
      brands.isNotEmpty || memories.isNotEmpty ||
      protectionClass != null || screenDiagonal != null ||
      screenType != null || batteryCapacity != null;
}
