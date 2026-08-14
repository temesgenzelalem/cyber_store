<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\Review;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $query = Product::query();

        if ($request->has('q')) {
            $search = $request->q;
            $query->where(function($q) use ($search) {
                $q->where('name', 'ilike', "%$search%")
                  ->orWhere('brand', 'ilike', "%$search%")
                  ->orWhere('description', 'ilike', "%$search%");
            });
        }

        if ($request->has('category')) {
            $query->whereHas('category', function($q) use ($request) {
                $q->where('name', $request->category);
            });
        }

        if ($request->has('brands')) {
            $query->whereIn('brand', explode(',', $request->brands));
        }

        if ($request->has('minPrice')) {
            $query->where('price', '>=', $request->minPrice);
        }

        if ($request->has('maxPrice')) {
            $query->where('price', '<=', $request->maxPrice);
        }

        if ($request->has('memories')) {
            $memories = explode(',', $request->memories);
            $query->where(function($q) use ($memories) {
                foreach ($memories as $memory) {
                    $q->orWhere('specs->memory', 'like', "%$memory%");
                }
            });
        }

        switch ($request->sortBy) {
            case 'price_asc':
                $query->orderBy('price', 'asc');
                break;
            case 'price_desc':
                $query->orderBy('price', 'desc');
                break;
            case 'newest':
                $query->orderBy('created_at', 'desc');
                break;
            default:
                $query->orderBy('rating', 'desc');
        }

        return $query->paginate($request->get('perPage', 8));
    }

    public function show(Product $product)
    {
        return $product->load(['category', 'variants']);
    }

    public function featured()
    {
        return Product::where('featured', true)->orderBy('rating', 'desc')->take(4)->get();
    }

    public function newArrivals()
    {
        return Product::orderBy('created_at', 'desc')->take(8)->get();
    }

    public function related(Product $product)
    {
        return Product::where('category_id', $product->category_id)
            ->where('id', '!=', $product->id)
            ->take(4)
            ->get();
    }

    public function frequentlyBoughtTogether(Product $product)
    {
        $orderIds = OrderItem::where('product_id', $product->id)
            ->pluck('order_id');

        $productIds = OrderItem::whereIn('order_id', $orderIds)
            ->where('product_id', '!=', $product->id)
            ->select('product_id', DB::raw('count(*) as total'))
            ->groupBy('product_id')
            ->orderBy('total', 'desc')
            ->take(4)
            ->pluck('product_id');

        return Product::whereIn('id', $productIds)->get();
    }

    public function reviews(Product $product)
    {
        return $product->reviews()->with('user')->orderBy('created_at', 'desc')->get();
    }

    public function addReview(Request $request, Product $product)
    {
        $request->validate([
            'rating' => 'required|numeric|min:1|max:5',
            'comment' => 'required|string',
        ]);

        $review = $product->reviews()->create([
            'user_id' => $request->user()->id,
            'rating' => $request->rating,
            'comment' => $request->comment,
        ]);

        // Update product rating
        $avgRating = $product->reviews()->avg('rating');
        $reviewCount = $product->reviews()->count();
        $product->update([
            'rating' => $avgRating,
            'review_count' => $reviewCount,
        ]);

        return response()->json($review, 201);
    }
}
