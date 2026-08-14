import 'services/providers.dart';
import 'services/notification_service.dart';
import 'router.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final apiSvc = ApiService();
  await apiSvc.init();
  runApp(CyberApp(apiSvc: apiSvc));
}

class CyberApp extends StatelessWidget {
  final ApiService apiSvc;
  const CyberApp({super.key, required this.apiSvc});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => apiSvc),
        ChangeNotifierProvider(create: (_) => AuthProvider(apiSvc)),
        ChangeNotifierProvider(create: (_) => CartProvider(apiSvc)),
        ChangeNotifierProvider(create: (_) => WishlistProvider(apiSvc)),
        ChangeNotifierProvider(create: (_) => CheckoutProvider()),
        ChangeNotifierProvider(create: (_) => AdminProductProvider(apiSvc)),
        ChangeNotifierProvider(create: (_) => AdminOrderProvider(apiSvc)),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..loadLocale()),
        ChangeNotifierProvider(create: (_) => ReferralProvider(apiSvc)),
        ChangeNotifierProvider(create: (_) => AdminCouponProvider(apiSvc)),
      ],
      child: Builder(builder: (ctx) {
        final themeProv = ctx.watch<ThemeProvider>();
        final localeProv = ctx.watch<LocaleProvider>();

        // Check auth state on start
        ctx.read<AuthProvider>().checkAuth();

        // Wire cart/wishlist when auth changes
        ctx.read<AuthProvider>().addListener(() {
          final isSignedIn = ctx.read<AuthProvider>().isSignedIn;
          if (isSignedIn) {
            ctx.read<CartProvider>().fetchCart();
            ctx.read<WishlistProvider>().fetchWishlist();
            NotificationService(apiSvc).init();
          } else {
            ctx.read<CartProvider>().stopListening();
            ctx.read<WishlistProvider>().stop();
          }
        });

        final router = buildRouter(ctx);
        return MaterialApp.router(
          title: 'cyber',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProv.useSystemTheme
              ? ThemeMode.system
              : (themeProv.themeName == 'light' ? ThemeMode.light : ThemeMode.dark),
          locale: localeProv.locale,
          routerConfig: router,
        );
      }),
    );
  }

  // Handle custom themes beyond just light/dark if not using system
  ThemeData _getThemeData(String name) {
    switch (name) {
      case 'dark': return AppTheme.darkTheme;
      case 'midnight': return AppTheme.midnightTheme;
      case 'forest': return AppTheme.forestTheme;
      case 'sunset': return AppTheme.sunsetTheme;
      default: return AppTheme.light;
    }
  }
}
