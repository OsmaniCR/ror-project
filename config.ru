require_relative 'app'

require_relative 'lib/database'

max_retries = 10
retry_count = 0
begin
  db = Database.connect
  db.fetch("SELECT 1").first
  Database.setup
rescue => e
  retry_count += 1
  if retry_count < max_retries
    puts "Database not ready, retrying in 2 seconds... (attempt #{retry_count}/#{max_retries})"
    sleep(2)
    retry
  else
    puts "Failed to connect to database after #{max_retries} attempts: #{e.message}"
    raise
  end
end

require_relative 'lib/services/auth_service'
require_relative 'lib/services/product_service'
require_relative 'lib/services/async_product_processor'

auth_service = AuthService.new(db)
product_service = ProductService.new(db)
async_processor = AsyncProductProcessor.new(product_service)
async_processor.start

app = FudoAPI.new(db, auth_service, product_service, async_processor)

use Rack::CommonLogger, $stdout
use Rack::ContentLength
use GzipMiddleware
use AuthMiddleware, auth_service

run app
