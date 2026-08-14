<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'address_id', 'shipping_method', 'payment_method',
        'subtotal', 'tax', 'shipping', 'total', 'status', 'delivery_date',
        'coupon_id', 'discount_amount', 'tracking_steps', 'wallet_deduction'
    ];

    protected $casts = [
        'subtotal' => 'float',
        'tax' => 'float',
        'shipping' => 'float',
        'total' => 'float',
        'discount_amount' => 'float',
        'wallet_deduction' => 'float',
        'tracking_steps' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function address()
    {
        return $this->belongsTo(Address::class);
    }
}
