require "webshot"

viewer = Webshot::Viewer.new
current_version = viewer.current_version
previous_version = viewer.previous_version

puts "The current version is: #{current_version}"

puts "It has screenshots for the following browsers:"
puts viewer.browsers(current_version)

puts "It has screenshots for the following breakpoints:"
puts viewer.breakpoints(current_version)

puts "Loading current version's screenshots..."
screenshots = viewer.screenshots(current_version)
puts screenshots

puts "The previous version is: #{previous_version}"

puts "Loading diffs between current and previous versions..."
diffs = viewer.diffs(previous_version, current_version, {:breakpoint => ["320x480", "768x1024"]})
puts diffs
