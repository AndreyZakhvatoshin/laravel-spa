<?php

namespace Tests\Feature;

use App\Events\MessageSent;
use App\Jobs\ProcessMessage;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\Broadcast;
use Illuminate\Support\Facades\Queue;
use Illuminate\Support\Facades\Redis;
use Tests\TestCase;

class WebSocketTest extends TestCase
{
    use DatabaseTransactions;

    public function test_message_sent_event_broadcasts()
    {
        Broadcast::shouldReceive('queue')
            ->once()
            ->withArgs(function (MessageSent $event) {
                return $event->username === 'TestUser' &&
                       $event->content === 'TestMessage' &&
                       $event->broadcastOn()[0]->name === 'chat' &&
                       $event->broadcastAs() === 'message.sent';
            });

        event(new MessageSent('TestUser', 'TestMessage'));

        $this->assertTrue(true);
    }

    public function test_message_stored_in_redis()
    {
        $username = 'TestUser';
        $content = 'TestMessage';

        Queue::fake();

        $response = $this->postJson('/api/chat/send', [
            'username' => $username,
            'content' => $content,
        ]);

        $response->assertStatus(200);

        // Выполняем задачу вручную
        $job = new ProcessMessage($username, $content);
        $job->handle();

        $messages = Redis::lrange('chat:messages', 0, -1);
        $lastMessage = json_decode(end($messages), true);

        $this->assertEquals($username, $lastMessage['username']);
        $this->assertEquals($content, $lastMessage['content']);
    }
}