require 'spec_helper'

RSpec.describe ApplicationHelper do

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
end