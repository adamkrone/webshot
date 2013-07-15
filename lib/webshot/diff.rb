module Webshot
  class Diff
    def initialize(last_version, current_version, current_page)
      @last_version = last_version
      @current_version = current_version
      @current_page = current_page
    end

    def get_image_diff
      last_file = @current_page.old_version(@last_version)
      new_file = @current_page.screenshot

      puts "Checking for #{last_file}...".yellow
      if File.exist?(last_file) and @last_version != nil
        diff_dir = "diffs/#{@current_page.browser}/#{@current_page.breakpoint}/#{@current_page.url}"
        diff_file = "#{@last_version}-vs-#{@current_version}.png"

        unless File.directory? diff_dir
          FileUtils.mkdir_p diff_dir
        end

        puts "Comparing #{new_file} with older version: #{last_file}".green
        system "compare #{last_file} #{new_file} #{diff_dir}/#{diff_file}"
        puts "Diff #{diff_dir}/#{diff_file} saved.".green
      else
        puts "Not found.".yellow
      end
    end
  end
end