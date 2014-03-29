require 'thor'
require 'colorize'

require 'webshot/config'
require 'webshot/sitemap'
require 'webshot/breakpoint'
require 'webshot/runner'

module Webshot
  class CLI < Thor
    START_TIME = Time.now

    desc "init", "Initialize project with Shotfile"
    option :force, :type => :boolean, :aliases => "-f"
    def init
      webshot = Webshot::Config.new
      webshot.create_config(options[:force])
    end

    desc "capture", "Captures screenshots of a page or pages"
    option :url, :aliases => "-u"
    option :sitemap, :aliases => "-s"
    option :browsers, :type => :array
    option :breakpoints, :type => :array
    option :output, :aliases => "-o"
    option :diff, :type => :boolean, :aliases => "-d"
    option :wait, :type => :numeric, :aliases => "-w"
    option :verbose, :aliases => "-v"
    def capture
      start_time = START_TIME.to_i
      @config = Webshot::Config.new
      @total_urls = 0

      merge_options(options)
      verify_config(options)
      urls = get_urls
      set_breakpoints

      runner = Webshot::Runner.new(:config => @config,
                                   :version => START_TIME.to_i,
                                   :urls => urls)
      runner.start
    end

    private

    def merge_options(options)
      options.each do |option, value|
        @config.settings[option.to_s] = value
      end
    end

    def verify_config(options)
      if options.count == 0 && @config.settings == nil
        puts "You must provide a --url, or configure a Shotfile using 'webshot init'."
        exit
      end
    end

    def get_urls
      if @config.settings["sitemap"]
        urls = Webshot::Sitemap.new(@config.settings["url"]).urls
      else
        urls = ["#{@config.settings['url']}"]
      end

      if urls == nil
        puts "I don't know what to do with '#{@config.settings["url"]}'..."
        puts "Please use a valid URL."
        exit
      else
        return urls
      end
    end

    def set_breakpoints
      if @config.settings["breakpoints"]
        @config.settings["breakpoints"].each_with_index do |breakpoint, i|
          @config.settings["breakpoints"][i] = Webshot::Breakpoint.new(breakpoint)
        end
      else
        puts "You must provide at least one breakpoint."
        exit
      end
    end
  end
end
