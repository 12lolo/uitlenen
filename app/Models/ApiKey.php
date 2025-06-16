<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class ApiKey extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'key',
        'active',
        'expires_at',
    ];

    protected $casts = [
        'active' => 'boolean',
        'expires_at' => 'datetime',
    ];

    /**
     * Generate a new API key
     *
     * @param string $name
     * @param \DateTime|null $expiresAt
     * @return self
     */
    public static function generate(string $name, \DateTime $expiresAt = null): self
    {
        return self::create([
            'name' => $name,
            'key' => Str::random(64),
            'active' => true,
            'expires_at' => $expiresAt,
        ]);
    }

    /**
     * Determine if the API key is valid
     *
     * @return bool
     */
    public function isValid(): bool
    {
        if (!$this->active) {
            return false;
        }

        if ($this->expires_at && $this->expires_at->isPast()) {
            return false;
        }

        return true;
    }
}
