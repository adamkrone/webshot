require "webshot"

viewer = Webshot::Viewer.new
current_version = viewer.current_version
previous_version = viewer.previous_version

puts "The current version is: #{current_version}"

puts "\tIt has screenshots for the following browsers:"
viewer.browsers(current_version).each { |browser| puts "\t\t#{browser}" }

puts "\tIt has screenshots for the following breakpoints:"
viewer.breakpoints(current_version).each { |breakpoint| puts "\t\t#{breakpoint}" }

puts "\tLoading current version's screenshots..."
screenshots = viewer.screenshots(current_version)
screenshots.each { |screenshot| puts "\t\t#{screenshot}" }

puts "The previous version is: #{previous_version}"

puts "\tLoading diffs between current and previous versions..."
diffs = viewer.diff_by_version(previous_version, current_version)
diffs.each { |diff| puts "\t\t#{diff}" }

puts "Pages:"
pages = viewer.pages(current_version)
pages.each { |page| puts "\t#{page}" }

home_page = "www.thirdwave.dev02.thirdwavellc.com/content.cfm/home"
puts "Diffs for home page (#{home_page}):"
diffs = viewer.diff_by_page(home_page)
diffs.each { |diff| puts "\t#{diff}" }
