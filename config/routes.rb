Requests::Engine.routes.draw do
  get "/", to: 'request#index'
  post '/borrow_direct', to: 'request#borrow_direct'
  post '/submit', to: 'request#submit'
  # no longer in use
  # get '/pageable', to: 'request#pageable'
  get ':system_id', to: 'request#generate', constraints: { system_id: /(\d+|dsp\w+|SCSB-\d+|coin-\d+)/i }
  post ':system_id', to: 'request#generate', constraints: { system_id: /(\d+|dsp\w+|SCSB-\d+|coin-\d+)/i }
  root to: "request#index"
end
