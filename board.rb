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

    
    def placed_blanks
        blank_locations = []
        @grid.each do |row| 
            row.each do |tile|
                if tile.value == 0
                    blank_locations << tile
                end
            end
        end
        blank_locations
    end
    
    def placed_blank_count
        self.placed_blanks.count        
    end

    def valid_pos(pos)
        x,y = pos
        (x >= 0 && x < @grid.length) && (y >= 0 && y < @grid.length)
    end
    
    def valid_adj_tiles(tile_pos)
        x,y = tile_pos
        adj_directions = [[-1,-1],[-1,0],[-1,1],[0,-1],[1,-1],[1,0],[1,1],[0,1]]
        valid_directions = adj_directions.select { |pos_x,pos_y| valid_pos([x + pos_x, y + pos_y])}
        valid_adj_pos = valid_directions.map { |pos_x,pos_y| [x + pos_x, y + pos_y] }
    end
    
    def place_random_blank
        x,y = rand(@grid.length), rand(@grid.length)
        first_blank = @grid[x][y]
        first_blank.set_value(0)

        pos = [x,y]     
    end

    def place_next_blank(pos,direction)
        x,y = pos
        path_x,path_y = direction
        if self.valid_pos(pos)
            next_blank = @grid[x + path_x][y + path_y]
            next_blank.set_value(0)
            [x + path_x,y +path_y]
        end
    end

    def place_blanks(tile_pos,direction,occurances)
        x,y = tile_pos
        path_x, path_y = direction

        occurances.times do 
            next_blank = @grid[x + path_x][y + path_y]
            next_blank.set_value(0)
            x += path_x
            y += path_y
        end
    end

    def big_blank_square_shape(tile_pos)
        tiles = valid_adj_tiles(tile_pos)

        tiles.each do |x,y| 
            @grid[x][y].set_value(0)
        end
    end
    
    def blank_square_shape(tile_pos)
        source = tile_pos
        path = @@Direction.clone.shuffle
        points = path.take(3)

        until points.length < 1
            point = points.shift
            if valid_pos(source)
                source = place_next_blank(source,point)
            else
                next
            end
        end        
    end

    def straight_line_shape(tile_pos)
        source = tile_pos
        path = @@Direction.shuffle[0]

        2.times do
            if valid_pos(source)
                source = place_next_blank(source,path)
            end
        end
        source        
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
                next_blank = self.place_next_blank(tile,move)
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