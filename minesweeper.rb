class Board

  def initialize(size)

    case size
    when "small"
      @num_mines = 10
      @dimension = 9
    when "big"
      @num_mines = 40
      @dimension = 16
    end

    populate_board #should return an array
  end

  def populate_board
     @tiles = []
     @dimension.times do |row|
       @dimension.times do |tile|
         row << make_tile([row, tile])
       end
     end

     set_neighbors
     number_adjacent_tiles
  end

  def make_tile(position) #position is a two-element array
    tile = Tile.new(position)
    tile.board = self
    tile
  end

  def set_neighors
    #iterate through tiles, set the neighbors for each
  end

  def number_adjacent_tiles
    #set contents of non-bomb tiles with number of adjacent bombs
  end

  def is_bomb?
  end

  def explore(tile)
    #board asks tiles for contents based on position
  end

  def flag_tile(tile)

  end

end

class Tile
  attr_accessor :board, :contents, :neighbors

  def initialize(position)
    @position = position
  end

end
