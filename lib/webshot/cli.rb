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

      options.each do |option, value|
        @config.settings[option.to_s] = value
      end

      if options.count == 0 && @config.settings == nil
        puts "You must provide a --url, or configure a Shotfile using 'webshot init'."
        exit
      end

      if @config.settings["sitemap"]
        urls = Webshot::Sitemap.new(@config.settings["url"]).urls
      else
        urls = ["#{@config.settings['url']}"]
      end

      if urls == nil
        puts "I don't know what to do with '#{url}'..."
        puts "Please use a valid URL."
        exit
      end

      if @config.settings["breakpoints"]
        @config.settings["breakpoints"].each_with_index do |breakpoint, i|
          @config.settings["breakpoints"][i] = Webshot::Breakpoint.new(breakpoint)
        end
      else
        puts "You must provide at least one breakpoint."
        exit
      end

      runner = Webshot::Runner.new(:config => @config,
                                   :version => START_TIME.to_i,
                                   :urls => urls)
      runner.start
    end
  end
end
