<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Banner extends Model
{
    use HasFactory;

    protected $fillable = ['title', 'subtitle', 'image_url', 'cta_label', 'product_id', 'category', 'order'];

    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
