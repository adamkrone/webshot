require 'spec_helper'

describe Webshot::Viewer do
  let(:viewer) { Webshot::Viewer.new }

  describe "#versions" do
    it "should return an array of versions" do
      versions = viewer.versions

      expect(versions).to be_kind_of(Array)
    end
  end

  describe "#current_version" do
    it "should return the current version" do
      viewer.should_receive(:versions).and_return(["123456789", "987654321"])

      expect(viewer.current_version).to eq("987654321")
    end
  end

  describe "#previous_version" do
    it "should return the previous version" do
      viewer.should_receive(:versions).and_return(["123456789", "987654321"])

      expect(viewer.previous_version).to eq("123456789")
    end
  end

  describe "#browsers" do
    it "should return an array of browsers" do
      browsers = viewer.browsers

      expect(browsers).to be_kind_of(Array)
    end
  end

  describe "#breakpoints" do
    it "should return an array of breakpoints" do
      breakpoints = viewer.breakpoints

      expect(breakpoints).to be_kind_of(Array)
    end
  end

  describe "#pages" do
    it "should return an array of pages" do
      pages = viewer.pages

      expect(pages).to be_kind_of(Array)
    end
  end

  describe "#screenshots" do
    it "should return an array of screenshots" do
      screenshots = viewer.screenshots

      expect(screenshots).to be_kind_of(Array)
    end
  end


  describe "#diffs" do
    it "should return an array of diffs" do
      diffs = viewer.diffs

      expect(diffs).to be_kind_of(Array)
    end
  end
end
