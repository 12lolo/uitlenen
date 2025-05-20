<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    /**
     * Display a listing of all users (teachers)
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        $users = User::select('id', 'name', 'email', 'is_admin', 'created_at')
            ->orderBy('name')
            ->get();

        return response()->json($users);
    }

    /**
     * Store a newly created user (teacher)
     * Only admin users can create new teachers
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8',
            'is_admin' => 'boolean'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Verify that the email ends with @firda.nl
        $email = $request->email;
        if (!str_ends_with($email, '@firda.nl')) {
            return response()->json([
                'message' => 'Docent e-mail moet eindigen op @firda.nl'
            ], 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $email,
            'password' => Hash::make($request->password),
            'is_admin' => $request->is_admin ?? false
        ]);

        return response()->json([
            'message' => 'Docent succesvol toegevoegd',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'is_admin' => $user->is_admin,
                'created_at' => $user->created_at
            ]
        ], 201);
    }
}
