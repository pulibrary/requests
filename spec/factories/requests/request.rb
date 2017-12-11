require 'factory_girl'

FactoryGirl.define do
  # factory :request_online, class: 'Requests::Request' do
  #   system_id 8_553_130
  #   initialize_with { new(system_id) }
  # end

  factory :request_no_items, class: 'Requests::Request' do
    system_id 4492846
    user { FactoryGirl.build(:user) }
    initialize_with { new({ system_id: system_id, user: user }) }
  end

  factory :request_on_order, class: 'Requests::Request' do
    system_id 7_338_297
    user { FactoryGirl.build(:user) }
    initialize_with { new({ system_id: system_id, user: user }) }
  end

  factory :request_pending, class: 'Requests::Request' do
    system_id 10094671
    user { FactoryGirl.build(:user) }
    initialize_with { new({ system_id: system_id, user: user }) }
  end

  # factory :request_with_items_available, class: 'Requests::Request' do
  #   system_id 1 # get real ID
  #   initialize_with { new(system_id) }
  # end

  # factory :request_always_available_no_items, class: 'Requests::Request' do
  #   system_id 8_5752_09
  #   initialize_with { new(system_id) }
  # end

  # factory :request_always_available_with_items_charged, class: 'Requests::Request' do
  #   system_id 8_575_209
  #   initialize_with { new(system_id) }
  # end

  # factory :request_serial_format, class: 'Requests::Request' do
  #   system_id 1 # get real ID
  #   initialize_with { new(system_id) }
  # end

  # factory :request_aeon, class: 'Requests::Request' do
  #   system_id 9_561_302
  #   initialize_with { new(system_id) }
  # end

  # factory :request_recap, class: 'Requests::Request' do
  #   system_id 1 # get real ID
  #   initialize_with { new(system_id) }
  # end

  #  factory :request_aeon_recap, class: 'Requests::Request' do
  #   system_id 1 # get real ID
  #   initialize_with { new(system_id) }
  # end

  # factory :request_recap_edd_eligible, class: 'Requests::Request' do
  #   system_id 1 # get real ID
  #   initialize_with { new(system_id) }
  # end

  factory :request_thesis, class: 'Requests::Request' do
    system_id "dsp01rr1720547"
    user { FactoryGirl.build(:user) }
    initialize_with { new({ system_id: system_id, user: user }) }
  end

  factory :request_visuals, class: 'Requests::Request' do
    system_id "visuals46165"
    user { FactoryGirl.build(:user) }
    initialize_with { new({ system_id: system_id, user: user }) }
  end

  factory :request_paging_available, class: 'Requests::Request' do
    system_id 6009363
    user { FactoryGirl.build(:user) }
    initialize_with { new({ system_id: system_id, user: user }) }
  end

  factory :request_paging_available_barcode_patron, class: 'Requests::Request' do
    system_id 6009363
    user { FactoryGirl.build(:valid_barcode_patron) }
    initialize_with { new({ system_id: system_id, user: user }) }
  end

  factory :request_paging_available_unauthenticated_patron, class: 'Requests::Request' do
    system_id 6009363
    user { FactoryGirl.build(:unauthenticated_patron) }
    initialize_with { new({ system_id: system_id, user: user }) }
  end

  factory :request_paging_mutliple_mfhd, class: 'Requests::Request' do
    system_id 2942771
    user { FactoryGirl.build(:user) }
    initialize_with { new({ system_id: system_id, user: user }) }
  end

  # missing item
  factory :request_missing_item, class: 'Requests::Request' do
    system_id 1389121
    user { FactoryGirl.build(:user) }
    initialize_with { new({ system_id: system_id, user: user }) }
  end

  factory :request_missing_item_barcode_patron, class: 'Requests::Request' do
    system_id 1389121
    user { FactoryGirl.build(:valid_barcode_patron) }
    initialize_with { new({ system_id: system_id, user: user }) }
  end

  factory :request_missing_item_unauthenticated_patron, class: 'Requests::Request' do
    system_id 1389121
    user { FactoryGirl.build(:unauthenticated_patron) }
    initialize_with { new({ system_id: system_id, user: user }) }
  end

  factory :request_on_shelf, class: 'Requests::Request' do
    system_id 1214063
    user { FactoryGirl.build(:user) }
    initialize_with { new({ system_id: system_id, user: user }) }
  end

  factory :aeon_eal_voyager_item, class: 'Requests::Request' do
    system_id 7721323
    user { FactoryGirl.build(:user) }
    initialize_with { new({ system_id: system_id, user: user }) }
  end

  factory :aeon_w_barcode, class: 'Requests::Request' do
    system_id 9594435
    user { FactoryGirl.build(:user) }
    initialize_with { new({ system_id: system_id, user: user }) }
  end

  factory :aeon_no_item_record, class: 'Requests::Request' do
    system_id 2535845
    user { FactoryGirl.build(:user) }
    initialize_with { new({ system_id: system_id, user: user }) }
  end

  factory :aeon_rbsc_voyager_enumerated, class: 'Requests::Request' do
    system_id 616086
    mfhd_id '675722'
    source 'pulsearch'
    user { FactoryGirl.build(:user) }
    initialize_with { new({ system_id: system_id, user: user, mfhd: mfhd_id, source: source }) }
  end

  factory :aeon_rbsc_enumerated, class: 'Requests::Request' do
    system_id 6794966
    mfhd_id '6720550'
    source 'pulsearch'
    user { FactoryGirl.build(:user) }
    initialize_with { new({ system_id: system_id, user: user, mfhd: mfhd_id, source: source }) }
  end

  factory :aeon_marquand, class: 'Requests::Request' do
    system_id 7915334
    mfhd_id '7697569'
    source 'pulsearch'
    user { FactoryGirl.build(:user) }
    initialize_with { new({ system_id: system_id, user: user, mfhd: mfhd_id, source: source }) }
  end

  factory :aeon_mudd, class: 'Requests::Request' do
    system_id 6023439
    mfhd_id '6080541'
    source 'pulsearch'
    user { FactoryGirl.build(:user) }
    initialize_with { new({ system_id: system_id, user: user, mfhd: mfhd_id, source: source }) }
  end

  factory :aeon_mudd_barcode_patron, class: 'Requests::Request' do
    system_id 6023439
    mfhd_id '6080541'
    source 'pulsearch'
    user { FactoryGirl.build(:valid_barcode_patron) }
    initialize_with { new({ system_id: system_id, user: user, mfhd: mfhd_id, source: source }) }
  end

  factory :aeon_mudd_unauthenticated_patron, class: 'Requests::Request' do
    system_id 6023439
    mfhd_id '6080541'
    source 'pulsearch'
    user { FactoryGirl.build(:unauthenticated_patron) }
    initialize_with { new({ system_id: system_id, user: user, mfhd: mfhd_id, source: source }) }
  end

  factory :missing_item, class: 'Requests::Request' do
    system_id 1389121
    mfhd_id '1594697'
    source 'pulsearch'
    user { FactoryGirl.build(:user) }
    initialize_with { new({ system_id: system_id, user: user, mfhd: mfhd_id, source: source }) }
  end

  factory :request_with_items_charged, class: 'Requests::Request' do
    system_id 1389121
    mfhd_id '1594698'
    source 'pulsearch'
    user { FactoryGirl.build(:user) }
    initialize_with { new({ system_id: system_id, user: user, mfhd: mfhd_id, source: source }) }
  end

  factory :request_with_items_charged_barcode_patron, class: 'Requests::Request' do
    system_id 1389121
    mfhd_id '1594698'
    source 'pulsearch'
    user { FactoryGirl.build(:valid_barcode_patron) }
    initialize_with { new({ system_id: system_id, user: user, mfhd: mfhd_id, source: source }) }
  end

  factory :request_with_items_charged_unauthenticated_patron, class: 'Requests::Request' do
    system_id 1389121
    mfhd_id '1594698'
    source 'pulsearch'
    user { FactoryGirl.build(:unauthenticated_patron) }
    initialize_with { new({ system_id: system_id, user: user, mfhd: mfhd_id, source: source }) }
  end

  factory :request_serial_with_item_on_hold, class: 'Requests::Request' do
    system_id 4563519
    mfhd_id '4808685'
    source 'pulsearch'
    user { FactoryGirl.build(:user) }
    initialize_with { new({ system_id: system_id, user: user, mfhd: mfhd_id, source: source }) }
  end

  factory :request_aeon_holding_volume_note, class: 'Requests::Request' do
    system_id 616086
    mfhd_id '5132984'
    source 'pulsearch'
    user { FactoryGirl.build(:user) }
    initialize_with { new({ system_id: system_id, user: user, mfhd: mfhd_id, source: source }) }
  end
end