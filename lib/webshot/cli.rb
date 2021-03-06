require 'thor'
require 'colorize'

require 'webshot/config'
require 'webshot/sitemap'
require 'webshot/breakpoint'
require 'webshot/runner'

module Webshot
  class CLI < Thor
    desc "init", "Initialize project with Shotfile"
    option :force, :type => :boolean, :aliases => "-f"
    def init
      webshot = Webshot::Config.new
      webshot.create_config(options[:force])
    end

    desc "capture", "Captures screenshots of a page or pages"
    option :urls, :type => :array, :aliases => "-u"
    option :sitemap, :aliases => "-s"
    option :browsers, :type => :array
    option :breakpoints, :type => :array
    option :output, :aliases => "-o"
    option :diff, :type => :boolean, :aliases => "-d"
    option :wait, :type => :numeric, :aliases => "-w"
    option :verbose, :aliases => "-v"
    option :version
    def capture
      @config = Webshot::Config.new(options)
      verify_config(options)
      @config.settings["urls"] = get_urls

      runner = Webshot::Runner.new(@config)
      runner.start
    end

    private

    def verify_config(options)
      if options.count == 0 && @config.settings == nil
        puts "You must provide one or more --urls, a --sitemap, or configure a Shotfile using 'webshot init'."
        exit
      end
    end

    def get_urls
      if @config.settings["sitemap"]
        urls = Webshot::Sitemap.new(@config.settings["sitemap"]).urls
      else
        urls = @config.settings['urls']
      end

      if urls == nil
        puts "I don't know what to do with '#{@config.settings["url"]}'..."
        puts "Please use a valid URL."
        exit
      else
        return urls
      end
    end
  end
end
