<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Damage extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'item_id',
        'description',
        'severity',
        'student_email',
        'photos',
        'reported_by',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'photos' => 'array',
    ];

    /**
     * Get the item that has damage
     */
    public function item()
    {
        return $this->belongsTo(Item::class);
    }

    /**
     * Get the user (teacher) who reported the damage
     */
    public function reportedBy()
    {
        return $this->belongsTo(User::class, 'reported_by');
    }
}
