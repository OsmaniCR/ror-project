require 'thread'
require_relative '../database'

class AsyncProductProcessor
  def initialize(product_service)
    @product_service = product_service
    @queue = Queue.new
    @running = false
    @db = Database.connect
  end

  def start
    @running = true
    @thread = Thread.new do
      process_queue
    end
  end

  def enqueue(name)
    job_id = @db[:async_jobs].insert(name: name, status: 'pending', created_at: Time.now)
    @queue << { job_id: job_id, name: name }
    job_id
  end

  def stop
    @running = false
    @queue << :stop
    @thread.join if @thread
  end

  private

  def process_queue
    while @running
      begin
        item = @queue.pop(timeout: 1)
        break if item == :stop
        next if item.nil?

        job_id = item[:job_id]
        name = item[:name]

        sleep(5)
        @product_service.create(name)
        @product_service.update_job_status(job_id, 'completed')
      rescue => e
        puts "Error processing job: #{e.message}"
        puts e.backtrace.first(5).join("\n") if e.backtrace
        begin
          if defined?(job_id) && job_id
            @product_service.update_job_status(job_id, 'failed')
          end
        rescue => update_error
          puts "Error updating job status: #{update_error.message}"
        end
      end
    end
  end
end
