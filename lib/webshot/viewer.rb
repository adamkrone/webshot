module Webshot
  class Viewer
    attr_accessor :versions, :browsers, :pages, :screenshots, :diffs

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

    def browsers(version = current_version)
      browser_path = "#{@screenshot_dir}/#{version}/"

      Dir.glob("#{browser_path}*").map do |browser|
        browser.gsub(browser_path, "")
      end
    end

    def breakpoints(version = current_version)
      browser = browsers(version)[0]
      breakpoint_path = "#{@screenshot_dir}/#{version}/#{browser}/"

      Dir.glob("#{breakpoint_path}*").map do |breakpoint|
        breakpoint.gsub(breakpoint_path, "")
      end
    end

    def pages(version = current_version)
      browser = browsers(version)[0]
      pages_path = "#{@screenshot_dir}/#{version}/#{browser}/*/"

      pages = Dir.glob("#{pages_path}**/*.png").map do |page|
        page = page.gsub(/#{@screenshot_dir}\/#{version}\//, "")
        page = page.split("/").drop(2).join("/")
        page.gsub(/\.png/, "")
      end

      pages.uniq
    end

    def screenshots(options = {})
      version = options[:version] ? "#{options[:version]}" : "*"
      browser = options[:browser] ? "#{options[:browser]}" : "*"
      breakpoint = options[:breakpoint] ? "#{options[:breakpoint]}" : "*"
      page = options[:page] ? "#{options[:page]}.png" : "**/*.png"
      screenshots = "#{@screenshot_dir}/#{version}/#{browser}/#{breakpoint}/#{page}"

      Dir.glob(screenshots)
    end

    def diffs(options = {})
      options[:browser] = "{#{options[:browser].join(",")}}" if options[:browser].kind_of?(Array)
      options[:breakpoint] = "{#{options[:breakpoint].join(",")}}" if options[:breakpoint].kind_of?(Array)

      browser = options[:browser] ? "#{options[:browser]}/" : "*/"
      breakpoint = options[:breakpoint] ? "#{options[:breakpoint]}/" : "*/"
      page = options[:page] ? "#{options[:page]}/" : "**/"

      version2 = options[:version2] || current_version
      version1 = options[:version1] || previous_version
      diffs = "#{@diff_dir}/#{browser}#{breakpoint}#{page}#{version1}-vs-#{version2}.png"

      Dir.glob(diffs)
    end
  end
end
