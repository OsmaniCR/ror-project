class StaticFilesMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    path = request.path

    @app.call(env)
  end
end
