cyber_store/
├── android/
│   ├── app/
│   │   ├── build.gradle                          ← Firebase google-services plugin
│   │   └── src/main/AndroidManifest.xml          ← Internet permission, activity config
│   └── build.gradle                              ← Project-level, google-services classpath
├── ios/
│   └── Runner/
│       └── Info.plist                            ← Camera permission, URL scheme for Firebase
├── assets/
│   ├── images/                                   ← Place local product images here
│   └── icons/                                    ← Place custom icons here
├── lib/
│   ├── main.dart                                 ← App entry, Firebase.initializeApp, providers
│   ├── router.dart                               ← GoRouter: all routes + auth redirect guard
│   ├── firebase_options.dart                     ← ⚠️ Replace with `flutterfire configure` output
│   ├── theme/
│   │   └── app_theme.dart                        ← Brand colors, text theme, button styles
│   ├── models/
│   │   └── models.dart                           ← ProductModel, CartItem, AddressModel, ReviewModel…
│   ├── services/
│   │   ├── firebase_service.dart                 ← ALL Firestore/Auth/Storage calls
│   │   └── providers.dart                        ← AuthProvider, CartProvider, WishlistProvider, CheckoutProvider
│   ├── middleware/
│   │   └── firebase_auth_middleware.dart         ← Reusable GoRouter auth guard builder
│   ├── widgets/
│   │   ├── main_scaffold.dart                    ← Bottom nav (Home/Products/Cart/Account)
│   │   └── widgets.dart                          ← ProductCard, CyberAppBar, SectionHeader, Footer, CheckoutStepper
│   └── screens/
│       ├── home/
│       │   └── home_screen.dart                  ← Hero carousel, categories, tabs, product grid, sale banner
│       ├── products/
│       │   ├── products_screen.dart              ← Product grid, filter bar, sort, pagination
│       │   ├── product_detail_screen.dart        ← Gallery, colour/storage picker, specs, reviews, related
│       │   └── filters_screen.dart               ← Price slider, brand, memory, protection, screen…
│       ├── cart/
│       │   └── cart_screen.dart                  ← Items, qty controls, promo code, order summary
│       ├── checkout/
│       │   ├── address_screen.dart               ← Step 1: saved addresses, radio, add new form
│       │   ├── shipping_screen.dart              ← Step 2: Free/Express/Scheduled + date picker
│       │   ├── payment_screen.dart               ← Step 3: animated card, card formatter, PayPal tabs
│       │   └── success_screen.dart               ← Animated order confirmation
│       ├── auth/
│       │   ├── login_screen.dart                 ← Email + password, forgot password link
│       │   └── register_screen.dart              ← Name, email, password, confirm
│       ├── profile/
│       │   └── profile_screen.dart               ← Avatar, orders, addresses, wishlist, settings, sign out
│       ├── wishlist/
│       │   └── wishlist_screen.dart              ← Saved products, add-to-cart, remove
│       └── orders/
│           └── orders_screen.dart                ← Order history list, status badges, reorder
├── firestore.rules                               ← Firestore security rules
├── storage.rules                                 ← Firebase Storage security rules
├── seed_firestore.js                             ← Node.js: seeds categories, banners, 13 products, reviews
├── analysis_options.yaml                         ← Flutter linter config
├── pubspec.yaml                                  ← All dependencies
└── README.md                                     ← Full setup guide
