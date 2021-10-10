require "./tile.rb"
require 'byebug'

class Board

    attr_accessor :grid
    @@Level = {
        "easy" => 8,
        "hard" => 16,
    }

    @@Direction = [[0,1],[0,-1],[1,0],[-1,0]]

    def self.grid_layout(level_difficulty)
        grid_size = @@Level[level_difficulty]
        @grid = Array.new(grid_size) {Array.new(grid_size) {Tile.new}}
    end

    def [](pos)
        @grid[pos]
    end

    def []=(pos,value)
        @grid[pos] = value
    end

    
    def initialize  #(grid = Board.grid_layout("easy"))
        @grid = Board.grid_layout("easy")
    end

    def blank_count_generator(blank_area_count)
        median_blank_count = round_to_even(@grid.flatten.count / 4)
        delta = round_to_even(@grid.flatten.count / 16)
        low_end_count = round_to_even(median_blank_count - delta)
        high_end_count = round_to_even(median_blank_count + delta)
        
        case blank_area_count
        when "one area"
            blanks = [(low_end_count..high_end_count).select(&:even?).sample]
        when "two areas"
            first_block = (low_end_count..median_blank_count).select(&:even?).sample
            second_block = delta
            blanks = [first_block,second_block]
        end
    end

    def placed_blank_count
        count = 0
        @grid.each do |row| 
            row.each do |tile|
                if tile.value == 0
                    count += 1
                end
            end
        end
        count         
    end

    def valid_pos(pos)
        x,y = pos
        (x >= 0 && x < @grid.length) && (y >= 0 && y < @grid.length)
    end
    
    def place_first_blank
        x,y = rand(@grid.length), rand(@grid.length)
        first_blank = @grid[x][y]
        first_blank.set_value(0)

        pos = [x,y]     
    end

    def place_adj_blank(pos,direction)
        x,y = pos
        path_x,path_y = direction
        next_blank = @grid[x + path_x][y + path_y]
        next_blank.set_value(0)
        [[x + path_x],[y +path_y]]
    end

    def valid_adj_tiles(tile_pos)
        x,y = tile_pos
        adj_directions = [[-1,-1],[-1,0],[-1,1],[0,-1],[1,-1],[1,0],[1,1],[0,1]]
        valid_directions = adj_directions.select { |pos_x,pos_y| valid_pos([x + pos_x, y + pos_y])}
        valid_adj_pos = valid_directions.map { |pos_x,pos_y| [x + pos_x, y + pos_y] }
    end
    
    def blank_tile_path(tile_pos)
        tile_pos = tile_pos
        blank_collection = [tile_pos]
        blank_count_options = {
            "one area" => blank_count_generator("one area"),
            "two areas" => blank_count_generator("two areas") 
        }

        blank_area_count = blank_count_options.values.sample
        
        move = @@Direction.sample
        x,y = tile
        x_move,y_move = move
     
        while self.placed_blank_count < blank_area_count
            spaces = rand(1..3)
            if spaces > (blank_area_count - self.placed_blank_count)
                spaces = (blank_area_count - self.placed_blank_count)
            end
            # debugger
            spaces.times do 
                next_blank = self.place_adj_blank(tile,move)
                tile = [x + x_move ,y + y_move]
                blank_collection << tile 
            end
        end
    end

    def blank_tile_select(blank_tile_array)
        blank_tile_array.sample
    end

    def round_to_even(num)
        return (num + 1) if num.odd?
        num
    end
end