require 'factory_girl'

FactoryGirl.define do
  factory :request_online, class: "Requests::Request" do
    system_id 8_553_130
    initialize_with { new(system_id) }
  end

  factory :request_no_items, class: "Requests::Request" do
    system_id 1_918_456
    initialize_with { new(system_id) }
  end

  factory :request_on_order, class: "Requests::Request" do
    system_id 7_338_297
    initialize_with { new(system_id) }
  end

  factory :request_with_items_available, class: "Requests::Request" do
    system_id 1 # get real ID
    initialize_with { new(system_id) }
  end

  factory :request_always_available_no_items, class: "Requests::Request" do
    system_id 8_5752_09
    initialize_with { new(system_id) }
  end

  factory :request_always_available_with_items_charged, class: "Requests::Request" do
    system_id 8_575_209
    initialize_with { new(system_id) }
  end

  factory :request_with_items_charged, class: "Requests::Request" do
    system_id 1 # get real ID
    initialize_with { new(system_id) }
  end

  factory :request_serial_format, class: "Requests::Request" do
    system_id 1 # get real ID
    initialize_with { new(system_id) }
  end

  factory :request_aeon, class: "Requests::Request" do
    system_id 9_561_302 
    initialize_with { new(system_id) }
  end

  factory :request_recap, class: "Requests::Request" do
    system_id 1 # get real ID
    initialize_with { new(system_id) }
  end

   factory :request_aeon_recap, class: "Requests::Request" do
    system_id 1 # get real ID
    initialize_with { new(system_id) }
  end

  factory :request_recap_edd_eligible, class: "Requests::Request" do
    system_id 1 # get real ID
    initialize_with { new(system_id) }
  end

  factory :request_thesis, class: "Requests::Request" do
    system_id "dsp01rr1720547"
    initialize_with { new(system_id) }
  end

  factory :request_paging_available, class: "Requests::Request" do
    system_id 6009363
    user { FactoryGirl.build(:user) }
    initialize_with { new( { system_id: system_id, user: user } ) }
  end

  factory :request_paging_mutliple_mfhd, class: "Requests::Request" do
    system_id 2942771
    user { FactoryGirl.build(:user) }
    initialize_with { new( { system_id: system_id, user: user } ) }
  end

end