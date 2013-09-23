class Game

  def is_bomb?(tile)
    tile.bomb #true or false value
  end

  def reveal(tile)
    tile.explore
  end

  def flag(tile)
    tile.flagged = true
    tile.explored = true
  end

  def winning?
    @board.all_explored?
  end

  def play
    # puts "What size board? (small/big)"
    board_size = "small" #gets.chomp.downcase
    @board = Board.new(board_size)
    @board.render

    game_over = false
    until game_over
      puts "Which tile? (row, tile)"
      tile_position = gets.chomp.split(", ")
      tile_position.map! {|el| el.to_i }
      tile = @board.tiles[tile_position[0]][tile_position[1]]

      puts "Flag or reveal? (f/r)"
      action = gets.chomp.downcase
        case action
        when "f"
          flag(tile)
        when "r"
          game_over = true if is_bomb?(tile)
          reveal(tile)
        end
      @board.render
      if winning?
        return "You win!"
      end
    end

    puts "Game over."
  end


end




class Board
  attr_accessor :tiles

  def initialize(size)

    case size
    when "small"
      @num_mines = 10
      @dimension = 9
    when "big"
      @num_mines = 40
      @dimension = 16
    end

    populate_board
    set_neighbors_all
    place_bombs
    mark_fringe_squares
  end

  def populate_board
     @tiles = []
     @dimension.times do |row|
       @tiles << []
       @dimension.times do |tile|
         @tiles[row] << make_tile([row, tile])
       end
     end
  end

  def make_tile(position)
    tile = Tile.new(position)
    tile.board = self
    tile
  end

  def set_neighbors_all
    @tiles.each do |row|
      row.each do |tile|
        set_neighors_one_tile(tile)
      end
    end
  end

  def set_neighors_one_tile(tile)
    tile_row = tile.position[0]
    tile_column = tile.position[1]


    (-1).upto(1) do |row|
      (-1).upto(1) do |column|
        next if (tile_row + row) < 0 || (tile_row + row) >= @dimension
        next if (tile_column + column) < 0 || (tile_column + column) >= @dimension

        next if @tiles[tile_row + row][tile_column + column] == tile #equality method for tile class?
        tile.neighbors << @tiles[(tile_row + row)][(tile_column + column)]
      end
    end
  end

  def place_bombs
    bomb_tiles = []
    @num_mines.times do
      rand_tile = nil

      while bomb_tiles.include?(rand_tile) || rand_tile.nil?
        rand_row = rand(9)
        rand_col = rand(9)
        rand_tile = @tiles[rand_row][rand_col]
      end

      rand_tile.bomb = true
      bomb_tiles << rand_tile
    end
  end

  def mark_fringe_squares
    @tiles.each do |row|
      row.each do |tile|
        tile.neighboring_bombs
      end
    end
  end

  def render
    @tiles.each do |row|
      row.each do |tile|
        print tile.display
      end
      puts
    end
  end

  def all_explored?
    @tiles.each do |row|
      row.each do |tile|
        return false if tile.explored == false
      end
    end
    true
  end

end






class Tile
  attr_accessor :board, :position, :neighbors, :bomb, :flagged, :adjacent_bombs, :explored

  def initialize(position)
    @position = position
    @neighbors = []
    @bomb = false
    @flagged = false
    @explored = false
  end

  def explore
    self.explored = true
    check_neighboring_bombs

    if @adjacent_bombs == '_'
      neighbors.each do |neighbor|
        next unless neighbor.display == '*'
        neighbor.explore
      end
    else
      display
    end
  end

  def display
    if @explored == false
      "*"
    # elsif @explored
  #     "_"
    elsif @flagged
      "F"
    elsif @bomb
      "B"
    elsif !@bomb
      @adjacent_bombs
    end
  end

  def check_neighboring_bombs
    num_bombs = 0
    @neighbors[0].position
    @neighbors.each do |neighbor|
      num_bombs += 1 if neighbor.bomb
    end
    if num_bombs == 0
      @adjacent_bombs = '_'
    else
      @adjacent_bombs = num_bombs.to_s
    end
  end

end
