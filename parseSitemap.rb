require 'net/http'
require 'rexml/document'

url = ARGV[0]

request = Net::HTTP.get_response(URI.parse(url)).body

sitemap = REXML::Document.new request
i = 0
startTime = Time.now

sitemap.elements.each("urlset/url/loc") do |url|
	puts "Saving screenshot of #{url.text}"
	system "phantomjs desktop.js #{url.text}"
	system "phantomjs mobile-portrait.js #{url.text}"
	system "phantomjs mobile-landscape.js #{url.text}"
	system "phantomjs tablet-portrait.js #{url.text}"

	i += 1
end

endTime = Time.now

puts "Rendered #{i} urls in #{endTime - startTime} seconds."
puts "All done!"