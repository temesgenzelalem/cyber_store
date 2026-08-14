<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class LoyaltyController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        // Calculate points until next rank
        $nextRank = 'Gold';
        $pointsNeeded = 1000;

        if ($user->rank === 'Gold') {
            $nextRank = 'Elite';
            $pointsNeeded = 5000;
        } elseif ($user->rank === 'Elite') {
            $nextRank = 'Max';
            $pointsNeeded = 0;
        }

        return response()->json([
            'points' => $user->loyalty_points,
            'rank' => $user->rank,
            'next_rank' => $nextRank,
            'points_needed' => $pointsNeeded,
            'progress' => $pointsNeeded > 0 ? ($user->loyalty_points / $pointsNeeded) : 1
        ]);
    }

    public function history(Request $request)
    {
        // For now, return simulated points history based on orders
        return $request->user()->orders()
            ->where('status', 'paid')
            ->get()
            ->map(function($order) {
                return [
                    'amount' => floor($order->total / 10),
                    'reason' => 'Purchase Reward',
                    'date' => $order->created_at
                ];
            });
    }
}
