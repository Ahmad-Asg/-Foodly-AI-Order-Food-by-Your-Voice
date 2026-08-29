export function errorHandler(error, request, response, next) {
  const statusCode = error.code === 11000 ? 409 : (error.statusCode ?? 500);
  if (statusCode >= 500) console.error(error);

  response.status(statusCode).json({
    success: false,
    message: error.code === 11000
      ? 'An account with this email already exists.'
      : (statusCode >= 500 ? 'An unexpected server error occurred.' : error.message),
  });
}
