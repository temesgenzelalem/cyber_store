<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Wishlist;
use Illuminate\Http\Request;

class WishlistController extends Controller
{
    public function index(Request $request)
    {
        return $request->user()->wishlist()->pluck('product_id');
    }

    public function toggle(Request $request, $productId)
    {
        $user = $request->user();
        $wishlist = Wishlist::where('user_id', $user->id)->where('product_id', $productId)->first();

        if ($wishlist) {
            $wishlist->delete();
            return response()->json(['wishlisted' => false]);
        } else {
            Wishlist::create(['user_id' => $user->id, 'product_id' => $productId]);
            return response()->json(['wishlisted' => true]);
        }
    }
}
