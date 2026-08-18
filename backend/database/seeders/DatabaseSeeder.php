<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Category;
use App\Models\Banner;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Admin User
        User::create([
            'name' => 'Admin User',
            'email' => 'admin@cyber.com',
            'password' => Hash::make('12345678'),
            'role' => 'admin',
            'email_verified_at' => now(),
        ]);

        $phones = Category::create(['name' => 'Phones', 'icon' => 'phone']);
        $watches = Category::create(['name' => 'Smart Watches', 'icon' => 'watch']);
        $cameras = Category::create(['name' => 'Cameras', 'icon' => 'camera']);

        DB::table('products')->insert([
            'name' => 'iPhone 14 Pro Max',
            'brand' => 'Apple',
            'category_id' => $phones->id,
            'price' => 1399.00,
            'original_price' => 1499.00,
            'images' => json_encode(['https://images.unsplash.com/photo-1663499482523-1c0c1bae4ce1']),
            'rating' => 4.9,
            'review_count' => 120,
            'sku' => 'IP14PM-128-BLK',
            'featured' => 'true', // Use string 'true' for Postgres
            'created_at' => now(),
            'updated_at' => now()
        ]);

        DB::table('products')->insert([
            'name' => 'Apple Watch Series 9',
            'brand' => 'Apple',
            'category_id' => $watches->id,
            'price' => 399.00,
            'images' => json_encode(['https://images.unsplash.com/photo-1544117518-2b462fca5631']),
            'rating' => 4.8,
            'review_count' => 85,
            'sku' => 'AWS9-45-SLV',
            'featured' => 'true', // Use string 'true' for Postgres
            'created_at' => now(),
            'updated_at' => now()
        ]);

        Banner::create([
            'title' => 'iPhone 14 Pro',
            'subtitle' => 'Pro.Beyond.',
            'image_url' => 'https://images.unsplash.com/photo-1663499482523-1c0c1bae4ce1',
            'cta_label' => 'Shop Now',
            'order' => 1
        ]);
    }
}
