require 'spec_helper'

describe Webshot::Sitemap do
  describe "#parse_urls" do
    describe "when given an invalid URL" do
      it "should return false" do
        sitemap = Webshot::Sitemap.new("invalid_url") 
        
        expect(sitemap.urls).to be_nil
      end
    end
  end
end
