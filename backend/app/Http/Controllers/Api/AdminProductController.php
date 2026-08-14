<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class AdminProductController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'brand' => 'required|string|max:255',
            'description' => 'nullable|string',
            'category_id' => 'required|exists:categories,id',
            'price' => 'required|numeric|min:0',
            'original_price' => 'nullable|numeric|min:0',
            'sku' => 'required|string|unique:products,sku',
            'featured' => 'boolean',
            'in_stock' => 'boolean',
            'images' => 'required|array',
            'images.*' => 'image|mimes:jpeg,png,jpg,webp|max:2048',
            'specs' => 'nullable|array',
            'colors' => 'nullable|array',
            'storage_options' => 'nullable|array',
        ]);

        $data = $request->all();
        $imageUrls = [];

        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $image) {
                $path = $image->store('products', 'public');
                $imageUrls[] = asset('storage/' . $path);
            }
        }
        $data['images'] = $imageUrls;

        $product = Product::create($data);

        if ($request->has('variants')) {
            $variants = is_array($request->variants) ? $request->variants : json_decode($request->variants, true);
            foreach ($variants as $variant) {
                $product->variants()->create($variant);
            }
        }

        return response()->json($product->load('variants'), 201);
    }

    public function update(Request $request, Product $product)
    {
        $request->validate([
            'name' => 'string|max:255',
            'brand' => 'string|max:255',
            'description' => 'nullable|string',
            'category_id' => 'exists:categories,id',
            'price' => 'numeric|min:0',
            'sku' => 'string|unique:products,sku,' . $product->id,
            'featured' => 'boolean',
            'in_stock' => 'boolean',
            'new_images' => 'nullable|array',
            'new_images.*' => 'image|mimes:jpeg,png,jpg,webp|max:2048',
            'remove_images' => 'nullable|array',
        ]);

        $data = $request->except(['new_images', 'remove_images']);
        $currentImages = $product->images;

        // Remove images
        if ($request->has('remove_images')) {
            $currentImages = array_filter($currentImages, function($url) use ($request) {
                return !in_array($url, $request->remove_images);
            });
            // Optional: delete files from storage
        }

        // Add new images
        if ($request->hasFile('new_images')) {
            foreach ($request->file('new_images') as $image) {
                $path = $image->store('products', 'public');
                $currentImages[] = asset('storage/' . $path);
            }
        }

        $data['images'] = array_values($currentImages);
        $product->update($data);

        if ($request->has('variants')) {
            $product->variants()->delete();
            $variants = is_array($request->variants) ? $request->variants : json_decode($request->variants, true);
            foreach ($variants as $variant) {
                $product->variants()->create($variant);
            }
        }

        return response()->json($product->load('variants'));
    }

    public function destroy(Product $product)
    {
        $product->delete();
        return response()->json(['message' => 'Product deleted']);
    }
}
