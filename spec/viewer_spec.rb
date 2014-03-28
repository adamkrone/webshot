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
      pending "Need to setup a default set of testing screenshots"
    end
  end

  describe "#previous_version" do
    it "should return the previous version" do
      pending "Need to setup a default set of testing screenshots"
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
