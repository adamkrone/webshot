require 'net/http'
require 'rexml/document'
require 'selenium-webdriver'

url = ARGV[0]

request = Net::HTTP.get_response(URI.parse(url)).body

sitemap = REXML::Document.new request


def getScreenshots sitemap
	i = 0
	startTime = Time.now
	driver = Selenium::WebDriver.for :firefox

	unless File.directory? "screenshots"
		FileUtils.mkdir_p "screenshots"
	end

	sitemap.elements.each "urlset/url/loc" do |url|
		puts "Saving screenshot of #{url.text}"

		driver.get url.text
		driver.manage.window.resize_to(1024, 768)

		full_path = "screenshots/" + url.text.gsub(/http:\/\/|https:\/\//, "")
		last_slash = full_path.rindex("/")
		dirs = full_path[0..last_slash]
		filename = full_path.gsub(dirs, "") + ".png"

		unless File.directory? dirs
			FileUtils.mkdir_p dirs
		end

		sleep 3

		driver.save_screenshot dirs + filename

		puts "Saved #{filename}"
		
		i += 1
	end
	
	driver.quit
	endTime = Time.now

	puts "Rendered #{i} urls in #{endTime - startTime} seconds."
	puts "All done!"
end

getScreenshots sitemap