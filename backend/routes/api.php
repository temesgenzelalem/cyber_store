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

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

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
    Route::middleware('can:admin')->prefix('admin')->group(function () {
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
        Route::post('/ai/description', [\App\Http\Controllers\Api\AiController::class, 'generateDescription']);
        Route::post('/ai/analyze', [\App\Http\Controllers\Api\AiController::class, 'analyzeBusiness']);
        Route::post('/ai/parse', [\App\Http\Controllers\Api\AiController::class, 'parseProductInfo']);
    });
});

Route::get('/email/verify/{id}/{hash}', [VerificationController::class, 'verify'])->name('verification.verify');
