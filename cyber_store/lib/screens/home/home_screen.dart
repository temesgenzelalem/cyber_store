import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_strings.dart';
import '../../widgets/widgets.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bannerIndex = 0;
  final _tabs = ['New Arrival', 'Bestseller', 'Featured Products'];
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final svc = context.read<ApiService>();

    return Scaffold(
      appBar: const CyberAppBar(),
      endDrawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Banners ─────────────────────────────────────────────
            FutureBuilder<List<BannerModel>>(
              future: svc.getBanners(),
              builder: (ctx, snap) {
                final banners = snap.data ?? [];
                if (banners.isEmpty) return _heroBannerPlaceholder();
                return _buildBannerCarousel(banners);
              },
            ),

            const SizedBox(height: 24),

            // ── Browse by Category ───────────────────────────────────────
            SectionHeader(title: AppStrings.tr(context, 'Categories')),
            const SizedBox(height: 12),
            FutureBuilder<List<CategoryModel>>(
              future: svc.getCategories(),
              builder: (ctx, snap) {
                final cats = snap.data ?? _demoCategories;
                return SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: cats.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => CategoryTile(category: cats[i]),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // ── Product Tabs ─────────────────────────────────────────────
            _buildTabBar(),
            const SizedBox(height: 12),

            if (_selectedTab == 0)
              FutureBuilder<List<ProductModel>>(
                future: svc.getNewArrivals(),
                builder: (ctx, snap) => _buildProductGrid(snap.data ?? []),
              )
            else if (_selectedTab == 2)
              FutureBuilder<List<ProductModel>>(
                future: svc.getFeatured(),
                builder: (ctx, snap) => _buildProductGrid(snap.data ?? []),
              )
            else
              _buildProductGrid([]),

            const SizedBox(height: 8),
            Center(
              child: OutlinedButton(
                onPressed: () => context.go('/products'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(200, 44)),
                child: const Text('View More'),
              ),
            ),

            const SizedBox(height: 32),

            // ── Discounts ────────────────────────────────────────────────
            _buildDiscountBanner(),

            const SizedBox(height: 24),

            // ── Big Summer Sale ──────────────────────────────────────────
            _buildSummerSale(),

            const SizedBox(height: 32),

            // ── Footer ───────────────────────────────────────────────────
            const CyberFooter(),
          ],
        ),
      ),
    );
  }

  // ── Banner Carousel ───────────────────────────────────────────────────────

  Widget _buildBannerCarousel(List<BannerModel> banners) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: banners.length,
          itemBuilder: (ctx, i, _) => _BannerSlide(banner: banners[i]),
          options: CarouselOptions(
            height: 320,
            viewportFraction: 1,
            enlargeCenterPage: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            onPageChanged: (i, _) => setState(() => _bannerIndex = i),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSmoothIndicator(
          activeIndex: _bannerIndex,
          count: banners.length,
          effect: const WormEffect(
            dotHeight: 6, dotWidth: 6,
            activeDotColor: AppTheme.black,
            dotColor: AppTheme.grey300,
          ),
        ),
      ],
    );
  }

  Widget _heroBannerPlaceholder() => Shimmer.fromColors(
    baseColor: AppTheme.dark,
    highlightColor: AppTheme.grey800,
    child: Container(
      height: 300,
      color: AppTheme.dark,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 80, height: 14, color: Colors.white),
          const SizedBox(height: 8),
          Container(width: 120, height: 13, color: Colors.white),
          const SizedBox(height: 8),
          Container(width: 200, height: 40, color: Colors.white),
          const SizedBox(height: 12),
          Container(width: double.infinity, height: 13, color: Colors.white),
          const SizedBox(height: 16),
          Container(width: 120, height: 38, color: Colors.white),
        ],
      ),
    ),
  );

  // ── Tab Bar ───────────────────────────────────────────────────────────────

  Widget _buildTabBar() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: List.generate(_tabs.length, (i) => GestureDetector(
        onTap: () => setState(() => _selectedTab = i),
        child: Container(
          margin: const EdgeInsets.only(right: 20),
          padding: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 2,
                color: _selectedTab == i ? AppTheme.black : Colors.transparent,
              ),
            ),
          ),
          child: Text(
            _tabs[i],
            style: TextStyle(
              fontSize: 14,
              fontWeight: _selectedTab == i ? FontWeight.w700 : FontWeight.w400,
              color: _selectedTab == i ? AppTheme.black : AppTheme.grey600,
            ),
          ),
        ),
      )),
    ),
  );

  // ── Product Grid ──────────────────────────────────────────────────────────

  Widget _buildProductGrid(List<ProductModel> products) {
    if (products.isEmpty) {
      return SizedBox(
        height: 200,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 0.68,
            crossAxisSpacing: 12, mainAxisSpacing: 12,
          ),
          itemCount: 4,
          itemBuilder: (_, __) => _ProductCardShimmer(),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.68,
        crossAxisSpacing: 12, mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => ProductCard(product: products[i]),
    );
  }

  // ── Discounts Section ─────────────────────────────────────────────────────

  Widget _buildDiscountBanner() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Discounts up to -50%',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      ),
      const SizedBox(height: 12),
      FutureBuilder<List<ProductModel>>(
        future: context.read<ApiService>().getFeatured(),
        builder: (ctx, snap) {
          final products = snap.data ?? [];
          return SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: products.isEmpty ? 4 : products.length,
              itemBuilder: (_, i) => products.isEmpty
                  ? _ProductCardShimmer()
                  : SizedBox(width: 160, child: ProductCard(product: products[i])),
            ),
          );
        },
      ),
    ],
  );

  // ── Summer Sale Banner ────────────────────────────────────────────────────

  Widget _buildSummerSale() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppTheme.dark,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Big Summer', style: TextStyle(
          color: AppTheme.white, fontSize: 28, fontWeight: FontWeight.w800)),
        const Text('Sale', style: TextStyle(
          color: AppTheme.white, fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => context.go('/products'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.white,
            foregroundColor: AppTheme.black,
            minimumSize: const Size(140, 44),
          ),
          child: const Text('Shop Now'),
        ),
      ],
    ),
  );

  // ── End Drawer ────────────────────────────────────────────────────────────

  Widget _buildDrawer(BuildContext context) => Drawer(
    child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('cyber', style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic)),
          ),
          const Divider(),
          _drawerItem(context, Icons.home_outlined, 'Home', '/'),
          _drawerItem(context, Icons.grid_view_outlined, 'Products', '/products'),
          _drawerItem(context, Icons.shopping_cart_outlined, 'Cart', '/cart'),
          const Divider(),
          _drawerItem(context, Icons.person_outline, 'Login', '/login'),
          _drawerItem(context, Icons.person_add_outlined, 'Register', '/register'),
        ],
      ),
    ),
  );

  ListTile _drawerItem(BuildContext ctx, IconData icon, String label, String path) =>
      ListTile(
        leading: Icon(icon),
        title: Text(label),
        onTap: () { Navigator.pop(ctx); ctx.go(path); },
      );

  // ── Demo data fallback ────────────────────────────────────────────────────

  static final List<CategoryModel> _demoCategories = [
    CategoryModel(id: '1', name: 'Phones',         icon: '', productCount: 0),
    CategoryModel(id: '2', name: 'Smart Watches',  icon: '', productCount: 0),
    CategoryModel(id: '3', name: 'Cameras',        icon: '', productCount: 0),
    CategoryModel(id: '4', name: 'Headphones',     icon: '', productCount: 0),
    CategoryModel(id: '5', name: 'Computers',      icon: '', productCount: 0),
    CategoryModel(id: '6', name: 'Gaming',         icon: '', productCount: 0),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────

class _BannerSlide extends StatelessWidget {
  final BannerModel banner;
  const _BannerSlide({required this.banner});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      if (banner.productId != null) context.push('/products/${banner.productId}');
      else if (banner.category != null) context.go('/products?category=${banner.category}');
    },
    child: Container(
      color: AppTheme.dark,
      child: Stack(
        children: [
          if (banner.imageUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: banner.imageUrl,
              width: double.infinity, height: double.infinity,
              fit: BoxFit.cover,
            ),
          Positioned(
            left: 24, bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CYBER', style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 3
                )),
                const SizedBox(height: 4),
                Text(banner.subtitle, style: const TextStyle(
                  color: AppTheme.grey400, fontSize: 12)),
                Text(banner.title, style: const TextStyle(
                  color: AppTheme.white, fontSize: 32,
                  fontWeight: FontWeight.w800, height: 1.1)),
                const SizedBox(height: 12),
                const _ShopNowButton(),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ShopNowButton extends StatelessWidget {
  const _ShopNowButton();
  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: () => context.go('/products'),
    style: OutlinedButton.styleFrom(
      foregroundColor: AppTheme.white,
      side: const BorderSide(color: AppTheme.white),
      minimumSize: const Size(120, 38),
    ),
    child: const Text('Shop Now'),
  );
}

class _ProductCardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppTheme.grey100,
    highlightColor: AppTheme.white,
    child: Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

// Add missing constant
extension on AppTheme {
  static const Color grey300 = Color(0xFFE0E0E0);
}
