import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Auth Provider
// ─────────────────────────────────────────────────────────────────────────────

class AuthProvider extends ChangeNotifier {
  final ApiService _svc;
  UserModel? _user;
  bool  _loading = false;
  String? _error;

  AuthProvider(this._svc);

  UserModel?    get user     => _user;
  bool     get loading  => _loading;
  String?  get error    => _error;
  bool     get isSignedIn => _user != null;

  Future<void> checkAuth() async {
    _user = await _svc.getCurrentUser();
    notifyListeners();
  }

  Future<bool> signUp(String email, String password, String name) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final res = await _svc.register(name, email, password);
      if (res != null) {
        _user = UserModel.fromJson(res['user']);
        _loading = false; notifyListeners(); return true;
      }
      _error = "Registration failed"; _loading = false; notifyListeners(); return false;
    } catch (e) {
      _error = e.toString(); _loading = false; notifyListeners(); return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final res = await _svc.login(email, password);
      if (res != null) {
        _user = UserModel.fromJson(res['user']);
        _loading = false; notifyListeners(); return true;
      }
      _error = "Login failed"; _loading = false; notifyListeners(); return false;
    } catch (e) {
      _error = e.toString(); _loading = false; notifyListeners(); return false;
    }
  }

  Future<void> resendVerification() async {
    await _svc.resendVerificationEmail();
  }

  Future<void> signOut() async {
    await _svc.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile(UserModel newUser) async {
    _user = newUser;
    notifyListeners();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Cart Provider
// ─────────────────────────────────────────────────────────────────────────────

class CartProvider extends ChangeNotifier {
  final ApiService _svc;
  List<CartItem> _items = [];
  bool _loading = false;
  String? _promoCode;
  double  _promoDiscount = 0;

  CartProvider(this._svc);

  List<CartItem> get items          => _items;
  bool           get loading        => _loading;
  int            get itemCount      => _items.fold(0, (s, i) => s + i.qty);
  String?        get promoCode      => _promoCode;
  double         get promoDiscount  => _promoDiscount;

  double get subtotal  => _items.fold(0, (s, i) => s + i.subtotal);
  double get tax       => subtotal * 0.02;
  double get shipping  => subtotal > 500 ? 0 : 29;
  double get total     => subtotal + tax + shipping - _promoDiscount;

  Future<void> fetchCart() async {
    _loading = true; notifyListeners();
    _items = await _svc.getCart();
    _loading = false; notifyListeners();
  }

  void stopListening() {
    _items = [];
    notifyListeners();
  }

  Future<void> add({
    required ProductModel product,
    int qty = 1,
    String? color,
    String? storage,
  }) async {
    await _svc.addToCart(product.id, qty, color: color, storage: storage);
    await fetchCart();
  }

  Future<void> updateQty(String productId, int qty) async {
    await _svc.updateCartQty(productId, qty);
    await fetchCart();
  }

  Future<void> remove(String productId) async {
    await _svc.removeFromCart(productId);
    await fetchCart();
  }

  void setPromo(String? code, double discount) {
    _promoCode = code;
    _promoDiscount = discount;
    notifyListeners();
  }

  bool applyPromo(String code) {
    const promos = {'CYBER10': 10.0, 'SAVE50': 50.0, 'SUMMER20': 20.0};
    final discount = promos[code.toUpperCase()];
    if (discount != null) {
      _promoCode     = code;
      _promoDiscount = discount;
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Wishlist Provider
// ─────────────────────────────────────────────────────────────────────────────

class WishlistProvider extends ChangeNotifier {
  final ApiService _svc;
  List<String> _productIds = [];

  WishlistProvider(this._svc);

  bool isWishlisted(String id) => _productIds.contains(id);

  Future<void> fetchWishlist() async {
    _productIds = await _svc.getWishlist();
    notifyListeners();
  }

  void stop() {
    _productIds = [];
    notifyListeners();
  }

  Future<void> toggle(String productId) async {
    await _svc.toggleWishlist(productId);
    await fetchWishlist();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Checkout Provider
// ─────────────────────────────────────────────────────────────────────────────

class CheckoutProvider extends ChangeNotifier {
  String?  selectedAddressId;
  String   shippingMethod    = 'free';
  DateTime? scheduledDate;
  String   paymentMethod     = 'credit_card';

  double shippingCost(double subtotal) {
    if (shippingMethod == 'express') return 8.5;
    return 0;
  }

  void selectAddress(String id)   { selectedAddressId = id; notifyListeners(); }
  void selectShipping(String m)   { shippingMethod    = m;  notifyListeners(); }
  void selectPayment(String m)    { paymentMethod     = m;  notifyListeners(); }
  void selectDate(DateTime d)     { scheduledDate     = d;  notifyListeners(); }

  void reset() {
    selectedAddressId = null;
    shippingMethod    = 'free';
    scheduledDate     = null;
    paymentMethod     = 'credit_card';
    notifyListeners();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Admin Product Provider
// ─────────────────────────────────────────────────────────────────────────────

class AdminProductProvider extends ChangeNotifier {
  final ApiService _svc;
  bool _loading = false;

  AdminProductProvider(this._svc);

  bool get loading => _loading;

  Future<void> addProduct(Map<String, dynamic> data, List<String> images) async {
    _loading = true; notifyListeners();
    try {
      await _svc.adminAddProduct(data, images);
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data, {List<String>? newImages}) async {
    _loading = true; notifyListeners();
    try {
      await _svc.adminUpdateProduct(id, data, newImages: newImages);
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    _loading = true; notifyListeners();
    try {
      await _svc.adminDeleteProduct(id);
    } finally {
      _loading = false; notifyListeners();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Theme & Locale Providers
// ─────────────────────────────────────────────────────────────────────────────

class ThemeProvider extends ChangeNotifier {
  String _themeName = 'light';
  bool _useSystemTheme = true;

  String get themeName => _themeName;
  bool get useSystemTheme => _useSystemTheme;

  void setTheme(String name) async {
    _themeName = name;
    _useSystemTheme = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_name', name);
    await prefs.setBool('use_system_theme', false);
    notifyListeners();
  }

  void setUseSystemTheme(bool val) async {
    _useSystemTheme = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_system_theme', val);
    notifyListeners();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _themeName = prefs.getString('theme_name') ?? 'light';
    _useSystemTheme = prefs.getBool('use_system_theme') ?? true;
    notifyListeners();
  }
}

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale l) async {
    _locale = l;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang_code', l.languageCode);
    notifyListeners();
  }

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('lang_code') ?? 'en';
    _locale = Locale(code);
    notifyListeners();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Admin Order Provider
// ─────────────────────────────────────────────────────────────────────────────

class AdminOrderProvider extends ChangeNotifier {
  final ApiService _svc;
  List<Map<String, dynamic>> _orders = [];
  bool _loading = false;

  AdminOrderProvider(this._svc);

  List<Map<String, dynamic>> get orders => _orders;
  bool get loading => _loading;

  Future<void> fetchOrders() async {
    _loading = true; notifyListeners();
    _orders = await _svc.adminGetOrders();
    _loading = false; notifyListeners();
  }

  Future<void> updateStatus(String id, String status) async {
    await _svc.adminUpdateOrderStatus(id, status);
    await fetchOrders();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Referral & Coupon Providers
// ─────────────────────────────────────────────────────────────────────────────

class ReferralProvider extends ChangeNotifier {
  final ApiService _svc;
  String? _code;
  double  _balance = 0;
  int     _count   = 0;
  List<Map<String, dynamic>> _referrals = [];
  bool    _loading = false;

  ReferralProvider(this._svc);

  String? get code      => _code;
  double  get balance   => _balance;
  int     get count     => _count;
  List<Map<String, dynamic>> get referrals => _referrals;
  bool    get loading   => _loading;

  Future<void> fetchData() async {
    _loading = true; notifyListeners();
    try {
      final res = await _svc.getReferralData();
      _code      = res['referral_code'];
      _balance   = (res['wallet_balance'] as num).toDouble();
      _count     = res['referral_count'];
      _referrals = List<Map<String, dynamic>>.from(res['referrals'] ?? []);
    } finally {
      _loading = false; notifyListeners();
    }
  }
}

class AdminCouponProvider extends ChangeNotifier {
  final ApiService _svc;
  List<CouponModel> _coupons = [];
  bool _loading = false;

  AdminCouponProvider(this._svc);

  List<CouponModel> get coupons => _coupons;
  bool get loading => _loading;

  Future<void> fetchCoupons() async {
    _loading = true; notifyListeners();
    _coupons = await _svc.adminGetCoupons();
    _loading = false; notifyListeners();
  }

  Future<void> addCoupon(Map<String, dynamic> data) async {
    await _svc.adminAddCoupon(data);
    await fetchCoupons();
  }

  Future<void> deleteCoupon(String id) async {
    await _svc.adminDeleteCoupon(id);
    await fetchCoupons();
  }
}
