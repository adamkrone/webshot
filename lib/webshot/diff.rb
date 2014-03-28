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
	diff_dir = "#{@base_dir}/diffs/#{@page.browser}/#{@page.breakpoint}/#{@page.url}"
	diff_file = "#{@old_version}-vs-#{@current_version}.png"

        unless File.directory? diff_dir
          FileUtils.mkdir_p diff_dir
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
          diff = ["#{diff_dir}/#{diff_file}", 1]
        end

        if diff[1] == 0
          puts "\tNo changes found.".yellow if @verbose
        else
          stdin, stdout, stderr = Open3.popen3("compare -dissimilarity-threshold 1 -subimage-search #{last_file} #{new_file} #{diff_dir}/#{diff_file}")
          error = (stderr.readlines).join("")

          if (error.include? "differs") 
            puts "\tImage size differs, swapping image order...".yellow if @verbose
            stdin, stdout, stderr = Open3.popen3("compare -dissimilarity-threshold 1 -subimage-search #{new_file} #{last_file} #{diff_dir}/#{diff_file}")
            error = (stderr.readlines).join("")

            if (error.include? "differs") 
              puts "\tCouldn't save diff file!".red
            else
              puts "\tDiff saved to #{diff_dir}/#{diff_file}.".green if @verbose
            end
          else
            puts "\tDiff saved to #{diff_dir}/#{diff_file}.".green if @verbose
          end
        end
      else
        puts "\tNot found.".yellow if @verbose
      end
    end
  end
end
