require 'spec_helper'

RSpec.describe Requests::ApplicationHelper do
  let(:isbns) {
      [
        '9780544343757',
        '179758877'
      ]
    }
  let(:isbn_string_helper) { described_class.isbn_string(isbns) }

  describe "#pickup_choices" do
    let(:on_order_params) {
      {
        item: {

        },
        location: {

        }
      }
    }
    let(:in_process_params) {
      {
        item: {

        },
        location: {

        }
      }
    }

    let(:standard_params) {
      {
        item: {

        },
        location: {

        }
      }
    }

    let(:requestable_on_order) { Requests::Requestable(on_order_params) }
    let(:requestable_in_process) { Requests::Requestable(in_process_params) }
    let(:requestable_default_behavior) { Requests::Requestable(standard_params) }
    let(:default_pickups) { ['Firestone Library'] }

    context "When an item is on order" do
      xit "Shows the default pickups when on order" do
      end
    end

    context "When an item is in process" do
      xit "Shows the default pickups when in process" do
      end
    end

    context "When an item is not in process or on order" do
      xit "Shows the pickups selected for the holding location" do
      end
    end
  end

  describe '#isbn_string' do
    xit 'returns a list of formatted isbns' do
      expect(isbn_string_helper).to eq('9780544343757,179758877')
    end
  end
end
