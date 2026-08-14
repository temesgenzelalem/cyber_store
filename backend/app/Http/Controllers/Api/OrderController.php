<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Cart;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        return $request->user()->orders()->with('items')->latest()->get();
    }

    public function store(Request $request)
    {
        $request->validate([
            'address_id' => 'required|exists:addresses,id',
            'shipping_method' => 'required|string',
            'payment_method' => 'required|string',
            'subtotal' => 'required|numeric',
            'tax' => 'required|numeric',
            'shipping' => 'required|numeric',
            'items' => 'required|array',
            'coupon_id' => 'nullable|exists:coupons,id',
            'discount_amount' => 'nullable|numeric',
            'wallet_deduction' => 'nullable|numeric|min:0',
        ]);

        return DB::transaction(function () use ($request) {
            $user = $request->user();
            $walletDeduction = $request->get('wallet_deduction', 0);

            if ($walletDeduction > $user->wallet_balance) {
                return response()->json(['message' => 'Insufficient wallet balance'], 422);
            }

            $order = Order::create([
                'user_id' => $user->id,
                'address_id' => $request->address_id,
                'shipping_method' => $request->shipping_method,
                'payment_method' => $request->payment_method,
                'subtotal' => $request->subtotal,
                'tax' => $request->tax,
                'shipping' => $request->shipping,
                'total' => $request->total,
                'status' => 'pending',
                'coupon_id' => $request->coupon_id,
                'discount_amount' => $request->discount_amount ?? 0,
                'wallet_deduction' => $walletDeduction,
                'tracking_steps' => [[
                    'status' => 'pending',
                    'time' => now()->toIso8601String(),
                    'message' => 'Order placed successfully'
                ]]
            ]);

            // Deduct from wallet if used
            if ($walletDeduction > 0) {
                $user->decrement('wallet_balance', $walletDeduction);
            }

            // If coupon used, increment count
            if ($request->coupon_id) {
                \App\Models\Coupon::find($request->coupon_id)->increment('used_count');
            }

            foreach ($request->items as $item) {
                $order->items()->create($item);
            }

            // Clear cart
            $cart = Cart::where('user_id', $request->user()->id)->first();
            if ($cart) $cart->items()->delete();

            // Reward referrer on first order
            $user = $request->user();
            if ($user->referred_by && $user->orders()->count() === 1) {
                $referrer = User::find($user->referred_by);
                if ($referrer) {
                    $reward = 50; // 50 ETB reward
                    $referrer->increment('wallet_balance', $reward);
                    // Also reward the user
                    $user->increment('wallet_balance', 25);
                }
            }

            return response()->json($order, 201);
        });
    }

    public function show(Order $order)
    {
        return $order->load(['items', 'address']);
    }
}
