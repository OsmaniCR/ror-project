require_relative 'base_controller'

class StaticController < BaseController
  def openapi
    content = File.read(File.join(__dir__, '..', '..', 'openapi.yaml'))
    [
      200,
      {
        'Content-Type' => 'text/yaml',
        'Cache-Control' => 'no-cache, no-store, must-revalidate',
        'Pragma' => 'no-cache',
        'Expires' => '0'
      },
      [content]
    ]
  end

  def authors
    content = File.read(File.join(__dir__, '..', '..', 'AUTHORS'))
    [
      200,
      {
        'Content-Type' => 'text/plain',
        'Cache-Control' => 'public, max-age=86400'
      },
      [content]
    ]
  end
end
