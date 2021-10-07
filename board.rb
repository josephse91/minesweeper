require "./tile.rb"

class Board

    attr_accessor :grid
    @@Level = {
        "easy" => 8,
        "hard" => 16,
    }

    def self.grid_layout(level_difficulty)
        grid_size = @@Level[level_difficulty]
        @grid = Array.new(grid_size) {Array.new(grid_size) {Tile.new}}
    end
    
    def initialize  #(grid = Board.grid_layout("easy"))
        @grid = Board.grid_layout("easy")
    end

    def set_blank_tiles
        blank_count_options = {
            "one area" => blank_count_generator("one area"),
            "two areas" => blank_count_generator("two areas") 
        }
    end

    def round_to_even(num)
        return (num + 1) if num.odd?
        num
    end

    def blank_count_generator(blank_area_count)
        median_blank_count = round_to_even(@grid.flatten.count / 4)
        delta = round_to_even(@grid.flatten.count / 16)
        low_end_count = round_to_even(median_blank_count - delta)
        high_end_count = round_to_even(median_blank_count + delta)
        
        case blank_area_count
        when "one area"
            blanks = (low_end_count..high_end_count).select(&:even?).sample
        when "two areas"
            first_block = (low_end_count..median_blank_count).select(&:even?).sample
            second_block = delta
            blanks = [first_block,second_block]
        end 
    end



end