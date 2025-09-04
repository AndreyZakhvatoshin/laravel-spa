<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name', 'email', 'password', 'avatar',
        'timezone', 'last_login_at', 'status'
    ];

    protected $hidden = [
        'password', 'remember_token',
    ];

    protected $casts = [
        'last_login_at' => 'datetime',
    ];

    public function roles(): BelongsToMany
    {
        return $this->belongsToMany(Role::class);
    }

    public function hasRole($role): bool
    {
        if (is_string($role)) {
            return $this->roles->contains('slug', $role);
        }

        return !!$role->intersect($this->roles)->count();
    }

    public function assignRole($role): void
    {
        if (is_string($role)) {
            $role = Role::where('slug', $role)->firstOrFail();
        }

        $this->roles()->syncWithoutDetaching($role);
    }

    public function hasPermission($permission): bool
    {
        foreach ($this->roles as $role) {
            if (isset($role->permissions[$permission]) && $role->permissions[$permission]) {
                return true;
            }
        }

        return false;
    }

    public function ownedBoards()
    {
        return $this->hasMany(Board::class, 'owner_id');
    }

    public function boards()
    {
        return $this->belongsToMany(Board::class, 'board_user')->withPivot('role');
    }

    public function assignedCards()
    {
        return $this->hasMany(Card::class, 'assignee_id');
    }

    public function comments()
    {
        return $this->hasMany(Comment::class);
    }
}
