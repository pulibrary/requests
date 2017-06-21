module Requests
  class Engine < ::Rails::Engine
    require 'jquery-rails'
    isolate_namespace Requests
  end
end
