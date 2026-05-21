from django.http import HttpResponse


class CorsMiddleware:
    """
    Simple custom CORS middleware that explicitly allows all origins.
    Handles preflight OPTIONS requests properly.
    """
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Handle preflight OPTIONS request
        if request.method == 'OPTIONS':
            response = HttpResponse()
        else:
            response = self.get_response(request)
        
        # Always add CORS headers
        response['Access-Control-Allow-Origin'] = '*'
        response['Access-Control-Allow-Methods'] = 'GET, POST, PUT, PATCH, DELETE, OPTIONS'
        response['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, X-Requested-With, X-CSRFToken'
        response['Access-Control-Max-Age'] = '3600'
        
        return response

