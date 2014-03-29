module Webshot
  class Breakpoint
    attr_reader :name, :width, :height

    def initialize(breakpoint)
      @name = breakpoint
      @width = @name.split("x")[0]
      @height = @name.split("x")[1]
    end
  end
end
