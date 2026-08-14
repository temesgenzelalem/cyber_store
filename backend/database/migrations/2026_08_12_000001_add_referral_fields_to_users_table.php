<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('referral_code')->unique()->nullable();
            $table->foreignId('referred_by')->nullable()->constrained('users')->onDelete('set null');
            $table->decimal('wallet_balance', 10, 2)->default(0);
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['referral_code', 'referred_by', 'wallet_balance']);
        });
    }
};
