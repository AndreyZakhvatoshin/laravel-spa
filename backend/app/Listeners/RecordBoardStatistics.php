<?php

namespace App\Listeners;

use App\Events\Board\BoardCreated;
use App\Jobs\AggregateBoardStatistics;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;

class RecordBoardStatistics
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
        // Отправляем задачу в очередь, указывая конкретное подключение и название очереди
        AggregateBoardStatistics::dispatch($event->board)
            ->onConnection('rabbitmq') // <-- Указываем, что использовать RabbitMQ
            ->onQueue('statistics');      // <-- Указываем, в какую очередь положить задачу
    }
}
