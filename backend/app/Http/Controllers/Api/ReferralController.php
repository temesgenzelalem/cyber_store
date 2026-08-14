<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class ReferralController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        return response()->json([
            'referral_code' => $user->referral_code,
            'wallet_balance' => $user->wallet_balance,
            'referral_count' => \App\Models\User::where('referred_by', $user->id)->count()
        ]);
    }

    public function useWallet(Request $request)
    {
        $request->validate(['amount' => 'required|numeric|min:1']);
        $user = $request->user();

        if ($user->wallet_balance < $request->amount) {
            return response()->json(['message' => 'Insufficient balance'], 422);
        }

        // Logic to apply wallet balance to checkout (handled in Flutter side via request)
        return response()->json(['message' => 'Balance verified']);
    }
}
