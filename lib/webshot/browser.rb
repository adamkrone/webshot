require 'webshot/breakpoint'

module Webshot
  class Browser
    attr_reader :name, :breakpoints, :urls, :start_time, :end_time

    def initialize(name, config)
      @name = name
      @config = config
      @breakpoints = @config.settings["breakpoints"]
      @urls = @config.settings["urls"]
    end

    def capture
      setup

      @breakpoints.each do |name|
        breakpoint = Webshot::Breakpoint.new(name, @driver, @config)
        breakpoint.capture
      end

      teardown
    end

    def setup
      puts "\nUsing #{@name.capitalize}...".yellow if @config.settings["verbose"]

      @config.settings["current_browser"] = @name
      @config.settings["current_browser_dir"] = "#{@config.settings["base_dir"]}/screenshots/#{@config.settings["version"]}/#{@config.settings["current_browser"]}"
      @start_time = Time.now
      @driver = Selenium::WebDriver.for @name.to_sym
    end

    def teardown
      @driver.quit
      @end_time = Time.now

      puts "\nCaptured #{@urls.length * @breakpoints.length} urls in #{@name.capitalize} in #{@end_time - @start_time} seconds.".green
    end
  end
end
