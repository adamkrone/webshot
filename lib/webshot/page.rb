require 'colorize'

require 'webshot/diff'

module Webshot
  class Page
    attr_reader :url, :stripped_url, :path, :version, :browser, :breakpoint

    def initialize(url, driver, config)
      @url = url
      @stripped_url = url.gsub(/http:\/\/|https:\/\//, "")
      @driver = driver
      @config = config
      @version = @config.settings["version"]
      @browser = @config.settings["current_browser"]
      @breakpoint = @config.settings["current_breakpoint"]
    end

    def path
      url = @config.settings["current_breakpoint_dir"] + @stripped_url
      last_slash = url.rindex("/")
      url[0..last_slash]
    end

    def filename
      @stripped_url.split("/")[-1] + ".png"
    end

    def screenshot
      path + filename
    end

    def last_screenshot(version)
      screenshot.gsub(@version.to_s, version.to_s)
    end

    def mkdirs
      unless File.directory? path
        FileUtils.mkdir_p path
      end
    end

    def save
      mkdirs
      @driver.get @url
      @driver.save_screenshot(screenshot)
      @config.log(:info, :green, "Saved to #{screenshot}")
      save_diff
    end

    def save_diff
      if @config.settings["diff"]
        current_diff = Webshot::Diff.new(self, @config)
        current_diff.save
      end
    end
  end
end
