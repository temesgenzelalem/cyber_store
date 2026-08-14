import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  // IMPORTANT: For physical phone testing, replace 'YOUR_LOCAL_IP'
  // with your computer's actual IP address (e.g., 192.168.1.5)
  static const String baseUrl = 'http://YOUR_LOCAL_IP:8000/api';

  String? _token;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      _token = data['access_token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      return data;
    }
    return null;
  }

  Future<Map<String, dynamic>?> register(String name, String email, String password) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: _headers,
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      _token = data['access_token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      return data;
    }
    return null;
  }

  Future<void> updateFcmToken(String token) async {
    await http.post(
      Uri.parse('$baseUrl/user/fcm-token'),
      headers: _headers,
      body: jsonEncode({'token': token}),
    );
  }

  Future<void> resendVerificationEmail() async {
    final resp = await http.post(Uri.parse('$baseUrl/email/resend'), headers: _headers);
    if (resp.statusCode != 200) throw Exception('Failed to resend email');
  }

  Future<void> logout() async {
    await http.post(Uri.parse('$baseUrl/logout'), headers: _headers);
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<UserModel?> getCurrentUser() async {
    if (_token == null) return null;
    final resp = await http.get(Uri.parse('$baseUrl/user'), headers: _headers);
    if (resp.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(resp.body));
    }
    return null;
  }

  // ── Banners & Categories ──────────────────────────────────────────────────

  Future<List<BannerModel>> getBanners() async {
    final resp = await http.get(Uri.parse('$baseUrl/banners'), headers: _headers);
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      return data.map((e) => BannerModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<CategoryModel>> getCategories() async {
    final resp = await http.get(Uri.parse('$baseUrl/categories'), headers: _headers);
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    }
    return [];
  }

  // ── Products ──────────────────────────────────────────────────────────────

  Future<List<ProductModel>> getProducts({
    String? category,
    ProductFilter? filter,
    int page = 1,
    int perPage = 8,
  }) async {
    final Map<String, String> queryParams = {
      if (category != null) 'category': category,
      if (filter != null) ...{
        if (filter.brands.isNotEmpty) 'brands': filter.brands.join(','),
        if (filter.minPrice != null) 'minPrice': filter.minPrice.toString(),
        if (filter.maxPrice != null) 'maxPrice': filter.maxPrice.toString(),
        'sortBy': filter.sortBy,
      },
      'page': page.toString(),
      'perPage': perPage.toString(),
    };

    final uri = Uri.parse('$baseUrl/products').replace(queryParameters: queryParams);
    final resp = await http.get(uri, headers: _headers);

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      final list = data['data'] as List;
      return list.map((e) => ProductModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<ProductModel?> getProduct(String id) async {
    final resp = await http.get(Uri.parse('$baseUrl/products/$id'), headers: _headers);
    if (resp.statusCode == 200) {
      return ProductModel.fromJson(jsonDecode(resp.body));
    }
    return null;
  }

  Future<List<ProductModel>> getRelatedProducts(String id) async {
    final resp = await http.get(Uri.parse('$baseUrl/products/$id/related'), headers: _headers);
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      return data.map((e) => ProductModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<ProductModel>> getFrequentlyBoughtTogether(String id) async {
    final resp = await http.get(Uri.parse('$baseUrl/products/$id/together'), headers: _headers);
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      return data.map((e) => ProductModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<ReviewModel>> getReviews(String id) async {
    final resp = await http.get(Uri.parse('$baseUrl/products/$id/reviews'), headers: _headers);
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      return data.map((e) => ReviewModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<ProductModel>> getFeatured() async {
    final resp = await http.get(Uri.parse('$baseUrl/products/featured'), headers: _headers);
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      return data.map((e) => ProductModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<ProductModel>> getNewArrivals() async {
    final resp = await http.get(Uri.parse('$baseUrl/products/new-arrivals'), headers: _headers);
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      return data.map((e) => ProductModel.fromJson(e)).toList();
    }
    return [];
  }

  // ── Cart & Wishlist ───────────────────────────────────────────────────────

  Future<List<CartItem>> getCart() async {
    final resp = await http.get(Uri.parse('$baseUrl/cart'), headers: _headers);
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      return data.map((e) => CartItem.fromMap(e)).toList();
    }
    return [];
  }

  Future<void> addToCart(String productId, int qty, {String? color, String? storage}) async {
    await http.post(
      Uri.parse('$baseUrl/cart'),
      headers: _headers,
      body: jsonEncode({
        'product_id': productId,
        'qty': qty,
        'color': color,
        'storage': storage,
      }),
    );
  }

  Future<void> updateCartQty(String productId, int qty) async {
    await http.put(
      Uri.parse('$baseUrl/cart/$productId'),
      headers: _headers,
      body: jsonEncode({'qty': qty}),
    );
  }

  Future<void> removeFromCart(String productId) async {
    await http.delete(Uri.parse('$baseUrl/cart/$productId'), headers: _headers);
  }

  Future<List<String>> getWishlist() async {
    final resp = await http.get(Uri.parse('$baseUrl/wishlist'), headers: _headers);
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }

  Future<bool> toggleWishlist(String productId) async {
    final resp = await http.post(Uri.parse('$baseUrl/wishlist/$productId'), headers: _headers);
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body)['wishlisted'];
    }
    return false;
  }

  // ── Addresses & Orders ────────────────────────────────────────────────────

  Future<List<AddressModel>> getAddresses() async {
    final resp = await http.get(Uri.parse('$baseUrl/addresses'), headers: _headers);
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      return data.map((e) => AddressModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<String> createOrder({
    required List<CartItem> items,
    required String addressId,
    required String shippingMethod,
    required String paymentMethod,
    required double subtotal,
    required double tax,
    required double shipping,
    required double total,
    double walletDeduction = 0,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: _headers,
      body: jsonEncode({
        'address_id': addressId,
        'shipping_method': shippingMethod,
        'payment_method': paymentMethod,
        'subtotal': subtotal,
        'tax': tax,
        'shipping': shipping,
        'total': total,
        'wallet_deduction': walletDeduction,
        'items': items.map((e) => e.toMap()).toList(),
      }),
    );
    if (resp.statusCode == 201) {
      return jsonDecode(resp.body)['id'].toString();
    }
    throw Exception('Failed to create order');
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final resp = await http.get(Uri.parse('$baseUrl/orders'), headers: _headers);
    if (resp.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(resp.body));
    }
    return [];
  }

  // ── Payments ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> initializePayment({
    required String orderId,
    required double amount,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/payments/initialize'),
      headers: _headers,
      body: jsonEncode({
        'order_id': orderId,
        'amount': amount,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
      }),
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    }
    throw Exception('Failed to initialize payment');
  }

  Future<bool> verifyPayment(String txRef) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/payments/verify/$txRef'),
      headers: _headers,
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body)['status'] == 'success';
    }
    return false;
  }

  // ── Coupons ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> validateCoupon(String code, double total) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/coupons/validate'),
      headers: _headers,
      body: jsonEncode({'code': code, 'total': total}),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Invalid coupon');
  }

  // ── Referral & Wallet ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getReferralData() async {
    final resp = await http.get(Uri.parse('$baseUrl/referrals'), headers: _headers);
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Failed to fetch referral data');
  }

  Future<Map<String, dynamic>> getLoyaltyData() async {
    final resp = await http.get(Uri.parse('$baseUrl/loyalty'), headers: _headers);
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Failed to fetch loyalty data');
  }

  // ── Admin API ─────────────────────────────────────────────────────────────

  Future<void> adminAddProduct(Map<String, dynamic> data, List<String> imagePaths) async {
    final uri = Uri.parse('$baseUrl/admin/products');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Authorization': 'Bearer $_token',
      'Accept': 'application/json',
    });

    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    for (var path in imagePaths) {
      request.files.add(await http.MultipartFile.fromPath('images[]', path));
    }

    final resp = await request.send();
    if (resp.statusCode != 201) throw Exception('Failed to add product');
  }

  Future<void> adminUpdateProduct(String id, Map<String, dynamic> data, {List<String>? newImages}) async {
    final uri = Uri.parse('$baseUrl/admin/products/$id');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Authorization': 'Bearer $_token',
      'Accept': 'application/json',
    });
    request.fields['_method'] = 'PUT';

    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    if (newImages != null) {
      for (var path in newImages) {
        request.files.add(await http.MultipartFile.fromPath('new_images[]', path));
      }
    }

    final resp = await request.send();
    if (resp.statusCode != 200) throw Exception('Failed to update product');
  }

  Future<void> adminDeleteProduct(String id) async {
    final resp = await http.delete(Uri.parse('$baseUrl/admin/products/$id'), headers: _headers);
    if (resp.statusCode != 200) throw Exception('Failed to delete product');
  }

  Future<UserModel> adminUpdateProfile({String? name, String? email, String? password, String? avatarPath}) async {
    final uri = Uri.parse('$baseUrl/admin/profile');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Authorization': 'Bearer $_token',
      'Accept': 'application/json',
    });

    if (name != null) request.fields['name'] = name;
    if (email != null) request.fields['email'] = email;
    if (password != null) {
      request.fields['password'] = password;
      request.fields['password_confirmation'] = password;
    }

    if (avatarPath != null) {
      request.files.add(await http.MultipartFile.fromPath('avatar', avatarPath));
    }

    final resp = await request.send();
    if (resp.statusCode == 200) {
      final body = await resp.stream.bytesToString();
      return UserModel.fromJson(jsonDecode(body));
    }
    throw Exception('Failed to update profile');
  }

  Future<List<Map<String, dynamic>>> adminGetOrders() async {
    final resp = await http.get(Uri.parse('$baseUrl/admin/orders'), headers: _headers);
    if (resp.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(resp.body));
    }
    return [];
  }

  Future<Map<String, dynamic>?> adminGetOrder(String id) async {
    final resp = await http.get(Uri.parse('$baseUrl/admin/orders/$id'), headers: _headers);
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    }
    return null;
  }

  Future<void> adminUpdateOrderStatus(String id, String status) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/admin/orders/$id/status'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );
    if (resp.statusCode != 200) throw Exception('Failed to update order status');
  }

  Future<Map<String, dynamic>> adminGetAnalytics() async {
    final resp = await http.get(Uri.parse('$baseUrl/admin/analytics'), headers: _headers);
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    }
    throw Exception('Failed to fetch analytics');
  }

  Future<List<CouponModel>> adminGetCoupons() async {
    final resp = await http.get(Uri.parse('$baseUrl/admin/coupons'), headers: _headers);
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      return data.map((e) => CouponModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> adminAddCoupon(Map<String, dynamic> data) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/admin/coupons'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (resp.statusCode != 201) throw Exception('Failed to add coupon');
  }

  Future<void> adminDeleteCoupon(String id) async {
    final resp = await http.delete(Uri.parse('$baseUrl/admin/coupons/$id'), headers: _headers);
    if (resp.statusCode != 200) throw Exception('Failed to delete coupon');
  }

  Future<String> adminAiGenerateDescription(String name, String? brand) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/admin/ai/description'),
      headers: _headers,
      body: jsonEncode({'name': name, 'brand': brand}),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body)['description'];
    throw Exception('AI description failed');
  }

  Future<String> adminAiAnalyzeBusiness(String query) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/admin/ai/analyze'),
      headers: _headers,
      body: jsonEncode({'query': query}),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body)['reply'];
    throw Exception('AI analysis failed');
  }

  Future<Map<String, dynamic>> adminAiParseProductInfo({String? text, String? imagePath}) async {
    final uri = Uri.parse('$baseUrl/admin/ai/parse');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_headers);
    if (text != null) request.fields['text'] = text;
    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    final resp = await request.send();
    if (resp.statusCode == 200) {
      final body = await resp.stream.bytesToString();
      return jsonDecode(body);
    }
    throw Exception('AI parsing failed');
  }

  Future<String> aiChat(String message, {String? imagePath}) async {
    // If imagePath is provided, we use multipart for Gemini Vision
    if (imagePath != null) {
      final uri = Uri.parse('$baseUrl/ai/chat');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(_headers);
      request.fields['message'] = message;
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      final resp = await request.send();
      if (resp.statusCode == 200) {
        final body = await resp.stream.bytesToString();
        return jsonDecode(body)['reply'];
      }
    } else {
      final resp = await http.post(
        Uri.parse('$baseUrl/ai/chat'),
        headers: _headers,
        body: jsonEncode({'message': message}),
      );
      if (resp.statusCode == 200) return jsonDecode(resp.body)['reply'];
    }
    throw Exception('AI unreachable');
  }
}

extension CategoryModelJson on CategoryModel {
  static CategoryModel fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'].toString(),
    name: json['name'],
    icon: json['icon'] ?? '',
    productCount: json['product_count'] ?? 0,
  );
}

extension BannerModelJson on BannerModel {
  static BannerModel fromJson(Map<String, dynamic> json) => BannerModel(
    id: json['id'].toString(),
    title: json['title'],
    subtitle: json['subtitle'],
    imageUrl: json['image_url'],
    ctaLabel: json['cta_label'] ?? 'Shop Now',
    productId: json['product_id']?.toString(),
    category: json['category'],
  );
}

extension AddressModelJson on AddressModel {
  static AddressModel fromJson(Map<String, dynamic> json) => AddressModel(
    id: json['id'].toString(),
    label: json['label'],
    street: json['street'],
    city: json['city'],
    state: json['state'],
    zip: json['zip'],
    phone: json['phone'],
  );
}
