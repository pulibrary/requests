require 'factory_girl'

FactoryGirl.define do
  factory :holding, class: "Requests::Holding" do
    holding_hash { }
    initialize_with { new(holding_hash) }
  end
end