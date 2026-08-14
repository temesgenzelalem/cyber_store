<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class AiController extends Controller
{
    public function chat(Request $request)
    {
        $request->validate(['message' => 'required|string']);

        $apiKey = env('GEMINI_API_KEY');
        $userMessage = $request->message;

        $products = Product::take(10)->get(['name', 'brand', 'price', 'description'])->toJson();
        $prompt = "You are 'Cyber Assistant', an expert AI shopping assistant for 'Cyber Store'.
        You are very friendly and helpful.
        IMPORTANT: If the user speaks in Amharic, you MUST respond in fluent Amharic using Ge'ez script.
        Context: $products. User Message: $userMessage";

        if ($request->hasFile('image')) {
            $imageData = base64_encode(file_get_contents($request->file('image')->path()));
            $payload = [
                "contents" => [[
                    "parts" => [
                        ["text" => $prompt],
                        ["inline_data" => [
                            "mime_type" => $request->file('image')->getMimeType(),
                            "data" => $imageData
                        ]]
                    ]
                ]]
            ];
        } else {
            $payload = [
                "contents" => [["parts" => [["text" => $prompt]]]]
            ];
        }

        $response = Http::withHeaders(['Content-Type' => 'application/json'])
            ->post("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey", $payload);

        if ($response->successful()) {
            $data = $response->json();
            $aiText = $data['candidates'][0]['content']['parts'][0]['text'] ?? "I'm sorry, I couldn't process that.";
            return response()->json(['reply' => $aiText]);
        }

        return response()->json(['error' => 'AI Service unavailable'], 500);
    }

    public function generateDescription(Request $request)
    {
        $request->validate(['name' => 'required|string', 'brand' => 'nullable|string']);

        $apiKey = env('GEMINI_API_KEY');
        $prompt = "Write a professional, high-converting product description for a '{$request->brand} {$request->name}'.
        Make it catchy and highlight potential tech features. Keep it around 100 words.";

        $response = Http::withHeaders(['Content-Type' => 'application/json'])
            ->post("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey", [
                "contents" => [["parts" => [["text" => $prompt]]]]
            ]);

        if ($response->successful()) {
            return response()->json(['description' => $response->json()['candidates'][0]['content']['parts'][0]['text'] ?? ""]);
        }
        return response()->json(['error' => 'Failed to generate description'], 500);
    }

    public function analyzeBusiness(Request $request)
    {
        $request->validate(['query' => 'required|string']);

        $apiKey = env('GEMINI_API_KEY');

        // Fetch analytics snapshot
        $totalSales = \App\Models\Order::where('status', 'paid')->sum('total');
        $topProducts = \App\Models\OrderItem::select('name', \DB::raw('sum(qty) as total_qty'))
            ->groupBy('name')->orderBy('total_qty', 'desc')->take(5)->get()->toJson();

        $prompt = "You are a business analyst AI for 'Cyber Store'.
        Total Sales: {$totalSales} ETB.
        Top Selling Products: {$topProducts}.
        The manager asks: '{$request->query}'.
        Give a concise, professional answer with business advice.";

        $response = Http::withHeaders(['Content-Type' => 'application/json'])
            ->post("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey", [
                "contents" => [["parts" => [["text" => $prompt]]]]
            ]);

        if ($response->successful()) {
            return response()->json(['reply' => $response->json()['candidates'][0]['content']['parts'][0]['text'] ?? ""]);
        }
        return response()->json(['error' => 'Failed to analyze'], 500);
    }

    public function parseProductInfo(Request $request)
    {
        $request->validate(['text' => 'nullable|string', 'image' => 'nullable|image']);

        $apiKey = env('GEMINI_API_KEY');
        $prompt = "Extract product information from the provided data.
        Return ONLY a JSON object with these keys: 'name', 'brand', 'price', 'category_id' (estimate or set 1), 'description', 'sku'.
        If some info is missing, use reasonable defaults or empty strings.
        Currency is ETB.
        Input text: {$request->text}";

        if ($request->hasFile('image')) {
            $imageData = base64_encode(file_get_contents($request->file('image')->path()));
            $payload = [
                "contents" => [[
                    "parts" => [
                        ["text" => $prompt],
                        ["inline_data" => [
                            "mime_type" => $request->file('image')->getMimeType(),
                            "data" => $imageData
                        ]]
                    ]
                ]]
            ];
        } else {
            $payload = [
                "contents" => [["parts" => [["text" => $prompt]]]]
            ];
        }

        $response = Http::withHeaders(['Content-Type' => 'application/json'])
            ->post("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey", $payload);

        if ($response->successful()) {
            $text = $response->json()['candidates'][0]['content']['parts'][0]['text'] ?? "{}";
            // Clean up Markdown if AI returned it
            $jsonStr = preg_replace('/```json|```/', '', $text);
            return response()->json(json_decode(trim($jsonStr), true));
        }
        return response()->json(['error' => 'Failed to parse'], 500);
    }
}
