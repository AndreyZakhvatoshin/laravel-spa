<?php

namespace App\Jobs;

use App\Models\Message;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Redis;

class ProcessMessage implements ShouldQueue
{
    use Dispatchable, Queueable;

    protected $username;
    protected $content;

    public function __construct($username, $content)
    {
        $this->username = $username;
        $this->content = $content;
    }

    public function handle()
    {
        Log::info('ProcessMessage Job started for user: ' . $this->username);
        // Сохраняем в MySQL
        $message = Message::create([
            'username' => $this->username,
            'content' => $this->content,
        ]);

        // Кэшируем в Redis
        Redis::rpush('chat:messages', json_encode([
            'id' => $message->id,
            'username' => $this->username,
            'content' => $this->content,
            'created_at' => $message->created_at,
        ]));

        // Ограничиваем кэш до 100 сообщений
        Redis::ltrim('chat:messages', -100, -1);

        // Транслируем событие через WebSocket
        event(new \App\Events\MessageSent($this->username, $this->content));
    }
}