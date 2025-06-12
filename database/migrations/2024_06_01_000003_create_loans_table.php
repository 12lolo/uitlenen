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
        Schema::create('loans', function (Blueprint $table) {
            $table->id();
            $table->foreignId('item_id')->constrained()->onDelete('cascade');
            $table->string('student_name');
            $table->string('student_email');
            $table->timestamp('loaned_at');
            $table->timestamp('due_date');
            $table->timestamp('returned_at')->nullable();
            $table->text('return_notes')->nullable();
            $table->text('notes')->nullable();
            $table->foreignId('user_id')->constrained(); // Teacher who created the loan
            $table->foreignId('returned_to_user_id')->nullable()->constrained('users'); // Teacher who received the return
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('loans');
    }
};
