<?php

namespace App\Http\Controllers;

use App\Actions\Board\CreateBoardAction;
use App\Http\Requests\Board\CreateBoardRequest;
use App\Models\Board;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class BoardController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        // Получаем все доски, где пользователь является членом (включая owned)
        $boards = Auth::user()->boards()->with(['owner', 'columns.cards'])->get();

        return response()->json($boards);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(CreateBoardRequest $request, CreateBoardAction $createBoard)
    {
        $board = $createBoard(
            $request->validated(),
            Auth::user()
        );

        // 3. Формируем успешный ответ, как и раньше
        return response()->json(
            $board->load(['owner', 'members', 'columns']),
            201
        );
    }

    /**
     * Display the specified resource.
     */
    public function show(Board $board)
    {
        // Проверяем, является ли пользователь членом доски
        if (!$board->members()->where('user_id', Auth::id())->exists()) {
            abort(403, 'You are not a member of this board.');
        }

        return response()->json($board->load(['owner', 'members', 'columns.cards.labels', 'columns.cards.comments', 'columns.cards.assignee']));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Board $board)
    {
        // Только owner может обновлять
        if ($board->owner_id !== Auth::id()) {
            abort(403, 'Only the owner can update this board.');
        }

        $validated = $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
        ]);

        $board->update($validated);

        return response()->json($board->fresh());
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Board $board)
    {
        // Только owner может удалять
        if ($board->owner_id !== Auth::id()) {
            abort(403, 'Only the owner can delete this board.');
        }

        $board->delete();

        return response()->json(null, 204);
    }

    /**
     * Add a member to the board.
     */
    public function addMember(Request $request, Board $board)
    {
        // Только owner может добавлять членов
        if ($board->owner_id !== Auth::id()) {
            abort(403, 'Only the owner can add members.');
        }

        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'role' => 'required|in:member', // Не позволяем добавлять owner'а
        ]);

        // Проверяем, не является ли уже членом
        if ($board->members()->where('user_id', $validated['user_id'])->exists()) {
            return response()->json(['error' => 'User is already a member.'], 400);
        }

        $board->members()->attach($validated['user_id'], ['role' => $validated['role']]);

        // TODO: Здесь можно добавить уведомление по email/websocket, e.g. $user->notify(...)

        return response()->json($board->fresh()->members);
    }

    /**
     * Remove a member from the board.
     */
    public function removeMember(Board $board, User $user)
    {
        // Только owner может удалять членов
        if ($board->owner_id !== Auth::id()) {
            abort(403, 'Only the owner can remove members.');
        }

        // Нельзя удалить самого owner'а
        if ($board->owner_id === $user->id) {
            return response()->json(['error' => 'Cannot remove the owner.'], 400);
        }

        $board->members()->detach($user->id);

        // TODO: Уведомление

        return response()->json($board->fresh()->members);
    }
}
