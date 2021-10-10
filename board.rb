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
        @grid.each_with_index do |row,row_idx| 
            row.each_with_index do |tile,tile_idx|
                if tile.value == 0
                    blank_locations << [row_idx,tile_idx]
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
        next_blank = @grid[x + path_x][y + path_y]
        if self.valid_pos([x + path_x,y +path_y])
            next_blank.set_value(0)
        end
        [x + path_x,y +path_y]
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
            source = place_next_blank(source,point)
        end        
    end

    def straight_line_shape(tile_pos)
        source = tile_pos
        path = @@Direction.shuffle[0]

        2.times do
            source = place_next_blank(source,path)
        end
        source        
    end

    def blank_shape_select(blanks_remaining,tile_pos)
        tie_break = (0..7).to_a.sample
        case 
        when blanks_remaining >= 0 && blanks_remaining < 3
            direction = @@Direction.shuffle[0]
            self.place_next_blank(tile_pos,direction)
        when blanks_remaining >= 3 && tie_break[1..7].even?
            self.blank_square_shape(tile_pos)
        when blanks_remaining >= 3 && tie_break[1..7].odd?
            self.straight_line_shape(tile_pos)
        when blanks_remaining >=8 && tie_break == 0 
            self.blank_square_shape(tile_pos)
        end
    end
    
    def blank_tile_path
        blank_count_options = {
            "one area" => blank_count_generator("one area"),
            "two areas" => blank_count_generator("two areas") 
        }

        blank_areas = blank_count_options.values.sample
     
        blank_areas.each do |area|
            source = self.place_random_blank

            # debugger
            while self.placed_blank_count < blank_areas.sum
                blanks_remaining = blank_areas.sum - self.placed_blank_count
                self.blank_shape_select(blanks_remaining,source)

                source = self.placed_blanks.sample
            end
        end
        self.placed_blank_count
    end

    def round_to_even(num)
        return (num + 1) if num.odd?
        num
    end
end