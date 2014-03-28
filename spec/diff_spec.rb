require 'spec_helper'

describe Webshot::Diff do
  let(:diff) { Webshot::Diff.new }

  describe "#get_image_diff" do
    it "should save a diff" do
      pending "Need to setup a default set of testing screenshots"
    end

    describe "when there is no difference" do
      it "should return a message" do
        pending "Need to setup a default set of testing screenshots"
      end
    end

    describe "when the screenshot doesn't exist" do
      it "should return an error" do
        pending "Need to setup a default set of testing screenshots"
      end
    end
  end
end
