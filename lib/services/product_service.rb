require_relative '../models/product'

class ProductService
  def initialize(db)
    @db = db
  end

  def create(name)
    id = @db[:products].insert(name: name, created_at: Time.now)
    find(id)
  end

  def find(id)
    product_data = @db[:products].where(id: id).first
    return nil unless product_data
    product = Product.new(product_data)
    product.to_hash
  end

  def list_all
    @db[:products].order(:id).map do |product_data|
      product = Product.new(product_data)
      product.to_hash
    end
  end

  def update(id, name)
    updated = @db[:products].where(id: id).update(name: name)
    return nil if updated == 0
    find(id)
  end

  def delete(id)
    deleted = @db[:products].where(id: id).delete
    deleted > 0
  end

  def update_job_status(job_id, status)
    @db[:async_jobs].where(id: job_id).update(status: status, processed_at: Time.now)
  end
end
