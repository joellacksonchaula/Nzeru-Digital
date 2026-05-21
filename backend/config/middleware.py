class CorsMiddleware:
    """
    Simple custom CORS middleware that explicitly allows all origins.
    This works in production when django-cors-headers might not.
    """
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        response = self.get_response(request)
        
        # Always add CORS headers
        response['Access-Control-Allow-Origin'] = '*'
        response['Access-Control-Allow-Methods'] = 'GET, POST, PUT, PATCH, DELETE, OPTIONS'
        response['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, X-Requested-With, X-CSRFToken'
        response['Access-Control-Max-Age'] = '3600'
        response['Access-Control-Allow-Credentials'] = 'true'
        
        return response
