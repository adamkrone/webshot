require 'selenium-webdriver'

require 'webshot/page'
require 'webshot/diff'

module Webshot
  class Runner
    attr_reader :version, :urls, :browsers, :breakpoints, :config

    def initialize(args)
      @config = args[:config]
      @version = args[:version]
      @urls = args[:urls]
      @browsers = @config.settings["browsers"]
      @breakpoints = @config.settings["breakpoints"]
      @urls_captured = 0
    end

    def start
      start_time = @version
      begin
          @browsers.each do |browser|
            capture_browser(browser)
          end
      rescue Selenium::WebDriver::Error::UnknownError => e
        puts "Sorry, we encountered an error..."
        if @config.settings["verbose"]
          puts e.message
          puts e.backtrace
        end
        exit
      end

      end_time = Time.now.to_i
      puts "Total: captured #{@urls_captured} urls in #{end_time - start_time} seconds.".green
    end

    private

    def capture_browser(browser)
      puts "\nUsing #{browser.capitalize}...".yellow if @config.settings["verbose"]

      current_run_start = Time.now
      driver = Selenium::WebDriver.for browser
      base_dir = @config.settings["output"] ? @config.settings["output"] : "."
      current_version = START_TIME.to_i
      last_version = get_last_version "#{base_dir}/screenshots"

      @config.settings["breakpoints"].each do |breakpoint|
        capture_breakpoint(breakpoint)
      end

      driver.quit
      end_time = Time.now
      @urls_captured+= num_urls

      puts "\nCaptured #{num_urls} urls in #{browser.to_s.capitalize} in #{end_time - current_run_start} seconds.".green
    end

    def capture_breakpoint(breakpoint)
      directory = "#{base_dir}/screenshots/#{current_version}/#{browser}/#{breakpoint['name']}/"

      unless File.directory? directory
        FileUtils.mkdir_p directory
      end

      if options[:diff]
        unless File.directory? "diffs/"
          FileUtils.mkdir_p "diffs/"
        end
      end

      puts "\nCapturing #{breakpoint['name']} breakpoint".yellow if @config.settings["verbose"]

      urls.each do |url|
        puts "\nSaving screenshot of #{url}..." if @config.settings["verbose"]

        driver.manage.window.resize_to(breakpoint["width"], breakpoint["height"])
        driver.get url

        current_page = Webshot::Page.new(:url => url, :version => current_version, :directory => directory, :browser => browser, :breakpoint => breakpoint["name"])

        sleep options[:wait] || 0

        current_file = current_page.screenshot

        current_page.save(driver)

        puts "Saved to #{current_file}".green if @config.settings["verbose"]

        if @config.settings["diff"]
          current_diff = Webshot::Diff.new(:base_dir => base_dir, :old_version => last_version, :current_version => current_version, :page => current_page, :verbose => @config.settings["verbose"])
          current_diff.get_image_diff
        end

        num_urls += 1
      end
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
