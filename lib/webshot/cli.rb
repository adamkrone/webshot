require 'thor'
require 'net/http'
require 'rexml/document'
require 'selenium-webdriver'
require 'colorize'

require 'webshot/page'
require 'webshot/diff'

module Webshot
  class CLI < Thor
    START_TIME = Time.now
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

    desc "capture", "Captures screenshots of a page or pages"
    option :url, :aliases => "-u"
    option :sitemap, :aliases => "-s"
    option :chrome, :type => :boolean, :aliases => "-c"
    option :firefox, :type => :boolean, :aliases => "-f"
    option :breakpoint, :aliases => "-b"
    option :output, :aliases => "-o"
    option :diff, :type => :boolean, :aliases => "-d"
    option :wait, :type => :numeric, :aliases => "-w"
    option :verbose, :aliases => "-v"
    def capture
      if options[:sitemap]
        urls = get_sitemap options[:sitemap]
      else
        urls = ["#{options[:url]}"]
      end

      if options[:chrome]
        get_screenshots urls, :chrome
      elsif options[:firefox]
        get_screenshots urls, :firefox
      else
        BROWSERS.each {|browser| get_screenshots(urls, browser.to_sym)}
      end
    end

    private

    def get_sitemap(sitemap_url)
      url = sitemap_url
      request = Net::HTTP.get_response(URI.parse(url)).body
      sitemap = REXML::Document.new request

      urls = []
      sitemap.elements.each "urlset/url/loc" do |url|
        urls << url.text
      end

      return urls
    end

    def get_screenshots(urls, browser)
      num_urls = 0
      start_time = START_TIME
      driver = Selenium::WebDriver.for browser
      base_dir = options[:output] ? options[:output] : "screenshots"
      current_version = START_TIME.to_i
      last_version = get_last_version base_dir

      if options[:breakpoint]
        breakpoints = ["#{options[:breakpoint]}"]
      else
        breakpoints = BREAKPOINTS
      end

      breakpoints.each do |breakpoint_name, breakpoint|
        directory = "#{base_dir}/#{current_version}/#{browser}/#{breakpoint_name}/"

        unless File.directory? directory
          FileUtils.mkdir_p directory
        end

        if options[:diff]
          unless File.directory? "diffs/"
            FileUtils.mkdir_p "diffs/"
          end
        end

        puts "Capturing #{breakpoint_name} breakpoint".yellow if options[:verbose]

        urls.each do |url|
          puts "Saving screenshot of #{url}".green if options[:verbose]

          driver.manage.window.resize_to(breakpoint["width"], breakpoint["height"])
          driver.get url

          current_page = Webshot::Page.new(url, current_version, directory, browser, breakpoint_name)

          sleep options[:wait] || 0

          current_file = current_page.screenshot

          current_page.save(driver)

          puts "Saved to #{current_file}".green if options[:verbose]

          if options[:diff]
            current_diff = Webshot::Diff.new(last_version, current_version, current_page)
            current_diff.get_image_diff
          end

          num_urls += 1
        end
      end
      
      driver.quit
      end_time = Time.now

      puts "Rendered #{num_urls} urls in #{browser.to_s.capitalize} in #{end_time - start_time} seconds.".green
    end

    def get_last_version(base_dir)
      last_dir = Dir.glob("#{base_dir}/*").max
      if last_dir
        last_dir.gsub(base_dir + "/", "")
      else
        nil
      end
    end
  end
end