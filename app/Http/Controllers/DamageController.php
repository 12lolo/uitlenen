<?php

namespace App\Http\Controllers;

use App\Models\Damage;
use App\Models\Item;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class DamageController extends Controller
{
    /**
     * Display a listing of all damages
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        $damages = Damage::with(['item', 'item.category', 'reportedBy'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($damages);
    }

    /**
     * Store a newly created damage report
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request, $id)
    {
        $item = Item::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'description' => 'required|string',
            'severity' => 'required|in:light,medium,severe',
            'student_email' => 'nullable|email',
            'photos' => 'nullable|array',
            'photos.*' => 'nullable|string|url'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $damage = Damage::create([
            'item_id' => $id,
            'description' => $request->description,
            'severity' => $request->severity,
            'student_email' => $request->student_email,
            'photos' => $request->photos,
            'reported_by' => $request->user()->id
        ]);

        return response()->json([
            'message' => 'Schade succesvol geregistreerd',
            'damage' => $damage
        ], 201);
    }
}
