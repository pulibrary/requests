require 'spec_helper'

describe Requests::RequestController, type: :routing do
  describe 'routing' do
    routes { Requests::Engine.routes }

    it 'routes to request #index' do
      expect(get: '/').to route_to('requests/request#index')
    end
 
    it 'routes to request form #magic_request' do
      expect(get: '/1235').to route_to('requests/request#generate', system_id: '1235')
    end

    it 'submits via post to #submit' do
      expect(post: '/submit').to route_to('requests/request#submit')
    end
  end
end

