<?php

namespace App\Listeners;

use App\Events\Board\BoardCreated;
use App\Notifications\Board\NewBoardNotification;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Support\Facades\Log;

class SendBoardCreationNotification
{
    /**
     * Create the event listener.
     */
    public function __construct()
    {
        //
    }

    /**
     * Handle the event.
     */
    public function handle(BoardCreated $event): void
    {
        // Получаем владельца из события
        $owner = $event->board->owner;

        // Отправляем ему уведомление
        $owner->notify(new NewBoardNotification($event->board));
        Log::info('Board Created: ' . $owner->name);
    }
}
