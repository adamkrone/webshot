require 'thor'
require 'net/http'
require 'rexml/document'
require 'selenium-webdriver'
require 'colorize'

require 'webshot/page'
require 'webshot/diff'
require 'webshot/config'

module Webshot
  class CLI < Thor
    START_TIME = Time.now

    desc "capture", "Captures screenshots of a page or pages"
    option :url, :aliases => "-u"
    option :sitemap, :aliases => "-s"
    option :browsers, :type => :array
    option :breakpoints, :type => :array
    option :output, :aliases => "-o"
    option :diff, :type => :boolean, :aliases => "-d"
    option :wait, :type => :numeric, :aliases => "-w"
    option :verbose, :aliases => "-v"
    def capture
      start_time = START_TIME.to_i
      @config = Webshot::Config.new
      @total_urls = 0

      options.each do |option, value|
        @config.settings[option.to_s] = value
      end

      if options.count == 0 && @config.settings == nil
        puts "You must provide a --url, or configure a Shotfile using 'webshot init'."
	exit
      end

      if @config.settings["sitemap"]
        urls = read_sitemap @config.settings["url"]
      else
        urls = ["#{@config.settings['url']}"]
      end

      @config.settings["browsers"].each do |browser|
        puts "Using #{browser.capitalize}...".yellow if @config.settings["verbose"]
        get_screenshots(urls, browser.to_sym)
      end

      end_time = Time.now.to_i
      puts "Total: #{@total_urls} urls in #{end_time - start_time} seconds.".green
    end

    desc "init", "Initialize project with Shotfile"
    option :force, :type => :boolean, :aliases => "-f"
    def init
      webshot = Webshot::Config.new
      webshot.create_config(options[:force])
    end

    private

    def read_sitemap(sitemap_url)
      url = sitemap_url
      begin
        request = Net::HTTP.get_response(URI.parse(url)).body
      rescue URI::InvalidURIError
        puts "I don't know what to do with '#{url}'..."
        puts "Please use a valid URL."
        exit
      end
      sitemap = REXML::Document.new request

      urls = []
      sitemap.elements.each "urlset/url/loc" do |url|
        urls << url.text
      end

      return urls
    end

    def get_screenshots(urls, browser)
      num_urls = 0
      current_run_start = Time.now
      driver = Selenium::WebDriver.for browser
      base_dir = options[:output] ? options[:output] : "screenshots"
      current_version = START_TIME.to_i
      last_version = get_last_version base_dir

      @config.settings["breakpoints"].each do |breakpoint|
        directory = "#{base_dir}/#{current_version}/#{browser}/#{breakpoint['name']}/"

        unless File.directory? directory
          FileUtils.mkdir_p directory
        end

        if options[:diff]
          unless File.directory? "diffs/"
            FileUtils.mkdir_p "diffs/"
          end
        end

        puts "Capturing #{breakpoint['name']} breakpoint".yellow if @config.settings["verbose"]

        urls.each do |url|
          puts "\nSaving screenshot of #{url}..." if @config.settings["verbose"]

          driver.manage.window.resize_to(breakpoint["width"], breakpoint["height"])
          driver.get url

          current_page = Webshot::Page.new(url, current_version, directory, browser, breakpoint["name"])

          sleep options[:wait] || 0

          current_file = current_page.screenshot

          current_page.save(driver)

          puts "Saved to #{current_file}".green if @config.settings["verbose"]

          if @config.settings["diff"]
            current_diff = Webshot::Diff.new(last_version, current_version, current_page, @config.settings["verbose"])
            current_diff.get_image_diff
          end

          num_urls += 1
        end
      end
      
      driver.quit
      end_time = Time.now
      @total_urls += num_urls

      puts "Rendered #{num_urls} urls in #{browser.to_s.capitalize} in #{end_time - current_run_start} seconds.".green
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