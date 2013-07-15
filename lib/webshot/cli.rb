require 'thor'
require 'net/http'
require 'rexml/document'
require 'selenium-webdriver'
require 'colorize'

module WebShot
  class App < Thor
    BROWSERS = [:chrome, :firefox]
    BREAKPOINTS = {
      "320x480" => {
        "width" => 320,
        "height" => 480
      },
      "480x320" => {
        "width" => 480,
        "height" => 320
      },
      "768x1024" => {
        "width" => 768,
        "height" => 1024
      },
      "1024x768" => {
        "width" => 1024,
        "height" => 768
      }
    }

    desc "capture", "Captures screenshots of a page or set of pages"
    option :url, aliases: "-u"
    option :sitemap, aliases: "-s"
    option :chrome, :type => :boolean, aliases: "-c"
    option :firefox, :type => :boolean, aliases: "-f"
    option :breakpoint, aliases: "-b"
    option :output, aliases: "-o"
    option :diff, :type => :boolean, aliases: "-d"
    def capture
      if options[:sitemap] then
        urls = getSitemap options[:sitemap]
      else
        urls = ["#{options[:url]}"]
      end

      if options[:chrome]
        getScreenshots urls, :chrome
      elsif options[:firefox]
        getScreenshots urls, :firefox
      else
        BROWSERS.each {|browser| getScreenshots urls, browser.to_sym}
      end

      puts "All done!".green
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
      base_dir = options[:output] ? options[:output] : "screenshots"
      new_version = Time.now.to_i
      last_version = getLastVersion base_dir

      if options[:breakpoint]
        breakpoints = ["#{options[:breakpoint]}"]
      else
        breakpoints = BREAKPOINTS
      end

      breakpoints.each do |name, breakpoint|
        directory = "#{base_dir}/#{new_version}/#{browser}/#{name}/"
        last_directory = "#{last_version}/#{browser}/#{name}/"

        unless File.directory? directory
          FileUtils.mkdir_p directory
        end

        if options[:diff]
          unless File.directory? "diffs/"
            FileUtils.mkdir_p "diffs/"
          end
        end

        puts "Capturing #{name} breakpoint".yellow

        urls.each do |url|
          puts "Saving screenshot of #{url}".green

          driver.manage.window.resize_to(breakpoint["width"], breakpoint["height"])
          driver.get url

          full_path = directory + url.gsub(/http:\/\/|https:\/\//, "")
          last_slash = full_path.rindex("/")
          dirs = full_path[0..last_slash]
          filename = full_path.gsub(dirs, "") + "-#{name}.png"

          unless File.directory? dirs
            FileUtils.mkdir_p dirs
          end

          sleep 3

          driver.save_screenshot dirs + filename

          puts "Saved #{filename}".green

          if options[:diff]
            last_file = url.gsub(/http:\/\/|https:\/\//, "") + "-#{name}.png"
            new_file = full_path + "-#{name}.png"

            getDiff last_version, new_version, last_file, new_file, browser, name, url.gsub(/http:\/\/|https:\/\//, "")
          end

          num_urls += 1
        end # urls
      end # breakpoints
      
      driver.quit
      end_time = Time.now

      puts "Rendered #{num_urls} urls in #{browser.capitalize} in #{end_time - start_time} seconds.".green
    end

    def getLastVersion base_dir
      Dir.glob("#{base_dir}/*").max
    end

    def getDiff last_version, new_version, last_file, new_file, browser, breakpoint, url
      puts "Checking for #{last_file}...".yellow
      if File.exist?(last_file)
        diff_dir = "diffs/#{browser}/#{breakpoint}/#{url}"
        diff_file = "#{last_version}-vs-#{new_version}.png"

        puts "Comparing #{new_file} with older version: #{last_file}".green
        system "compare #{last_file} #{new_file} #{diff_dir}/#{diff_file}"
        puts "Diff #{diff_dir}/#{diff_file} saved.".green
      else
        puts "Not found.".yellow
      end
    end
  end
end