require 'colorize'
require 'byebug'

class Tile

    attr_accessor :bomb
    def initialize
        @show = false
        @bomb = false
        @value = ""
    end

    def reveal
        @show = true
    end

    def set_value(num)
        @value = num
    end

    def print_bomb
        "*"
    end
    
    def value_print_with_color
        val = @value.to_s
        case val
        when "1" then return val.colorize(:light_blue)
        when "2" then return val.colorize(:green)
        when "3" then return val.colorize(:red)
        when "4" then return val.colorize(:magenta)
        when "5" then return val.colorize(:cyan)   
        end
        # val
    end
    # private

    # attr_reader :value
    # attr_accessor :bomb

end