<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AnalyticsController extends Controller
{
    public function index()
    {
        $totalSales = Order::where('status', '!=', 'cancelled')->sum('total');
        $totalOrders = Order::count();
        $totalUsers = User::where('role', 'customer')->count();

        $recentSales = Order::where('status', '!=', 'cancelled')
            ->where('created_at', '>=', now()->subDays(30))
            ->select(DB::raw('DATE(created_at) as date'), DB::raw('SUM(total) as total'))
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        $topProducts = OrderItem::select('product_id', 'name', DB::raw('SUM(qty) as total_qty'), DB::raw('SUM(qty * price) as revenue'))
            ->groupBy('product_id', 'name')
            ->orderBy('total_qty', 'desc')
            ->take(5)
            ->get();

        return response()->json([
            'stats' => [
                'total_sales' => (float)$totalSales,
                'total_orders' => $totalOrders,
                'total_users' => $totalUsers,
            ],
            'recent_sales' => $recentSales,
            'top_products' => $topProducts,
        ]);
    }
}
