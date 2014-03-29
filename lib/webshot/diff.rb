require 'rmagick'
require 'open3'
include Magick

module Webshot
  class Diff
    def initialize(args)
      @base_dir = args[:base_dir]
      @old_version = args[:old_version]
      @current_version = args[:current_version]
      @page = args[:page]
      @verbose = args[:verbose]
    end

    def get_image_diff
      last_file = @page.old_version(@old_version)
      new_file = @page.screenshot

      puts "\tDiff:"
      puts "\tChecking for #{last_file}..." if @verbose
      if File.exist?(last_file) and @old_version != nil
        @diff_dir = "#{@base_dir}/diffs/#{@page.browser}/#{@page.breakpoint}/#{@page.url}"
        @diff_file = "#{@old_version}-vs-#{@current_version}.png"

        unless File.directory? @diff_dir
          FileUtils.mkdir_p @diff_dir
        end

        if @verbose
          puts "\tComparing:"
          puts "\tnew version: #{new_file}"
          puts "\tolder version: #{last_file}"
        end

        image1 = ImageList.new(last_file)
        image2 = ImageList.new(new_file)

        begin
          diff = image1.compare_channel(image2, MeanAbsoluteErrorMetric)
        rescue
          diff = ["#{@diff_dir}/#{@diff_file}", 1]
        end

        if diff[1] == 0
          puts "\tNo changes found.".yellow
        else
          compare(last_file, new_file, true)
        end
      else
        puts "\tScreenshot not found.".yellow
      end
    end

    private

    def compare(file1, file2, retry_compare)
      stdin, stdout, stderr = Open3.popen3("compare -dissimilarity-threshold 1 -subimage-search #{file1} #{file2} #{@diff_dir}/#{@diff_file}")
      error = (stderr.readlines).join("")

      if error.include? "differs"
        if retry_compare
          puts "\tImage size differs, swapping image order...".yellow if @verbose
          compare(file2, file1, false)
        else
          puts "\tCouldn't save diff file!".red
        end
      else
        puts "\tDiff saved to #{@diff_dir}/#{@diff_file}.".green
      end
    end
  end
end
