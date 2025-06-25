<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class UserController extends ApiController
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

        return $this->successResponse($users);
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
            'email' => 'required|string|email|max:255|unique:users',
            'is_admin' => 'boolean'
        ]);

        if ($validator->fails()) {
            return $this->validationErrorResponse($validator);
        }

        // Verify that the email ends with @firda.nl
        $email = $request->email;
        if (!str_ends_with($email, '@firda.nl')) {
            return $this->errorResponse('Docent e-mail moet eindigen op @firda.nl', 422);
        }

        // Generate a temporary random password (not needed for login since user will set their password)
        $tempPassword = Str::random(16);

        $user = User::create([
            'name' => 'New User', // Temporary name
            'email' => $email,
            'password' => Hash::make($tempPassword),
            'is_admin' => $request->is_admin ?? false,
            'setup_completed' => false,
            'invitation_sent_at' => now()
        ]);

        // Send verification email
        $user->sendEmailVerificationNotification();

        return $this->successResponse(
            [
                'user' => [
                    'id' => $user->id,
                    'email' => $user->email,
                    'is_admin' => $user->is_admin,
                    'created_at' => $user->created_at
                ]
            ],
            'Uitnodiging succesvol verzonden. De gebruiker ontvangt een e-mail om het account te activeren.',
            201
        );
    }

    /**
     * Remove the specified user
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy($id)
    {
        try {
            $user = User::findOrFail($id);
            
            // Check if the user has active loans
            if ($user->loans()->whereNull('returned_at')->count() > 0) {
                return $this->errorResponse(
                    'Kan gebruiker niet verwijderen omdat deze nog actieve uitleningen heeft',
                    422
                );
            }
            
            // Delete the user
            $user->delete();
            
            return $this->successResponse(
                null, 
                'Gebruiker succesvol verwijderd'
            );
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return $this->notFoundResponse('De opgevraagde gebruiker kon niet worden gevonden');
        } catch (\Exception $e) {
            return $this->errorResponse(
                'Er is een fout opgetreden bij het verwijderen van de gebruiker', 
                500
            );
        }
    }
}
