<?php

namespace App\Http\Controllers;

use App\Events\MessageSent;
use App\Jobs\ProcessMessage;
use App\Models\Message;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Redis;

class ChatController extends Controller
{
    public function sendMessage(Request $request)
    {
        $request->validate([
            'username' => 'required|string|max:255',
            'content' => 'required|string|max:1000',
        ]);

        
        ProcessMessage::dispatch($request->username, $request->content);
    }

    public function getMessages()
    {
        $messages = Redis::lrange('chat:messages', 0, -1);
        $decoded = array_map('json_decode', $messages);
        return response()->json($decoded);
    }
}