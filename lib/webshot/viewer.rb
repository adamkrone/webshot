module Webshot
  class Viewer
    attr_accessor :versions, :browsers, :screenshots, :diffs

    def initialize(options = {:screenshot_dir => "./screenshots",
                              :diff_dir => "./diffs"})
      @screenshot_dir = options[:screenshot_dir]
      @diff_dir = options[:diff_dir]
    end

    def versions
      Dir.glob("#{@screenshot_dir}/*").map do |version|
        version.gsub("#{@screenshot_dir}/", "")
      end
    end

    def current_version
      versions[-1]
    end

    def previous_version
      versions[-2]
    end

    def browsers(version)
      browser_path = "#{@screenshot_dir}/#{version}/"

      Dir.glob("#{browser_path}*").map do |browser|
        browser.gsub(browser_path, "")
      end
    end

    def breakpoints(version)
      browser = browsers(version)[0]
      breakpoint_path = "#{@screenshot_dir}/#{version}/#{browser}/"

      Dir.glob("#{breakpoint_path}*").map do |breakpoint|
        breakpoint.gsub(breakpoint_path, "")
      end
    end

    def screenshots(version, options = {})
      browser = options[:browser] ? "#{options[:browser]}/" : ""
      breakpoint = options[:breakpoint] ? "#{options[:breakpoint]}/" : ""
      screenshots = "#{@screenshot_dir}/#{version}/#{browser}#{breakpoint}**/*.png"

      Dir.glob(screenshots)
    end

    def diffs(version1, version2, options = {})
      options[:browser] = "{#{options[:browser].join(",")}}" if options[:browser].kind_of?(Array)
      options[:breakpoint] = "{#{options[:breakpoint].join(",")}}" if options[:breakpoint].kind_of?(Array)

      browser = options[:browser] ? "#{options[:browser]}/" : "*/"
      breakpoint = options[:breakpoint] ? "#{options[:breakpoint]}/" : "*/"
      diffs = "#{@diff_dir}/#{browser}#{breakpoint}**/#{version1}-vs-#{version2}.png"

      Dir.glob(diffs)
    end
  end
end
