<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('damages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('item_id')->constrained()->onDelete('cascade');
            $table->text('description');
            $table->string('severity'); // Could be enum: 'minor', 'moderate', 'severe'
            $table->string('student_email')->nullable();
            $table->json('photos')->nullable();
            $table->foreignId('reported_by')->constrained('users'); // Teacher who reported the damage
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('damages');
    }
};
