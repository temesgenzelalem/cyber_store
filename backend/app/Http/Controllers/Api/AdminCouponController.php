<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Coupon;
use Illuminate\Http\Request;

class AdminCouponController extends Controller
{
    public function index()
    {
        return Coupon::latest()->get();
    }

    public function store(Request $request)
    {
        $request->validate([
            'code' => 'required|string|unique:coupons,code',
            'type' => 'required|in:fixed,percent',
            'value' => 'required|numeric|min:0',
            'min_order_value' => 'nullable|numeric|min:0',
            'expires_at' => 'nullable|date',
            'usage_limit' => 'nullable|integer|min:1',
        ]);

        $coupon = Coupon::create($request->all());
        return response()->json($coupon, 201);
    }

    public function destroy(Coupon $coupon)
    {
        $coupon->delete();
        return response()->json(['message' => 'Coupon deleted']);
    }

    public function validateCoupon(Request $request)
    {
        $request->validate([
            'code' => 'required|string',
            'total' => 'required|numeric'
        ]);

        $coupon = Coupon::where('code', $request->code)->first();

        if (!$coupon || !$coupon->isValid($request->total)) {
            return response()->json(['message' => 'Invalid or expired coupon'], 422);
        }

        return response()->json([
            'valid' => true,
            'discount' => $coupon->calculateDiscount($request->total),
            'coupon_id' => $coupon->id
        ]);
    }
}
