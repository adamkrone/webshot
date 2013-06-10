require 'thor'
require 'net/http'
require 'rexml/document'
require 'selenium-webdriver'

class App < Thor
	BROWSERS = [:chrome, :firefox]

	desc "capture", "Captures screenshots of a page or set of pages"
	option :page, aliases: "-p"
	option :sitemap, aliases: "-s"
	option :chrome, :type => :boolean
	option :firefox, :type => :boolean
	option :output, aliases: "-o"
	def capture
		if options[:sitemap] then
			urls = getSitemap options[:sitemap]
		else
			urls = ["#{options[:page]}"]
		end

		if options[:chrome]
			puts options[:chrome]
			getScreenshots urls, :chrome
		elsif options[:firefox]
			getScreenshots urls, :firefox
		else
			BROWSERS.each {|browser| getScreenshots urls, browser.to_sym}
		end
	end

	private

	def getSitemap sitemap_url
		url = sitemap_url
		request = Net::HTTP.get_response(URI.parse(url)).body
		sitemap = REXML::Document.new request

		urls = []
		sitemap.elements.each "urlset/url/loc" do |url|
			urls << url.text
		end

		return urls
	end

	def getScreenshots urls, browser
		num_urls = 0
		start_time = Time.now
		driver = Selenium::WebDriver.for browser

		if options[:output]
			directory = "#{options[:output]}/#{browser}/"
		else
			directory = "screenshots/#{browser}/"
		end

		unless File.directory? directory
			FileUtils.mkdir_p directory
		end

		urls.each do |url|
			puts "Saving screenshot of #{url}"

			driver.get url
			driver.manage.window.resize_to(1024, 768)

			full_path = directory + url.gsub(/http:\/\/|https:\/\//, "")
			last_slash = full_path.rindex("/")
			dirs = full_path[0..last_slash]
			filename = full_path.gsub(dirs, "") + ".png"

			unless File.directory? dirs
				FileUtils.mkdir_p dirs
			end

			sleep 3

			driver.save_screenshot dirs + filename

			puts "Saved #{filename}"
			
			num_urls += 1
		end
		
		driver.quit
		end_time = Time.now

		puts "Rendered #{num_urls} urls in #{browser.capitalize} in #{end_time - start_time} seconds."
		puts "All done!"
	end
end

App.start ARGV
