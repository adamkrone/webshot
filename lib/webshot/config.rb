require 'yaml'

module Webshot
  class Config
    attr_accessor :settings

    def initialize(options=nil)
      @settings = check_for_config
      merge_options(options) if options
      @settings["base_dir"] = @settings["output"] ? @settings["output"] : "."
      @settings["last_version"] = last_version
    end

    def check_for_config
      if File.exist? "Shotfile"
        YAML.load(File.read "Shotfile")
      else
        {}
      end
    end

    def merge_options(options)
      options.each do |option, value|
        @settings[option.to_s] = value
      end
    end

    def last_version
      screenshots_dir = "#{@settings["base_dir"]}/screenshots"
      last_dir = Dir.glob("#{screenshots_dir}/*").max
      if last_dir
        last_dir.gsub(screenshots_dir + "/", "")
      else
        nil
      end
    end

    def shotfile_exists?
      File.exist?("Shotfile")
    end

    def create_config(force=false)
      if shotfile_exists? and !force
        puts "You already have a Shotfile."
        return false
      end

      puts "Overwriting Shotfile..." if force

      File.open("Shotfile", "w") do |f|
        config = {
          "urls" => ["http://example.com"],
          "browsers" => ["firefox"],
          "breakpoints" => ["320x480", "480x320", "768x1024", "1024x768"],
          "diff" => true,
          "verbose" => false
        }

        f.write config.to_yaml
      end
    end
  end
end
