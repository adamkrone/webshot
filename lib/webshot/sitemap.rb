require 'net/http'
require 'rexml/document'

module Webshot
  class Sitemap
    attr_reader :sitemap_url, :urls

    def initialize(sitemap_url)
      @sitemap_url = sitemap_url
      @urls = parse_urls
    end

    def parse_urls
      begin
        url = URI.parse(@sitemap_url)
        request = Net::HTTP.get_response(url).body
      rescue URI::InvalidURIError, TypeError, NoMethodError
        return nil
      end

      sitemap = REXML::Document.new request
      urls = []

      sitemap.elements.each "urlset/url/loc" do |url|
        urls << url.text
      end

      return urls
    end
  end
end
