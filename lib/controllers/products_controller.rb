require_relative 'base_controller'

class ProductsController < BaseController
  def initialize(request, env, product_service, async_processor)
    super(request, env)
    @product_service = product_service
    @async_processor = async_processor
  end

  def create
    body = parse_json_body
    return error_response('Invalid JSON', 400) unless body

    name = body['name']
    return error_response('Name is required', 400) if name.nil? || name.empty?

    job_id = @async_processor.enqueue(name)
    json_response({ job_id: job_id, message: 'Product creation queued' }, 202)
  end

  def index
    products = @product_service.list_all
    json_response(products)
  end

  def show
    id = @request.path.split('/').last.to_i
    product = @product_service.find(id)

    if product
      json_response(product)
    else
      error_response('Product not found', 404)
    end
  end

  def update
    id = @request.path.split('/').last.to_i
    body = parse_json_body
    return error_response('Invalid JSON', 400) unless body

    name = body['name']
    return error_response('Name is required', 400) if name.nil? || name.empty?

    product = @product_service.update(id, name)
    if product
      json_response(product)
    else
      error_response('Product not found', 404)
    end
  end

  def destroy
    id = @request.path.split('/').last.to_i
    deleted = @product_service.delete(id)

    if deleted
      json_response({ message: 'Product deleted successfully' })
    else
      error_response('Product not found', 404)
    end
  end
end
