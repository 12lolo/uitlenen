<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Item extends Model
{
    use HasFactory;    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'title',
        'description',
        'category_id',
        'photos',
        'status',
        'location',
        'inventory_number',
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
     * Get the category that owns the item
     */
    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    /**
     * Get the loans for this item
     */
    public function loans()
    {
        return $this->hasMany(Loan::class);
    }

    /**
     * Get the damage reports for this item
     */
    public function damageReports()
    {
        return $this->hasMany(Damage::class);
    }

    /**
     * Check if the item is currently on loan
     */
    public function isOnLoan()
    {
        return $this->loans()->whereNull('returned_at')->exists();
    }
}
