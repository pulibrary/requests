require 'spec_helper'

describe Requests::Request do

  describe "Voyager Source Request Options" do

    let (:request)  { FactoryGirl.create(:request) }

    context "Does Not Have Item Records" do
      it "Online Resource" do
      end

      it "Is located at an Open Access Location" do
      end

      it "Is located at Restricted Access location" do
      end

      it "Is located at the Annex" do
      end

      it "Is located at Restricted Access, Always Requestable location" do
      end

    end

    context "Has Item Records" do

      context "Available Resource" do

        it "Is in a circulating location" do
        end  

        it "Is in a non-circulating location" do
        end

      end

      context "Unavailable Resource" do
        it "Is in a circulating location" do
        end  

        it "Is in a non-circulating location" do
        end
      end

    end

  end

  describe "Non-Voyager Source Request Options" do
    
    let (:request)  { FactoryGirl.create(:request) }

    context "Online Item" do
    end

    context "Physical Item" do
    end

  end
end