require 'zlib'
require 'stringio'

class GzipMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    accept_encoding = env['HTTP_ACCEPT_ENCODING'] || ''
    return [status, headers, body] unless accept_encoding.include?('gzip')

    content_type = headers['Content-Type'] || ''
    return [status, headers, body] unless content_type.include?('application/json') || content_type.include?('text/')

    body_content = ''
    body.each { |chunk| body_content << chunk }
    body.close if body.respond_to?(:close)

    compressed_body = compress(body_content)
    headers['Content-Encoding'] = 'gzip'
    headers['Content-Length'] = compressed_body.bytesize.to_s
    headers.delete('Transfer-Encoding')

    [status, headers, [compressed_body]]
  end

  private

  def compress(content)
    io = StringIO.new
    gz = Zlib::GzipWriter.new(io)
    gz.write(content)
    gz.close
    io.string
  end
end
