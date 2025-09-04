<?php

namespace App\Jobs;

use App\Models\Board;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class AggregateBoardStatistics implements ShouldQueue
{
    use InteractsWithQueue, Queueable, SerializesModels;

    /**
     * Create a new job instance.
     */
    public function __construct(public Board $board)
    {
    }

    public function handle(): void
    {
        // Здесь будет логика сбора статистики
        Log::info("Статистика для доски #{$this->board->id} ('{$this->board->title}') отправлена на обработку.");
    }
}
