module Webshot
  class Page
    attr_reader :url, :path, :filename, :browser, :breakpoint, :screenshot

    def initialize(url, current_version, directory, browser, breakpoint)
      @url = url.gsub(/http:\/\/|https:\/\//, "")
      @current_version = current_version
      @path = get_path(directory)
      @browser = browser
      @breakpoint = breakpoint
      @filename = get_filename
      @screenshot = @path + @filename
    end

    def get_path(directory)
      url = directory + @url
      last_slash = url.rindex("/")
      url[0..last_slash]
    end

    def get_filename
      @url.split("/")[-1] + ".png"
    end

    def mkdirs
      unless File.directory? @path
        FileUtils.mkdir_p @path
      end
    end

    def save(driver)
      mkdirs
      driver.save_screenshot(@screenshot)
    end

    def old_version(version)
      @screenshot.gsub(@current_version.to_s, version.to_s)
    end
  end
end
