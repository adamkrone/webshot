require 'thor'
require 'net/http'
require 'rexml/document'
require 'colorize'

require 'webshot/config'
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
        urls = read_sitemap @config.settings["url"]
      else
        urls = ["#{@config.settings['url']}"]
      end

      if @config.settings["breakpoints"]
        @config.settings["breakpoints"].each_with_index do |breakpoint, i|
          name = breakpoint
          breakpoint = breakpoint.split("x")
          width = breakpoint[0].to_i
          height = breakpoint[1].to_i

          @config.settings["breakpoints"][i] = {"name" => name, "width" => width, "height" => height}
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

    private

    def read_sitemap(sitemap_url)
      url = sitemap_url
      begin
        request = Net::HTTP.get_response(URI.parse(url)).body
      rescue URI::InvalidURIError
        puts "I don't know what to do with '#{url}'..."
        puts "Please use a valid URL."
        exit
      end
      sitemap = REXML::Document.new request

      urls = []
      sitemap.elements.each "urlset/url/loc" do |url|
        urls << url.text
      end

      return urls
    end
  end
end
