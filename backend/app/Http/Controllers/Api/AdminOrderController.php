<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;

class AdminOrderController extends Controller
{
    public function index()
    {
        return Order::with(['user', 'items'])->latest()->get();
    }

    public function updateStatus(Request $request, Order $order)
    {
        $request->validate([
            'status' => 'required|in:pending,processing,shipped,delivered,cancelled',
        ]);

        $order->update(['status' => $request->status]);

        // Update tracking steps
        $steps = $order->tracking_steps ?? [];
        $steps[] = [
            'status' => $request->status,
            'time' => now()->toIso8601String(),
            'message' => $request->get('message', "Order is now " . $request->status)
        ];
        $order->update(['tracking_steps' => $steps]);

        // Send Push Notification (Simulated)
        if ($order->user->fcm_token) {
            \Log::info("Sending FCM to user {$order->user->id}: Order {$order->id} is now {$request->status}");
            // In a real app, you would use a library like kreait/laravel-firebase
            // or send a POST request to https://fcm.googleapis.com/v1/projects/{project-id}/messages:send
        }

        return response()->json($order);
    }

    public function show(Order $order)
    {
        return $order->load(['user', 'items', 'address']);
    }
}
