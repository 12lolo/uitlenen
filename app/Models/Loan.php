<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Loan extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'item_id',
        'student_name',
        'student_email',
        'loaned_at',
        'due_date',
        'returned_at',
        'return_notes',
        'notes',
        'user_id',
        'returned_to_user_id',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'loaned_at' => 'datetime',
        'due_date' => 'datetime',
        'returned_at' => 'datetime',
    ];

    /**
     * Get the item that is loaned
     */
    public function item()
    {
        return $this->belongsTo(Item::class);
    }

    /**
     * Get the user (teacher) who created the loan
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the user (teacher) who received the return
     */
    public function returnedToUser()
    {
        return $this->belongsTo(User::class, 'returned_to_user_id');
    }

    /**
     * Check if the loan is overdue
     */
    public function isOverdue()
    {
        return $this->due_date < now() && $this->returned_at === null;
    }
}
