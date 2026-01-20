require 'rack'
require 'rack/contrib'
require 'json'
require 'sequel'
require 'bcrypt'
require 'fileutils'
require_relative 'lib/database'
require_relative 'lib/middleware/auth_middleware'
require_relative 'lib/middleware/gzip_middleware'
require_relative 'lib/models/user'
require_relative 'lib/models/product'
require_relative 'lib/services/auth_service'
require_relative 'lib/services/product_service'
require_relative 'lib/services/async_product_processor'
require_relative 'lib/controllers/base_controller'
require_relative 'lib/controllers/auth_controller'
require_relative 'lib/controllers/products_controller'
require_relative 'lib/controllers/static_controller'

class FudoAPI
  def initialize(db = nil, auth_service = nil, product_service = nil, async_processor = nil)
    @db = db || Database.connect
    Database.setup unless db
    @auth_service = auth_service || AuthService.new(@db)
    @product_service = product_service || ProductService.new(@db)
    if async_processor
      @async_processor = async_processor
    else
      @async_processor = AsyncProductProcessor.new(@product_service)
      @async_processor.start
    end
  end

  def call(env)
    request = Rack::Request.new(env)
    path = request.path
    method = request.request_method
    start_time = Time.now

    response = route(request, env, method, path)

    status = response[0]
    duration = ((Time.now - start_time) * 1000).round(2)
    user_info = env['fudo.user'] ? " user=#{env['fudo.user'][:username]}" : ""
    $stdout.puts "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] #{method} #{path} -> #{status} (#{duration}ms)#{user_info}"
    $stdout.flush

    response
  end

  private

  def route(request, env, method, path)
    static_controller = StaticController.new(request, env)
    return static_controller.openapi if path == '/openapi.yaml'
    return static_controller.authors if path == '/AUTHORS'

    case [method, path]
    when ['POST', '/auth']
      auth_controller = AuthController.new(request, env, @auth_service)
      auth_controller.authenticate
    when ['POST', '/products']
      products_controller = ProductsController.new(request, env, @product_service, @async_processor)
      products_controller.create
    when ['GET', '/products']
      products_controller = ProductsController.new(request, env, @product_service, @async_processor)
      products_controller.index
    else
      products_controller = ProductsController.new(request, env, @product_service, @async_processor)
      if method == 'GET' && path.match?(/^\/products\/\d+$/)
        products_controller.show
      elsif (method == 'PUT' || method == 'PATCH') && path.match?(/^\/products\/\d+$/)
        products_controller.update
      elsif method == 'DELETE' && path.match?(/^\/products\/\d+$/)
        products_controller.destroy
      else
        [404, { 'Content-Type' => 'application/json' }, [JSON.generate({ error: 'Not found' })]]
      end
    end
  end
end
