require 'yaml'

module Webshot
  class Config
    attr_accessor :settings

    def initialize()
      @settings = check_for_config
    end

    def check_for_config
      if File.exist? "Shotfile"
        YAML.load(File.read "Shotfile")
      else
        {}
      end
    end

    def create_config(force=false)
      if @settings and !force
        puts "You already have a Shotfile."
        return false
      end

      puts "Overwriting Shotfile..." if force

      File.open("Shotfile", "w") do |f|
        config = {
          "url" => "http://example.com",
          "sitemap" => false,
          "browsers" => ["firefox", "chrome"],
          "diff" => false,
          "verbose" => false
        }

        f.write config.to_yaml
      end
    end
  end
end