<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Board extends Model
{
    use HasFactory;

    protected $fillable = ['title', 'description', 'owner_id'];

    public function owner()
    {
        return $this->belongsTo(User::class, 'owner_id');
    }

    public function members()
    {
        return $this->belongsToMany(User::class, 'board_user')->withPivot('role');
    }

    public function columns()
    {
        return $this->hasMany(Column::class)->orderBy('order');
    }

    public function labels()
    {
        return $this->hasMany(Label::class);
    }
}
