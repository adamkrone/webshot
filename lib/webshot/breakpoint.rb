require 'colorize'

require 'webshot/page'

module Webshot
  class Breakpoint
    attr_reader :name, :urls

    def initialize(name, driver, config)
      @name = name
      @driver = driver
      @config = config
      @urls = @config.settings["urls"]
    end

    def width
      @name.split("x")[0]
    end

    def height
      @name.split("x")[1]
    end

    def capture
      setup

      urls.each do |url|
        save_screenshot(url)
      end
    end

    private

    def setup
      @config.settings["current_breakpoint"] = @name
      @directory = "#{@config.settings["current_browser_dir"]}/#{@name}/"
      @config.settings["current_breakpoint_dir"] = @directory

      create_directory
      resize_driver

      @config.log(:info, :yellow, "Capturing #{@name} breakpoint\n")
    end

    def create_directory
      unless File.directory? @directory
        FileUtils.mkdir_p @directory
      end
    end

    def resize_driver
      @driver.manage.window.resize_to(width, height)
    end

    def save_screenshot(url)
      @config.log(:info, :white, "Saving screenshot of #{url}...")

      page = Webshot::Page.new(url, @driver, @config)
      sleep @config.settings[:wait] || 0

      page.save
    end
  end
end
