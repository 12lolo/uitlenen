<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class HelpController extends Controller
{
    /**
     * Display public API help information
     */
    public function publicHelp()
    {
        $publicEndpoints = [
            [
                'module' => '🔐 Authentication',
                'endpoints' => [
                    [
                        'method' => 'POST',
                        'endpoint' => '/api/login',
                        'description' => 'Login with registered account',
                        'auth_required' => false
                    ],
                    [
                        'method' => 'POST',
                        'endpoint' => '/api/register',
                        'description' => 'Register new account (only @firda.nl or @student.firda.nl)',
                        'auth_required' => false
                    ],
                ]
            ],
            [
                'module' => '📂 Categories',
                'endpoints' => [
                    [
                        'method' => 'GET',
                        'endpoint' => '/api/categories',
                        'description' => 'Get list of all categories',
                        'auth_required' => false
                    ],
                    [
                        'method' => 'GET',
                        'endpoint' => '/api/categories/{id}/items',
                        'description' => 'Get items within a specific category',
                        'auth_required' => false
                    ]
                ]
            ],
            [
                'module' => '📦 Items',
                'endpoints' => [
                    [
                        'method' => 'GET',
                        'endpoint' => '/api/items/{id}',
                        'description' => 'Get details for a specific item',
                        'auth_required' => false
                    ]
                ]
            ],
            [
                'module' => '🧪 Testing',
                'endpoints' => [
                    [
                        'method' => 'POST',
                        'endpoint' => '/api/test/email',
                        'description' => 'Send a test email to verify mail configuration',
                        'auth_required' => false,
                        'parameters' => [
                            'recipient' => 'Email address to send the test to (required)',
                            'subject' => 'Email subject (optional)',
                            'message' => 'Email message (optional)'
                        ]
                    ]
                ]
            ],
            [
                'module' => '❓ Help',
                'endpoints' => [
                    [
                        'method' => 'GET',
                        'endpoint' => '/api/help',
                        'description' => 'Show all public API endpoints',
                        'auth_required' => false
                    ],
                    [
                        'method' => 'GET',
                        'endpoint' => '/api/help/authenticated',
                        'description' => 'Show all API endpoints (requires login)',
                        'auth_required' => true
                    ]
                ]
            ]
        ];

        return response()->json([
            'status' => 'success',
            'message' => 'Welcome to the Firda Lending API',
            'version' => '1.0',
            'public_endpoints' => $publicEndpoints
        ]);
    }

    /**
     * Display authenticated API help information (requires login)
     */
    public function authenticatedHelp()
    {
        $authenticatedEndpoints = [
            [
                'module' => '🔐 Authentication',
                'endpoints' => [
                    [
                        'method' => 'POST',
                        'endpoint' => '/api/logout',
                        'description' => 'Logout and invalidate token',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'GET',
                        'endpoint' => '/api/user',
                        'description' => 'Get current user profile',
                        'auth_required' => true
                    ]
                ]
            ],
            [
                'module' => '📂 Category Management',
                'endpoints' => [
                    [
                        'method' => 'POST',
                        'endpoint' => '/api/categories',
                        'description' => 'Create new category',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'PUT',
                        'endpoint' => '/api/categories/{id}',
                        'description' => 'Update existing category',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'DELETE',
                        'endpoint' => '/api/categories/{id}',
                        'description' => 'Delete category',
                        'auth_required' => true
                    ]
                ]
            ],
            [
                'module' => '📦 Item Management',
                'endpoints' => [
                    [
                        'method' => 'GET',
                        'endpoint' => '/api/items',
                        'description' => 'Get all items',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'POST',
                        'endpoint' => '/api/items',
                        'description' => 'Create new item',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'PUT',
                        'endpoint' => '/api/items/{id}',
                        'description' => 'Update existing item',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'DELETE',
                        'endpoint' => '/api/items/{id}',
                        'description' => 'Delete item',
                        'auth_required' => true
                    ]
                ]
            ],
            [
                'module' => '➕ Loan Management',
                'endpoints' => [
                    [
                        'method' => 'GET',
                        'endpoint' => '/api/lendings',
                        'description' => 'Get all loans',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'POST',
                        'endpoint' => '/api/lendings',
                        'description' => 'Create new loan',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'POST',
                        'endpoint' => '/api/lendings/{id}/return',
                        'description' => 'Return an item',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'GET',
                        'endpoint' => '/api/lendings/status',
                        'description' => 'Get loans due today or overdue',
                        'auth_required' => true
                    ]
                ]
            ],
            [
                'module' => '🛠 Damage Management',
                'endpoints' => [
                    [
                        'method' => 'GET',
                        'endpoint' => '/api/damages',
                        'description' => 'Get all damage reports',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'POST',
                        'endpoint' => '/api/items/{id}/damage',
                        'description' => 'Report damage for an item',
                        'auth_required' => true
                    ]
                ]
            ],
            [
                'module' => '👥 User Management (Admin Only)',
                'endpoints' => [
                    [
                        'method' => 'GET',
                        'endpoint' => '/api/users',
                        'description' => 'Get all users (teachers)',
                        'auth_required' => true,
                        'admin_required' => true
                    ],
                    [
                        'method' => 'POST',
                        'endpoint' => '/api/users',
                        'description' => 'Create new user (teacher)',
                        'auth_required' => true,
                        'admin_required' => true
                    ]
                ]
            ],
            [
                'module' => '📧 Notifications',
                'endpoints' => [
                    [
                        'method' => 'POST',
                        'endpoint' => '/api/notifications/send-reminders',
                        'description' => 'Send reminders for upcoming returns and overdue items',
                        'auth_required' => true,
                        'cron_token_required' => true
                    ]
                ]
            ]
        ];

        return response()->json([
            'status' => 'success',
            'message' => 'Welcome to the Firda Lending API - Authenticated endpoints',
            'user' => auth()->user()->name,
            'authenticated_endpoints' => $authenticatedEndpoints
        ]);
    }
}
