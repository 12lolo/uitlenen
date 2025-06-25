<?php

namespace App\Http\Controllers;

use App\Models\Item;
use App\Models\Loan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ItemController extends ApiController
{
    /**
     * Display a listing of all items
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        $items = Item::with('category')->get();

        return $this->successResponse($items);
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
            return $this->validationErrorResponse($validator);
        }

        $item = Item::create($request->all());

        return $this->successResponse(
            ['item' => $item],
            'Item succesvol aangemaakt',
            201
        );
    }

    /**
     * Display the specified item
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show($id)
    {
        try {
            $item = Item::with('category')->findOrFail($id);
            
            // Check if item is currently on loan
            $activeLoans = Loan::where('item_id', $id)
                ->whereNull('returned_at')
                ->first();

            $isAvailable = $activeLoans === null;

            return $this->successResponse([
                'item' => $item,
                'is_available' => $isAvailable
            ]);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return $this->notFoundResponse('Het opgevraagde item kon niet worden gevonden.');
        }
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
        try {
            $item = Item::findOrFail($id);

            $validator = Validator::make($request->all(), [
                'title' => 'required|string|max:255',
                'description' => 'nullable|string',
                'category_id' => 'required|exists:categories,id',
                'photos' => 'nullable|array',
                'photos.*' => 'nullable|string|url'
            ]);

            if ($validator->fails()) {
                return $this->validationErrorResponse($validator);
            }

            $item->update($request->all());

            return $this->successResponse(['item' => $item], 'Item succesvol bijgewerkt');
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return $this->notFoundResponse('Het opgevraagde item kon niet worden gevonden.');
        }
    }

    /**
     * Remove the specified item
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy($id)
    {
        try {
            $item = Item::findOrFail($id);

            // Check if item is currently on loan
            $activeLoans = Loan::where('item_id', $id)
                ->whereNull('returned_at')
                ->count();

            if ($activeLoans > 0) {
                return $this->errorResponse(
                    'Kan item niet verwijderen omdat het momenteel is uitgeleend',
                    422
                );
            }

            $item->delete();

            return $this->successResponse(null, 'Item succesvol verwijderd');
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return $this->notFoundResponse('Het opgevraagde item kon niet worden gevonden.');
        }
    }

    /**
     * Get available items (not currently loaned out)
     * This endpoint is public - no authentication required
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function availableItems()
    {
        try {
            $availableItems = Item::whereDoesntHave('loans', function ($query) {
                $query->whereNull('returned_at');
            })->with('category')->get();
            
            return $this->successResponse(['data' => $availableItems]);
        } catch (\Exception $e) {
            return $this->errorResponse('Er is een fout opgetreden bij het ophalen van beschikbare items.', 500);
        }
    }
}
