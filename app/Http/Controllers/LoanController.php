<?php

namespace App\Http\Controllers;

use App\Models\Loan;
use App\Models\Item;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Carbon\Carbon;

class LoanController extends Controller
{
    /**
     * Display a listing of all loans
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        $loans = Loan::with(['item', 'item.category'])
            ->orderBy('due_date', 'asc')
            ->get();

        return response()->json($loans);
    }

    /**
     * Store a newly created loan
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'item_id' => 'required|exists:items,id',
            'student_name' => 'required|string|max:255',
            'student_email' => 'required|email|max:255',
            'due_date' => 'required|date|after:today',
            'notes' => 'nullable|string'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Verify that the student email ends with @student.firda.nl
        if (!str_ends_with($request->student_email, '@student.firda.nl')) {
            return response()->json([
                'message' => 'Student e-mail moet eindigen op @student.firda.nl'
            ], 422);
        }

        // Check if the item is already on loan
        $activeLoans = Loan::where('item_id', $request->item_id)
            ->whereNull('returned_at')
            ->count();

        if ($activeLoans > 0) {
            return response()->json([
                'message' => 'Dit item is momenteel al uitgeleend'
            ], 422);
        }

        $loan = Loan::create([
            'item_id' => $request->item_id,
            'student_name' => $request->student_name,
            'student_email' => $request->student_email,
            'loaned_at' => Carbon::now(),
            'due_date' => $request->due_date,
            'notes' => $request->notes,
            'user_id' => $request->user()->id // ID of the teacher who created the loan
        ]);

        return response()->json([
            'message' => 'Uitlening succesvol geregistreerd',
            'loan' => $loan
        ], 201);
    }

    /**
     * Process a returned item
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function returnItem(Request $request, $id)
    {
        $loan = Loan::with('item')->findOrFail($id);

        if ($loan->returned_at !== null) {
            return response()->json([
                'message' => 'Dit item is al geretourneerd'
            ], 422);
        }

        $loan->returned_at = Carbon::now();
        $loan->return_notes = $request->return_notes;
        $loan->returned_to_user_id = $request->user()->id; // ID of the teacher who received the return
        $loan->save();

        return response()->json([
            'message' => 'Item succesvol geretourneerd',
            'loan' => $loan
        ]);
    }

    /**
     * Get loan status overview (due today and overdue)
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function status()
    {
        $today = Carbon::today();

        // Items due today
        $dueToday = Loan::with(['item', 'item.category'])
            ->whereDate('due_date', $today)
            ->whereNull('returned_at')
            ->get();

        // Overdue items
        $overdue = Loan::with(['item', 'item.category'])
            ->whereDate('due_date', '<', $today)
            ->whereNull('returned_at')
            ->get();

        return response()->json([
            'due_today' => $dueToday,
            'overdue' => $overdue
        ]);
    }
}
