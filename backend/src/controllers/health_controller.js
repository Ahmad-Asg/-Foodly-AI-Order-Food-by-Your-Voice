export function getHealth(request, response) {
  response.status(200).json({
    success: true,
    message: 'Foodly AI API is running',
  });
}
