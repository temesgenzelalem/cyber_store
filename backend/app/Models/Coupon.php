<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Coupon extends Model
{
    use HasFactory;

    protected $fillable = [
        'code', 'type', 'value', 'min_order_value', 'expires_at', 'usage_limit', 'used_count', 'is_active'
    ];

    protected $casts = [
        'expires_at' => 'datetime',
        'is_active' => 'boolean',
        'value' => 'float',
        'min_order_value' => 'float',
    ];

    public function isValid($total): bool
    {
        if (!$this->is_active) return false;
        if ($this->expires_at && $this->expires_at->isPast()) return false;
        if ($this->usage_limit && $this->used_count >= $this->usage_limit) return false;
        if ($total < $this->min_order_value) return false;
        return true;
    }

    public function calculateDiscount($total): float
    {
        if ($this->type === 'percent') {
            return ($total * $this->value) / 100;
        }
        return min($this->value, $total);
    }
}
