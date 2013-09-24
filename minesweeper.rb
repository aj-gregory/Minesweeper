class Game

  def is_bomb?(tile)
    tile.bomb #true or false value
  end

  def reveal(tile)
    tile.explore
    tile.flagged = false
  end

  def flag(tile)
    if @board.num_flagged >= @board.num_mines
      puts "You're out of flags!"
    else
      tile.flagged = true
    end
  end

  def winning?
    @board.player_wins?
  end

  def play
    # puts "What size board? (small/big)"
    board_size = "small" #gets.chomp.downcase
    @board = Board.new(board_size)

    game_over = false
    until game_over
      @board.render
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
      if winning?
        @board.final_render
        return "You win!"
      end
    end
    @board.final_render
    puts "BOMB!"
    puts "Game over."
  end


end




class Board
  attr_accessor :tiles, :num_mines

  def initialize(size)

    case size
    when "small"
      @num_mines = 3 #fix this
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
        tile.check_neighboring_bombs
      end
    end
  end

  def render
    puts "       0 1 2 3 4 5 6 7 8"
    @tiles.each_with_index do |row, row_idx|
      print "row: #{row_idx} "
      row.each do |tile|
        print "#{tile.display} "
      end
      puts
    end
  end

  def final_render
    puts "       0 1 2 3 4 5 6 7 8"
    @tiles.each_with_index do |row, row_idx|
      print "row: #{row_idx} "
      row.each do |tile|
        print "#{tile.display_bombs} "
      end
      puts
    end
  end

  def num_explored
    tiles_explored = 0
    @tiles.each do |row|
      row.each do |tile|
        tiles_explored += 1 if tile.explored
      end
    end
    tiles_explored
  end

  def num_flagged
    tiles_flagged = 0
    @tiles.each do |row|
      row.each do |tile|
        tiles_flagged += 1 if tile.flagged
      end
    end
    tiles_flagged
  end

  def player_wins?
   (num_explored + num_flagged) == @dimension ** 2
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
    self.explored = true unless @bomb
    check_neighboring_bombs

    if @adjacent_bombs == '_'
      neighbors.each do |neighbor|
        next if neighbor.explored
        next if neighbor.flagged
        neighbor.explore
      end
    else
      display
    end
  end

  def display
    if @flagged
      "F"
    elsif @explored == false
      "*"
    elsif !@bomb
      @adjacent_bombs
    end
  end

  def display_bombs
    if @bomb
      "B"
    elsif @flagged
      "F"
    elsif @explored == false
      "*"
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
