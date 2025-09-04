<?php

declare(strict_types=1);

namespace App\Actions\Board;

use App\Events\Board\BoardCreated;
use App\Models\Board;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class CreateBoardAction
{
    /**
     * Создает новую доску и назначает владельца.
     *
     * @param array $data Данные для создания доски (title, description).
     * @param User $owner Пользователь, который будет владельцем.
     * @return Board
     */
    public function __invoke(array $data, User $owner): Board
    {
        // Оборачиваем в транзакцию, чтобы обеспечить целостность данных.
        // Если при привязке участника произойдет ошибка, создание доски тоже отменится.
        return DB::transaction(function () use ($data, $owner) {

            // 1. Создаем саму доску, добавляя ID владельца
            $board = Board::create([
                'title' => $data['title'],
                'description' => $data['description'] ?? null,
                'owner_id' => $owner->id,
            ]);

            // 2. Добавляем создателя как участника с ролью 'owner' в pivot-таблицу
            $board->members()->attach($owner->id, ['role' => 'owner']);
            BoardCreated::dispatch($board);
            return $board;
        });
    }
}
