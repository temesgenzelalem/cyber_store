<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'name', 'brand', 'description', 'category_id', 'price', 'original_price',
        'images', 'rating', 'review_count', 'sku', 'featured',
        'in_stock', 'specs', 'colors', 'storage_options', 'ar_model_url'
    ];

    protected $casts = [
        'images' => 'array',
        'specs' => 'array',
        'colors' => 'array',
        'storage_options' => 'array',
        'featured' => 'boolean',
        'in_stock' => 'boolean',
        'price' => 'float',
        'original_price' => 'float',
        'rating' => 'float',
    ];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    public function variants()
    {
        return $this->hasMany(ProductVariant::class);
    }
}
