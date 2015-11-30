require 'spec_helper'

describe Requests::RequestsController, type: :routing do

  describe 'routing' do

    routes { Requests::Engine.routes }

    it 'routes to #index' do
      expect(get: '/requests').to route_to('requests#index')
    end
  end
end

