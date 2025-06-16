<?php

namespace App\Http\Controllers;

use App\Models\ApiKey;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ApiKeyController extends Controller
{
    /**
     * Display a listing of the API keys
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        $apiKeys = ApiKey::all();
        return response()->json(['data' => $apiKeys]);
    }

    /**
     * Store a newly created API key
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'expires_at' => 'nullable|date',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $expiresAt = $request->expires_at ? new \DateTime($request->expires_at) : null;
        $apiKey = ApiKey::generate($request->name, $expiresAt);

        return response()->json([
            'message' => 'API key created successfully',
            'data' => $apiKey
        ], 201);
    }

    /**
     * Display the specified API key
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show($id)
    {
        $apiKey = ApiKey::findOrFail($id);
        return response()->json(['data' => $apiKey]);
    }

    /**
     * Update the specified API key
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request, $id)
    {
        $apiKey = ApiKey::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'active' => 'sometimes|required|boolean',
            'expires_at' => 'nullable|date',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $apiKey->update($request->only(['name', 'active', 'expires_at']));

        return response()->json([
            'message' => 'API key updated successfully',
            'data' => $apiKey
        ]);
    }

    /**
     * Remove the specified API key
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy($id)
    {
        $apiKey = ApiKey::findOrFail($id);
        $apiKey->delete();

        return response()->json([
            'message' => 'API key deleted successfully'
        ]);
    }
}
