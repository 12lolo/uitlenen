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
        Schema::table('items', function (Blueprint $table) {
            $table->string('status')->default('available')->after('photos');
            $table->string('location')->nullable()->after('status');
            $table->string('inventory_number')->nullable()->unique()->after('location');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('items', function (Blueprint $table) {
            $table->dropColumn(['status', 'location', 'inventory_number']);
        });
    }
};
