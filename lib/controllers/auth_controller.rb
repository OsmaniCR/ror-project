require_relative 'base_controller'

class AuthController < BaseController
  def initialize(request, env, auth_service)
    super(request, env)
    @auth_service = auth_service
  end

  def authenticate
    body = parse_json_body
    return error_response('Invalid JSON', 400) unless body

    username = body['username']
    password = body['password']

    token = @auth_service.authenticate(username, password)
    if token
      json_response({ token: token })
    else
      error_response('Invalid credentials', 401)
    end
  end
end
