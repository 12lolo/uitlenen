<?php

namespace App\Traits;

trait ApiResponser
{
    /**
     * Return a success JSON response.
     *
     * @param array|string $data
     * @param string $message
     * @param int $code
     * @return \Illuminate\Http\JsonResponse
     */
    protected function successResponse($data, $message = null, $code = 200)
    {
        return response()->json([
            'status' => 'success',
            'message' => $message,
            'data' => $data
        ], $code);
    }

    /**
     * Return an error JSON response.
     *
     * @param string $message
     * @param int $code
     * @param array|string|null $data
     * @return \Illuminate\Http\JsonResponse
     */
    protected function errorResponse($message, $code, $data = null)
    {
        $response = [
            'status' => 'error',
            'message' => $message,
            'status_code' => $code
        ];

        if ($data) {
            $response['errors'] = $data;
        }

        return response()->json($response, $code);
    }

    /**
     * Return a validation error JSON response.
     *
     * @param \Illuminate\Validation\Validator $validator
     * @return \Illuminate\Http\JsonResponse
     */
    protected function validationErrorResponse($validator)
    {
        return $this->errorResponse(
            'De ingevoerde gegevens zijn ongeldig.',
            422,
            $validator->errors()
        );
    }
    
    /**
     * Return a not found JSON response.
     * 
     * @param string $message
     * @return \Illuminate\Http\JsonResponse
     */
    protected function notFoundResponse($message = 'Het opgevraagde item kon niet worden gevonden.')
    {
        return $this->errorResponse($message, 404);
    }
    
    /**
     * Return an unauthorized JSON response.
     * 
     * @param string $message
     * @return \Illuminate\Http\JsonResponse
     */
    protected function unauthorizedResponse($message = 'Je bent niet geautoriseerd voor deze actie.')
    {
        return $this->errorResponse($message, 403);
    }
    
    /**
     * Return an unauthenticated JSON response.
     * 
     * @param string $message
     * @return \Illuminate\Http\JsonResponse
     */
    protected function unauthenticatedResponse($message = 'Je bent niet ingelogd.')
    {
        return $this->errorResponse($message, 401);
    }
}
