module Webshot
  class Page
    attr_reader :url, :path, :filename, :browser, :breakpoint, :screenshot

    def initialize(args)
      @url = args[:url].gsub(/http:\/\/|https:\/\//, "")
      @version = args[:version]
      @path = get_path(args[:directory])
      @browser = args[:browser]
      @breakpoint = args[:breakpoint]
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
      @screenshot.gsub(@version.to_s, version.to_s)
    end
  end
end
