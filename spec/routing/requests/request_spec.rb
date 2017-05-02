require 'spec_helper'

describe Requests::RequestController, type: :routing do
  describe 'routing' do
    routes { Requests::Engine.routes }

    it 'routes to request #index' do
      expect(get: '/').to route_to('requests/request#index')
    end
 
    it 'generates a request form via #generate' do
      expect(get: '/1235').to route_to('requests/request#generate', system_id: '1235')
    end

    it 'generates a request form for a specific mfhd via #generate' do
      expect(get: '/1235?mfhd=1234').to route_to('requests/request#generate', system_id: '1235', mfhd: '1234')
    end

    it 'submits via post to #submit' do
      expect(post: '/submit').to route_to('requests/request#submit')
    end

    # it 'handles a #pageable arguement' do
    #   expect(get: '/pageable?system_id=foo123').to route_to('requests/request#pageable', system_id: 'foo123')
    # end

    it 'routes to borrow direct' do
      expect(post: '/borrow_direct').to route_to('requests/request#borrow_direct')
    end

    it 'routes to borrow direct' do
      expect(post: '/recall_pickups').to route_to('requests/request#recall_pickups')
    end
  end
end

