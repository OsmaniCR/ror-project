require 'rack'
require 'json'

class BaseController
  def initialize(request, env = {})
    @request = request
    @env = env
  end

  protected

  def json_response(data, status = 200)
    [status, { 'Content-Type' => 'application/json' }, [JSON.generate(data)]]
  end

  def error_response(message, status = 400)
    json_response({ error: message }, status)
  end

  def parse_json_body
    JSON.parse(@request.body.read)
  rescue JSON::ParserError
    nil
  end

  def current_user
    @env['fudo.user']
  end
end
