<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class FormatController extends Controller
{
    public function accountSetupFormat()
    {
        return response()->json([
            'user_id' => '(user id from verification link)',
            'name' => '(your full name)',
            'password' => '(your password)',
            'password_confirmation' => '(repeat password)'
        ]);
    }

    public function invitationResendFormat()
    {
        return response()->json([
            'email' => '(email address of the user to resend invitation)'
        ]);
    }

    public function loginFormat()
    {
        return response()->json([
            'email' => '(your email)',
            'password' => '(your password)'
        ]);
    }

    public function registerFormat()
    {
        return response()->json([
            'name' => '(your name)',
            'email' => '(your email)',
            'password' => '(your password)',
            'password_confirmation' => '(repeat password)'
        ]);
    }

    public function testEmailFormat()
    {
        return response()->json([
            'recipient' => '(recipient\'s email)',
            'subject' => '(title)',
            'message' => '(message)'
        ]);
    }

    public function categoryFormat()
    {
        return response()->json([
            'name' => '(category name)',
            'description' => '(category description)'
        ]);
    }

    public function categoryUpdateFormat()
    {
        return response()->json([
            'name' => '(updated category name)',
            'description' => '(updated category description)'
        ]);
    }

    public function itemFormat()
    {
        return response()->json([
            'name' => '(item name)',
            'description' => '(item description)',
            'category_id' => '(category id)',
            'status' => '(available/unavailable)',
            'location' => '(storage location)',
            'inventory_number' => '(inventory number)'
        ]);
    }

    public function itemUpdateFormat()
    {
        return response()->json([
            'name' => '(updated item name)',
            'description' => '(updated item description)',
            'category_id' => '(category id)',
            'status' => '(available/unavailable)',
            'location' => '(updated storage location)',
            'inventory_number' => '(updated inventory number)'
        ]);
    }

    public function lendingFormat()
    {
        return response()->json([
            'item_id' => '(item id)',
            'due_date' => '(return due date: YYYY-MM-DD)',
            'notes' => '(optional notes)'
        ]);
    }

    public function returnItemFormat()
    {
        return response()->json([
            'condition' => '(condition on return: good/damaged)',
            'notes' => '(optional notes)'
        ]);
    }

    public function damageFormat()
    {
        return response()->json([
            'description' => '(damage description)',
            'severity' => '(severity level: minor/moderate/severe)',
            'reported_by' => '(optional: user id who reported)'
        ]);
    }

    public function userFormat()
    {
        return response()->json([
            'email' => '(user email - must end with @firda.nl)',
            'is_admin' => '(optional: true/false - defaults to false if not specified)'
        ]);
    }

    public function sendRemindersFormat()
    {
        return response()->json([
            'token' => '(security token)',
            'days_before' => '(optional: days before due date to send reminder)',
            'include_overdue' => '(optional: true/false)'
        ]);
    }

    public function projectFormat()
    {
        return response()->json([
            'name' => '(project name)',
            'description' => '(project description)',
            'start_date' => '(YYYY-MM-DD)',
            'end_date' => '(YYYY-MM-DD)',
            'status' => '(active/completed/on-hold)'
        ]);
    }
}
