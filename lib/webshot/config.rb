require 'yaml'
require 'logger'

module Webshot
  class Config
    attr_accessor :settings

    def initialize(options=nil)
      @settings = check_for_config
      @settings["version"] = Time.now.to_i
      merge_options(options) if options
      @settings["base_dir"] = @settings["output"] ? @settings["output"] : "."
      @settings["last_version"] = last_version
      configure_logger
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

    def configure_logger
      if @settings["log_dir"]
        @settings["logger"] = Logger.new(log_file)
        @settings["logger"].level = log_level
      end
    end

    def log_file
      FileUtils.mkdir_p(@settings["log_dir"])
      return File.open("#{@settings["log_dir"]}/#{@settings["version"]}.log",
                       File::WRONLY | File::APPEND | File::CREAT)
    end

    def log_level
      if @settings["log_level"]
        case @settings["log_level"]
        when debug
          return Logger::DEBUG
        else
          return Logger::INFO
        end
      else
        return Logger::INFO
      end
    end

    def log(level, color, msg)
      colored_msg = msg.method(color)
      puts colored_msg.call
      if @settings["logger"]
        logger = @settings["logger"].method(level)
        logger.call(msg)
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
          "log_dir" => "logs"
        }

        f.write config.to_yaml
      end

      return true
    end
  end
end
