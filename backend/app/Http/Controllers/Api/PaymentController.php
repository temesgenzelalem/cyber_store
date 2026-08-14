<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class PaymentController extends Controller
{
    /**
     * Initialize Chapa Payment
     */
    public function initialize(Request $request)
    {
        $request->validate([
            'order_id' => 'required|exists:orders,id',
            'amount' => 'required|numeric',
            'email' => 'required|email',
            'first_name' => 'required|string',
            'last_name' => 'required|string',
        ]);

        $order = Order::findOrFail($request->order_id);

        // Generate a unique transaction reference
        $tx_ref = 'TX-' . Str::random(10) . '-' . $order->id;

        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . env('CHAPA_SECRET_KEY'),
            'Content-Type' => 'application/json',
        ])->post('https://api.chapa.co/v1/transaction/initialize', [
            'amount' => $request->amount,
            'currency' => 'ETB',
            'email' => $request->email,
            'first_name' => $request->first_name,
            'last_name' => $request->last_name,
            'tx_ref' => $tx_ref,
            'callback_url' => route('payment.callback', ['tx_ref' => $tx_ref]),
            'return_url' => 'cyberstore://payment-success?tx_ref=' . $tx_ref,
            'customization' => [
                'title' => 'Cyber Store Order #' . $order->id,
                'description' => 'Payment for electronics gadgets'
            ]
        ]);

        if ($response->successful()) {
            return response()->json($response->json());
        }

        return response()->json([
            'message' => 'Failed to initialize payment',
            'details' => $response->json()
        ], 400);
    }

    /**
     * Verify Chapa Payment
     */
    public function verify(Request $request, $tx_ref)
    {
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . env('CHAPA_SECRET_KEY'),
        ])->get("https://api.chapa.co/v1/transaction/verify/$tx_ref");

        if ($response->successful()) {
            $data = $response->json();
            if ($data['status'] == 'success') {
                // Extract order ID from tx_ref (last part)
                $parts = explode('-', $tx_ref);
                $orderId = end($parts);

                $order = Order::find($orderId);
                if ($order && $order->status !== 'paid') {
                    $order->update(['status' => 'paid']);

                    // Award Loyalty Points (1 point per 10 ETB)
                    $points = floor($order->total / 10);
                    $user = $order->user;
                    $user->increment('loyalty_points', $points);

                    // Rank update logic
                    if ($user->loyalty_points >= 5000) $user->update(['rank' => 'Elite']);
                    elseif ($user->loyalty_points >= 1000) $user->update(['rank' => 'Gold']);
                }

                return response()->json([
                    'message' => 'Payment verified successfully',
                    'status' => 'success',
                    'data' => $data['data']
                ]);
            }
        }

        return response()->json([
            'message' => 'Payment verification failed',
            'status' => 'failed'
        ], 400);
    }

    /**
     * Webhook for Chapa (Production)
     */
    public function callback(Request $request, $tx_ref)
    {
        // Chapa sends data here. Verification logic is same as above.
        // In production, you would verify the hash signature provided by Chapa.
        return $this->verify($request, $tx_ref);
    }
}
