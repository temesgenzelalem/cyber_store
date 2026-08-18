<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Banner;
use Illuminate\Http\Request;

class BannerController extends Controller
{
    public function index()
    {
        // Avoid 'order' keyword issues in Postgres
        return Banner::orderBy('id')->get();
    }
}
