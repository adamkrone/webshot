require 'rmagick'
include Magick

module Webshot
  class Diff
    def initialize(base_dir, last_version, current_version, current_page, verbose)
      @base_dir = base_dir
      @last_version = last_version
      @current_version = current_version
      @current_page = current_page
      @verbose = verbose
    end

    def get_image_diff
      last_file = @current_page.old_version(@last_version)
      new_file = @current_page.screenshot

      puts "\tDiff:"
      puts "\tChecking for #{last_file}..." if @verbose
      if File.exist?(last_file) and @last_version != nil
        diff_dir = "#{@base_dir}/diffs/#{@current_page.browser}/#{@current_page.breakpoint}/#{@current_page.url}"
        diff_file = "#{@last_version}-vs-#{@current_version}.png"

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
          system "compare #{last_file} #{new_file} #{diff_dir}/#{diff_file}"
          puts "\tDiff saved to #{diff_dir}/#{diff_file}.".green if @verbose
        end
      else
        puts "\tNot found.".yellow if @verbose
      end
    end
  end
end
