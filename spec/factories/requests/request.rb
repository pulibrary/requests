require 'factory_girl'

FactoryGirl.define do
  # factory :request_online, class: 'Requests::Request' do
  #   system_id 8_553_130
  #   initialize_with { new(system_id) }
  # end

  factory :request_no_items, class: 'Requests::Request' do
    system_id 4_492_846
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, user_barcode: user_barcode) }
  end

  factory :request_on_order, class: 'Requests::Request' do
    system_id 11_416_426
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, user_barcode: user_barcode) }
  end

  factory :request_pending, class: 'Requests::Request' do
    system_id 11_889_085
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, user_barcode: user_barcode) }
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
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, user_barcode: user_barcode) }
  end

  factory :request_numismatics, class: 'Requests::Request' do
    system_id "coin-1167"
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, user_barcode: user_barcode) }
  end

  factory :request_paging_available, class: 'Requests::Request' do
    system_id 6_009_363
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, user_barcode: user_barcode) }
  end

  factory :request_paging_available_barcode_patron, class: 'Requests::Request' do
    system_id 6_009_363
    user { FactoryGirl.build(:valid_barcode_patron) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, user_barcode: user_barcode) }
  end

  factory :request_paging_available_unauthenticated_patron, class: 'Requests::Request' do
    system_id 6_009_363
    user { FactoryGirl.build(:unauthenticated_patron) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, user_barcode: user_barcode) }
  end

  factory :request_paging_mutliple_mfhd, class: 'Requests::Request' do
    system_id 2_942_771
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, user_barcode: user_barcode) }
  end

  # missing item
  factory :request_missing_item, class: 'Requests::Request' do
    system_id 1_389_121
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, user_barcode: user_barcode) }
  end

  factory :request_missing_item_barcode_patron, class: 'Requests::Request' do
    system_id 1_389_121
    user { FactoryGirl.build(:valid_barcode_patron) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, user_barcode: user_barcode) }
  end

  factory :request_missing_item_unauthenticated_patron, class: 'Requests::Request' do
    system_id 1_389_121
    user { FactoryGirl.build(:unauthenticated_patron) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, user_barcode: user_barcode) }
  end

  factory :request_on_shelf, class: 'Requests::Request' do
    system_id 1_214_063
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, user_barcode: user_barcode) }
  end

  factory :aeon_eal_voyager_item, class: 'Requests::Request' do
    system_id 7_721_323
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, user_barcode: user_barcode) }
  end

  factory :aeon_w_barcode, class: 'Requests::Request' do
    system_id 9_594_435
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, user_barcode: user_barcode) }
  end

  factory :aeon_w_long_title, class: 'Requests::Request' do
    system_id 2_990_846
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, user_barcode: user_barcode) }
  end

  factory :aeon_no_item_record, class: 'Requests::Request' do
    system_id 2_535_845
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, user_barcode: user_barcode) }
  end

  factory :aeon_rbsc_voyager_enumerated, class: 'Requests::Request' do
    system_id 616_086
    mfhd_id '675722'
    source 'pulsearch'
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, mfhd: mfhd_id, source: source, user_barcode: user_barcode) }
  end

  factory :aeon_rbsc_enumerated, class: 'Requests::Request' do
    system_id 6_794_966
    mfhd_id '6720550'
    source 'pulsearch'
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, mfhd: mfhd_id, source: source, user_barcode: user_barcode) }
  end

  factory :aeon_marquand, class: 'Requests::Request' do
    system_id 7_915_334
    mfhd_id '7697569'
    source 'pulsearch'
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, mfhd: mfhd_id, source: source, user_barcode: user_barcode) }
  end

  factory :aeon_mudd, class: 'Requests::Request' do
    system_id 6_023_439
    mfhd_id '6080541'
    source 'pulsearch'
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, mfhd: mfhd_id, source: source, user_barcode: user_barcode) }
  end

  factory :aeon_mudd_barcode_patron, class: 'Requests::Request' do
    system_id 6_023_439
    mfhd_id '6080541'
    source 'pulsearch'
    user { FactoryGirl.build(:valid_barcode_patron) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, mfhd: mfhd_id, source: source, user_barcode: user_barcode) }
  end

  factory :aeon_mudd_unauthenticated_patron, class: 'Requests::Request' do
    system_id 6_023_439
    mfhd_id '6080541'
    source 'pulsearch'
    user { FactoryGirl.build(:unauthenticated_patron) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, mfhd: mfhd_id, source: source, user_barcode: user_barcode) }
  end

  factory :missing_item, class: 'Requests::Request' do
    system_id 1_389_121
    mfhd_id '1594697'
    source 'pulsearch'
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, mfhd: mfhd_id, source: source, user_barcode: user_barcode) }
  end

  factory :request_with_items_charged, class: 'Requests::Request' do
    system_id 1_389_121
    mfhd_id '1594698'
    source 'pulsearch'
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, mfhd: mfhd_id, source: source, user_barcode: user_barcode) }
  end

  factory :request_with_items_charged_barcode_patron, class: 'Requests::Request' do
    system_id 1_389_121
    mfhd_id '1594698'
    source 'pulsearch'
    user { FactoryGirl.build(:valid_barcode_patron) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, mfhd: mfhd_id, source: source, user_barcode: user_barcode) }
  end

  factory :request_with_items_charged_unauthenticated_patron, class: 'Requests::Request' do
    system_id 1_389_121
    mfhd_id '1594698'
    source 'pulsearch'
    user { FactoryGirl.build(:unauthenticated_patron) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, mfhd: mfhd_id, source: source, user_barcode: user_barcode) }
  end

  factory :request_serial_with_item_on_hold, class: 'Requests::Request' do
    system_id 4_563_519
    mfhd_id '4808685'
    source 'pulsearch'
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, mfhd: mfhd_id, source: source, user_barcode: user_barcode) }
  end

  factory :request_aeon_holding_volume_note, class: 'Requests::Request' do
    system_id 616_086
    source 'pulsearch'
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, source: source, user_barcode: user_barcode) }
  end

  factory :request_scsb_cu, class: 'Requests::Request' do
    system_id 'SCSB-5235419'
    source 'pulsearch'
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, source: source, user_barcode: user_barcode) }
  end

  # use_statement: "In Library Use"
  factory :request_scsb_ar, class: 'Requests::Request' do
    system_id 'SCSB-2650865'
    source 'pulsearch'
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, source: source, user_barcode: user_barcode) }
  end

  factory :request_scsb_mr, class: 'Requests::Request' do
    system_id 'SCSB-2901229'
    source 'pulsearch'
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, source: source, user_barcode: user_barcode) }
  end

  factory :mfhd_with_no_circ_and_circ_item, class: 'Requests::Request' do
    system_id 257_717
    mfhd_id '282033'
    source 'pulsearch'
    user { FactoryGirl.build(:user) }
    user_barcode '111222333'
    initialize_with { new(system_id: system_id, user: user, mfhd: mfhd_id, source: source, user_barcode: user_barcode) }
  end
end
