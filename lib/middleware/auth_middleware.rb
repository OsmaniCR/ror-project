require 'json'

class AuthMiddleware
  def initialize(app, auth_service)
    @app = app
    @auth_service = auth_service
  end

  def call(env)
    request = Rack::Request.new(env)
    path = request.path

    if path == '/auth' || path == '/openapi.yaml' || path == '/AUTHORS'
      return @app.call(env)
    end

    auth_header = env['HTTP_AUTHORIZATION']
    if auth_header && auth_header.start_with?('Bearer ')
      token = auth_header[7..-1]
      token_data = @auth_service.validate_token(token)
      
      if token_data
        env['fudo.user'] = token_data
        return @app.call(env)
      end
    end

    [401, { 'Content-Type' => 'application/json' }, [JSON.generate({ error: 'Unauthorized' })]]
  end
end
