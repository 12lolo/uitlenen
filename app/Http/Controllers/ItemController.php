<?php

namespace App\Http\Controllers;

use App\Models\Item;
use App\Models\Loan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ItemController extends Controller
{
    /**
     * Display a listing of all items
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        $items = Item::with('category')->get();

        return response()->json($items);
    }

    /**
     * Store a newly created item
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'category_id' => 'required|exists:categories,id',
            'photos' => 'nullable|array',
            'photos.*' => 'nullable|string|url'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $item = Item::create($request->all());

        return response()->json([
            'message' => 'Item succesvol aangemaakt',
            'item' => $item
        ], 201);
    }

    /**
     * Display the specified item
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show($id)
    {
        $item = Item::with('category')->findOrFail($id);

        // Check if item is currently on loan
        $activeLoans = Loan::where('item_id', $id)
            ->whereNull('returned_at')
            ->first();

        $isAvailable = $activeLoans === null;

        return response()->json([
            'item' => $item,
            'is_available' => $isAvailable
        ]);
    }

    /**
     * Update the specified item
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request, $id)
    {
        $item = Item::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'category_id' => 'required|exists:categories,id',
            'photos' => 'nullable|array',
            'photos.*' => 'nullable|string|url'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $item->update($request->all());

        return response()->json([
            'message' => 'Item succesvol bijgewerkt',
            'item' => $item
        ]);
    }

    /**
     * Remove the specified item
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy($id)
    {
        $item = Item::findOrFail($id);

        // Check if item is currently on loan
        $activeLoans = Loan::where('item_id', $id)
            ->whereNull('returned_at')
            ->count();

        if ($activeLoans > 0) {
            return response()->json([
                'message' => 'Kan item niet verwijderen omdat het momenteel is uitgeleend'
            ], 422);
        }

        $item->delete();

        return response()->json([
            'message' => 'Item succesvol verwijderd'
        ]);
    }

    /**
     * Get available items (not currently loaned out)
     * Used with API Key authentication
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function availableItems()
    {
        $availableItems = Item::whereDoesntHave('loans', function ($query) {
            $query->whereNull('returned_at');
        })->get();
        
        return response()->json([
            'data' => $availableItems
        ]);
    }
}
