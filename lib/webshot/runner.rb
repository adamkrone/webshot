require 'selenium-webdriver'

require 'webshot/browser'

module Webshot
  class Runner
    attr_reader :base_dir, :version, :urls, :browsers, :breakpoints, :config,
                :driver, :old_version, :current_browser, :current_breakpoint,
                :current_page, :urls_captured, :browser_urls

    def initialize(config)
      @config = config
      @version = @config.settings["version"]
      @browsers = @config.settings["browsers"]
      @breakpoints = @config.settings["breakpoints"]
      @urls = @config.settings["urls"]
    end

    def start
      start_time = @version.to_i
      begin
        @browsers.each do |name|
          browser = Webshot::Browser.new(name, @config)
          browser.capture
        end
      rescue Selenium::WebDriver::Error::UnknownError
        puts "Sorry, we encountered an error..."
        exit
      end

      end_time = Time.now.to_i
      puts "Total: captured #{@urls.length * @browsers.length * @breakpoints.length} urls in #{end_time - start_time} seconds.".green
    end
  end
end
