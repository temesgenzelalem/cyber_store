<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Product;
use Illuminate\Http\Request;

class CartController extends Controller
{
    public function index(Request $request)
    {
        $cart = Cart::firstOrCreate(['user_id' => $request->user()->id]);
        return $cart->items()->with('product')->get()->map(function($item) {
            return [
                'product_id' => $item->product_id,
                'name' => $item->product->name,
                'price' => $item->product->price,
                'image' => $item->product->images[0] ?? '',
                'qty' => $item->qty,
                'sku' => $item->product->sku,
                'color' => $item->color,
                'storage' => $item->storage,
            ];
        });
    }

    public function store(Request $request)
    {
        $request->validate([
            'product_id' => 'required|exists:products,id',
            'qty' => 'required|integer|min:1',
        ]);

        $cart = Cart::firstOrCreate(['user_id' => $request->user()->id]);

        $item = $cart->items()->where('product_id', $request->product_id)
            ->where('color', $request->color)
            ->where('storage', $request->storage)
            ->first();

        if ($item) {
            $item->increment('qty', $request->qty);
        } else {
            $cart->items()->create($request->all());
        }

        return response()->json(['message' => 'Added to cart']);
    }

    public function update(Request $request, $productId)
    {
        $cart = Cart::where('user_id', $request->user()->id)->firstOrFail();
        $item = $cart->items()->where('product_id', $productId)->firstOrFail();

        if ($request->qty <= 0) {
            $item->delete();
        } else {
            $item->update(['qty' => $request->qty]);
        }

        return response()->json(['message' => 'Cart updated']);
    }

    public function destroy(Request $request, $productId)
    {
        $cart = Cart::where('user_id', $request->user()->id)->firstOrFail();
        $cart->items()->where('product_id', $productId)->delete();
        return response()->json(['message' => 'Removed from cart']);
    }

    public function clear(Request $request)
    {
        $cart = Cart::where('user_id', $request->user()->id)->first();
        if ($cart) $cart->items()->delete();
        return response()->json(['message' => 'Cart cleared']);
    }
}
