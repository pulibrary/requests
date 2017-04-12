Requests::Engine.routes.draw do
  get "/", to: 'request#index'
  post '/borrow_direct', to: 'request#borrow_direct'
  post '/recall_pickups', to: 'request#recall_pickups'
  post '/submit', to: 'request#submit'
  get '/pageable', to: 'request#pageable'
  get ':system_id', to: 'request#generate', constraints: { system_id: /(\d+|dsp\w+|visuals\d+|SCSB-\d+)/i }
  post ':system_id', to: 'request#generate', constraints: { system_id: /(\d+|dsp\w+|visuals\d+|SCSB-\d+)/i }
  root to: "request#index"
end
