<?php

use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\BoardController;
use App\Http\Controllers\ChatController;
use App\Http\Controllers\User\UserController;
use App\Http\Middleware\CheckPermission;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/test', function (Request $request) {
    return response()->json([
        'message' => 'Hello from Laravel API!',
        'status' => 'success',
        'data' => ['example' => 'This is a test endpoint']
    ]);
});

Route::post('/chat/send', [ChatController::class, 'sendMessage']);
Route::get('/chat/messages', [ChatController::class, 'getMessages']);

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    // User management (only for admins)
    Route::apiResource('users', UserController::class)->except(['store', 'create']);

    // Role management
    Route::get('/roles', function () {
        return response()->json(\App\Models\Role::all());
    })->middleware('check.permission:manage-roles');

    Route::apiResource('boards', BoardController::class);

    // Для добавления/удаления членов доски
    Route::post('boards/{board}/members', [BoardController::class, 'addMember'])->name('boards.members.add');
    Route::delete('boards/{board}/members/{user}', [BoardController::class, 'removeMember'])->name('boards.members.remove');
});
