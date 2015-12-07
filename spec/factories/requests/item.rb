require 'factory_girl'

FactoryGirl.define do
  factory :item, class: "Requests::Item" do
    item { FactoryGirl.create(:item) }
  end
end