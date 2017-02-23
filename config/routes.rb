Requests::Engine.routes.draw do
  get "/", to: 'request#index'
  get '/borrow_direct', to: 'request#bd'
  post '/recall_pickups', to: 'request#recall_pickups'
  post '/submit', to: 'request#submit'
  get '/pageable', to: 'request#pageable'
  get ':system_id', to: 'request#generate' #, constraints: { system_id: /(\d|^dsp).+/ }
  post ':system_id', to: 'request#generate'
  root to: "request#index"
end
