require 'colorize'
require 'RMagick'
require 'open3'
include Magick

module Webshot
  class Diff
    def initialize(page, config)
      @page = page
      @config = config
      @base_dir = @config.settings["base_dir"]
      @last_version = @config.settings["last_version"]
      @current_version = @config.settings["version"]
      @verbose = @config.settings["verbose"]
    end

    def save
      @last_file = @page.last_screenshot(@last_version)
      @new_file = @page.screenshot

      @config.log(:info, :white, "\tDiff:")
      check_file
    end

    private

    def check_file
      @config.log(:info, :white, "\tChecking for #{@last_file}...") if @last_version != nil
      if File.exist?(@last_file)
        @diff_file = "#{@last_version}-vs-#{@current_version}.png"

        create_dir

        if @verbose
          @config.log(:info, :white, "\tComparing:")
          @config.log(:info, :white, "\tnew version: #{@new_file}")
          @config.log(:info, :white, "\tolder version: #{@last_file}")
        end

        image1 = ImageList.new(@last_file)
        image2 = ImageList.new(@new_file)

        diff = compare_channel(image1, image2)

        if diff[1] == 0
          @config.log(:info, :yellow, "\tNo changes found.\n")
        else
          compare(@last_file, @new_file, true)
        end
      else
        @config.log(:info, :yellow, "\tScreenshot not found.\n")
      end
    end

    def create_dir
      @diff_dir = "#{@base_dir}/diffs/#{@page.browser}/#{@page.breakpoint}/#{@page.stripped_url}"

      unless File.directory? @diff_dir
        FileUtils.mkdir_p @diff_dir
      end
    end

    def compare_channel(image1, image2)
      begin
        diff = image1.compare_channel(image2, MeanAbsoluteErrorMetric)
      rescue
        diff = ["#{@diff_dir}/#{@diff_file}", 1]
      end

      return diff
    end

    def compare(file1, file2, retry_compare)
      stdin, stdout, stderr = Open3.popen3("compare -dissimilarity-threshold 1 -subimage-search #{file1} #{file2} #{@diff_dir}/#{@diff_file}")
      error = (stderr.readlines).join("")

      if error.include? "differs"
        if retry_compare
          @config.log(:info, :yellow, "\tImage size differs, swapping image order...")
          compare(file2, file1, false)
        else
          @config.log(:warn, :red, "\tCouldn't save diff file!\n")
        end
      else
        @config.log(:info, :green, "\tDiff saved to #{@diff_dir}/#{@diff_file}.\n")
      end
    end
  end
end
