require 'spec_helper'

describe Webshot::Breakpoint do
  let(:config) { double("config", :settings => {}) }
  let(:driver) { double("driver") }
  let(:breakpoint) { Webshot::Breakpoint.new("1024x768", driver, config) }

  it "should have a name" do
    expect(breakpoint.name).to eq("1024x768")
  end

  it "should have a width" do
    expect(breakpoint.width).to eq("1024")
  end

  it "should have a height" do
    expect(breakpoint.height).to eq("768")
  end
end
