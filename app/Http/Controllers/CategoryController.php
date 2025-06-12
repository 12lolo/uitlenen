<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\Item;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CategoryController extends Controller
{
    /**
     * Display a listing of all categories
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        $categories = Category::all();
        return response()->json($categories);
    }

    /**
     * Store a newly created category
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255|unique:categories',
            'description' => 'nullable|string'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $category = Category::create($request->all());

        return response()->json([
            'message' => 'Categorie succesvol aangemaakt',
            'category' => $category
        ], 201);
    }

    /**
     * Display all items in a specific category
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function items($id)
    {
        $category = Category::findOrFail($id);
        $items = Item::where('category_id', $id)
            ->with('category')
            ->get();

        return response()->json([
            'category' => $category,
            'items' => $items
        ]);
    }

    /**
     * Update the specified category
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request, $id)
    {
        $category = Category::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255|unique:categories,name,' . $id,
            'description' => 'nullable|string'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $category->update($request->all());

        return response()->json([
            'message' => 'Categorie succesvol bijgewerkt',
            'category' => $category
        ]);
    }

    /**
     * Remove the specified category
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy($id)
    {
        $category = Category::findOrFail($id);

        // Check if category has items
        $itemCount = Item::where('category_id', $id)->count();

        if ($itemCount > 0) {
            return response()->json([
                'message' => 'Kan categorie niet verwijderen omdat er nog items aan gekoppeld zijn'
            ], 422);
        }

        $category->delete();

        return response()->json([
            'message' => 'Categorie succesvol verwijderd'
        ]);
    }
}
