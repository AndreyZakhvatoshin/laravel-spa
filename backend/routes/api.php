<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/test', function (Request $request) {
    return response()->json([
        'message' => 'Hello from Laravel API!',
        'status' => 'success',
        'data' => ['example' => 'This is a test endpoint']
    ]);
});