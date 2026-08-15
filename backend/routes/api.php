<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\BannerController;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\WishlistController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\AddressController;
use App\Http\Controllers\Api\AiController;
use App\Http\Controllers\Api\LoyaltyController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\ReferralController;
use App\Http\Controllers\Api\AnalyticsController;
use App\Http\Controllers\Api\AdminOrderController;
use App\Http\Controllers\Api\AdminCouponController;
use App\Http\Controllers\Api\AdminProductController;
use App\Http\Controllers\Api\AdminProfileController;
use App\Http\Controllers\Api\VerificationController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

Route::get('/wipe', function () {
    try {
        \Illuminate\Support\Facades\Artisan::call('db:wipe --force');
        return response()->json([
            'status' => 'success',
            'output' => \Illuminate\Support\Facades\Artisan::output()
        ]);
    } catch (\Throwable $e) {
        return response()->json([
            'status' => 'error',
            'message' => $e->getMessage()
        ], 500);
    }
});

Route::get('/migrate', function () {
    try {
        \Illuminate\Support\Facades\Artisan::call('migrate --force');
        return response()->json([
            'status' => 'success',
            'output' => \Illuminate\Support\Facades\Artisan::output()
        ]);
    } catch (\Throwable $e) {
        return response()->json([
            'status' => 'error',
            'message' => $e->getMessage(),
            'trace' => $e->getTraceAsString()
        ], 500);
    }
});

Route::get('/tables', function () {
    try {
        $tables = \Illuminate\Support\Facades\DB::select("SELECT table_name FROM information_schema.tables WHERE table_schema \u003d \u0027public\u0027");
        return response()->json($tables);
    } catch (\Throwable $e) {
        return response()->json([\u0027error\u0027 \u003d\u003e $e-\u003egetMessage()], 500);
    }
});

Route::get('/diag', function () {
    try {
        \Illuminate\Support\Facades\Artisan::call('migrate:status');
        $migrateStatus = \Illuminate\Support\Facades\Artisan::output();

        return response()->json([
            'status' => 'ok',
            'database' => \Illuminate\Support\Facades\DB::connection()->getDatabaseName(),
            'migrate_status' => $migrateStatus,
            'env' => app()->environment(),
            'debug' => config('app.debug'),
        ]);
    } catch (\Throwable $e) {
        return response()->json([
            'status' => 'error',
            'message' => $e->getMessage(),
            'trace' => $e->getTraceAsString()
        ], 500);
    }
});

Route::get('/version', function () {
    return response()->json(['commit' \u003d\u003e '811c356']);
});

Route::get('/test', function () {
    return response()->json(['status' => 'ok', 'message' => 'Backend is working!']);
});

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::get('/banners', [BannerController::class, 'index']);
Route::get('/categories', [CategoryController::class, 'index']);

Route::get('/products', [ProductController::class, 'index']);
Route::get('/products/featured', [ProductController::class, 'featured']);
Route::get('/products/new-arrivals', [ProductController::class, 'newArrivals']);
Route::get('/products/{product}', [ProductController::class, 'show']);
Route::get('/products/{product}/related', [ProductController::class, 'related']);
Route::get('/products/{product}/together', [ProductController::class, 'frequentlyBoughtTogether']);
Route::get('/products/{product}/reviews', [ProductController::class, 'reviews']);

Route::post('/ai/chat', [AiController::class, 'chat']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
    Route::post('/user/fcm-token', function (Request $request) {
        $request->validate(['token' => 'required|string']);
        $request->user()->update(['fcm_token' => $request->token]);
        return response()->json(['message' => 'Token updated']);
    });

    Route::get('/cart', [CartController::class, 'index']);
    Route::post('/cart', [CartController::class, 'store']);
    Route::put('/cart/{product}', [CartController::class, 'update']);
    Route::delete('/cart/{product}', [CartController::class, 'destroy']);
    Route::post('/cart/clear', [CartController::class, 'clear']);

    Route::get('/wishlist', [WishlistController::class, 'index']);
    Route::post('/wishlist/{product}', [WishlistController::class, 'toggle']);

    Route::get('/addresses', [AddressController::class, 'index']);
    Route::post('/addresses', [AddressController::class, 'store']);
    Route::delete('/addresses/{address}', [AddressController::class, 'destroy']);

    Route::get('/orders', [OrderController::class, 'index']);
    Route::post('/orders', [OrderController::class, 'store']);

    Route::post('/products/{product}/reviews', [ProductController::class, 'addReview']);

    // Email Verification
    Route::post('/email/resend', [VerificationController::class, 'resend']);

    // Payments
    Route::post('/payments/initialize', [PaymentController::class, 'initialize']);
    Route::get('/payments/verify/{tx_ref}', [PaymentController::class, 'verify'])->name('payment.callback');

    // Coupons
    Route::post('/coupons/validate', [AdminCouponController::class, 'validateCoupon']);

    // Referral & Wallet
    Route::get('/referrals', [ReferralController::class, 'index']);
    Route::post('/wallet/use', [ReferralController::class, 'useWallet']);

    // Loyalty
    Route::get('/loyalty', [LoyaltyController::class, 'index']);
    Route::get('/loyalty/history', [LoyaltyController::class, 'history']);

    // Admin Routes
    Route::middleware('admin')->prefix('admin')->group(function () {
        Route::post('/products', [AdminProductController::class, 'store']);
        Route::put('/products/{product}', [AdminProductController::class, 'update']);
        Route::delete('/products/{product}', [AdminProductController::class, 'destroy']);
        Route::post('/profile', [AdminProfileController::class, 'update']);

        // Admin Order Management
        Route::get('/orders', [AdminOrderController::class, 'index']);
        Route::get('/orders/{order}', [AdminOrderController::class, 'show']);
        Route::put('/orders/{order}/status', [AdminOrderController::class, 'updateStatus']);
        // Admin Analytics
        Route::get('/analytics', [AnalyticsController::class, 'index']);

        // Admin Coupons
        Route::get('/coupons', [AdminCouponController::class, 'index']);
        Route::post('/coupons', [AdminCouponController::class, 'store']);
        Route::delete('/coupons/{coupon}', [AdminCouponController::class, 'destroy']);

        // Admin AI
        Route::post('/ai/description', [AiController::class, 'generateDescription']);
        Route::post('/ai/analyze', [AiController::class, 'analyzeBusiness']);
        Route::post('/ai/parse', [AiController::class, 'parseProductInfo']);
    });
});

Route::get('/email/verify/{id}/{hash}', [VerificationController::class, 'verify'])->name('verification.verify');
