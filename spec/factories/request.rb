require 'factory_girl'

FactoryGirl.define do
  factory :request, class: "Requests::Request" do
    request { FactoryGirl.create(:request) }
  do

end