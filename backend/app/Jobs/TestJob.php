<?php

namespace App\Jobs;

use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Log;

class TestJob implements ShouldQueue
{
    use Queueable;

    public $tries = 3;
    public $timeout = 120;

    public function __construct()
    {
        //
    }

    public function handle(): void
    {
        $timestamp = now()->format('Y-m-d H:i:s');
        Log::info("✅ TestScheduledJob started at: {$timestamp}");
        
        // Имитация работы
        sleep(3);
        
        Log::info("✅ TestScheduledJob completed at: " . now()->format('Y-m-d H:i:s'));
    }
}
