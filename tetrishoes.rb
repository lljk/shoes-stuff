# tetrishoes by lljk
# still a little funky!


class TetrisBlock < Shoes::Widget
	attr_accessor :x, :y, :stroke_color, :fill_color
	def initialize(x, y, stroke_color, fill_color)
		@x = x; @y = y
		@stroke_color = stroke_color; @fill_color = fill_color
		
		stroke stroke_color; fill fill_color
		rect(x, y, 18, 18, 3)
	end
end		 #TetrisBlock


module TetrisShape
	attr_accessor :x, :y, :occupied_coords, :size
	
	def init(shape_array, size, stroke_color, fill_color)
		@shape_array = shape_array
		@size = size * 20
		@rotation_index = rand(@shape_array.length)
		@occupied_coords = []
		@locked = false
		@slot = stack width: @size, height: @size
		@stroke_color = stroke_color; @fill_color = fill_color
		
	end
	
	def draw_shape(shape_array)
		@occupied_coords.clear
		x = 0; y = 0
		@slot.append{
			shape_array.each{|row|
				row.each{|entry|
					case entry
						when 0
							x += 20
						when 1
							block = tetris_block(x, y, @stroke_color, @fill_color)
							block.x = x + @x; block.y = y + @y
							@occupied_coords << [block.x, block.y, block]
							x += 20
					end
				}
			x = 0
			y += 20
			}
		}
	end
	
	def rotate_shape
		@rotation_index += 1
		@rotation_index = 0 if @rotation_index > @shape_array.length - 1
		@slot.clear
		draw_shape(@shape_array[@rotation_index])
	end
	
	def set_coords(x, y)
		@x = x; @y = y
		@slot.clear
		@slot.move(@x, @y)
		draw_shape(@shape_array[@rotation_index])
	end
	
	def lock
		@locked = true
	end
	
	def locked?
		@locked
	end
	
end		#TetrisShape


class TetrisO < Shoes::Widget
	include TetrisShape
	def initialize
		pos = [
		[1, 1],
		[1, 1]
		]
		shape_array = [pos]
		init(shape_array, 2, gold, maroon)
	end
end		#TetrisO


class TetrisI < Shoes::Widget
	include TetrisShape
	def initialize
		pos1 = [
			[1],
			[1],
			[1],
			[1]
		]
		pos2 = [
			[1, 1, 1, 1]
		]
		shape_array = [pos1, pos2]
		init(shape_array, 4, silver, darkblue)
	end
end	#TetrisI


class TetrisL < Shoes::Widget
	include TetrisShape
	def initialize
		pos1 = [
			[1, 0, ],
			[1, 0, ],
			[1, 1, ]
		]
		pos2 = [
			[0, 0, 1],
			[1, 1, 1]
		]
		pos3 = [
			[1, 1],
			[0, 1],
			[0, 1]
		]
		pos4 = [
			[1, 1, 1],
			[1, 0, 0],
		]
		shape_array = [pos1, pos2, pos3, pos4]
		init(shape_array, 3, forestgreen, gold)
	end
end		#TetrisL


class TetrisJ < Shoes::Widget
	include TetrisShape
	def initialize
		pos1 = [
			[0, 1],
			[0, 1],
			[1, 1]
		]
		pos2 = [
			[1, 1, 1],
			[0, 0, 1],
		]
		pos3 = [
			[1, 1],
			[1, 0],
			[1, 0]
		]
		pos4 = [
			[1, 0, 0],
			[1, 1, 1]
		]
		shape_array = [pos1, pos2, pos3, pos4]
		init(shape_array, 3, gold, forestgreen)
	end
end		#TetrisJ


class TetrisT < Shoes::Widget
	include TetrisShape
	def initialize
		pos1 = [
			[1, 1, 1],
			[0, 1, 0],
		]
		pos2 = [
			[1, 0],
			[1, 1],
			[1, 0]
		]
		pos3 = [
			[0, 1, 0],
			[1, 1, 1]
		]
		pos4 = [
			[0, 1],
			[1, 1],
			[0, 1]
		]
		shape_array = [pos1, pos2, pos3, pos4]
		init(shape_array, 3, blue, silver)
	end
end		#TetrisT


class TetrisS < Shoes::Widget
	include TetrisShape
	def initialize
		pos1 = [
			[0, 1, 1],
			[1, 1, 0]
		]
		pos2 = [
			[1, 0],
			[1, 1],
			[0, 1]
		]
		shape_array = [pos1, pos2]
		init(shape_array, 3, royalblue, purple)
	end
end


class TetrisZ < Shoes::Widget
	include TetrisShape
	def initialize
		pos1 = [
			[1, 1, 0],
			[0, 1, 1]
		]
		pos2 = [
			[0, 1],
			[1, 1],
			[1, 0]
		]
		shape_array = [pos1, pos2]
		init(shape_array, 3, purple, royalblue)
	end
end


class TetrisBoardRow < Shoes::Widget
	attr_accessor :cells
	def initialize(x, y)
		@cells = {}
		10.times{
			@cells[x] = "empty"
			x += 20
		}
	end
end		#TetrisBoardRow


class TetrisBoard < Shoes::Widget
	attr_accessor :field
	
	def initialize(x, y)
		board = stack width: 210, height: 410, do
			#background black ## THIS BREAKS!!
			border white
			row_y = 400
			@field = {}
			20.times{
				row = tetris_board_row(x, row_y)
				@field[row_y] = row.cells
				row_y -= 20
			}
		end
		board.move(x - 5, y - 5)
	end
	
	def occupy_cell(x, y, element)
		@field[y][x] = element if @field[y] && @field[y][x]
	end
	
end		#TetrisBoard

######################


Shoes.app width: 480, height: 450 do
	
	@game_started = false
	background gradient(dimgray, black)
	title "\n\ntetriShoes\n", stroke: white, align: "center"
	para "use left and right arrow keys to move piece
up arrow to rotate, down arrow to soft drop
space bar to start and pause play", stroke: white, align: "center"

	def init_game
		background gradient(dimgray, black)
		@game_over = false
		@score = 0
		@rows_cleared = 0
		@drop_speed = 2
		@board_x = 20; @board_y = 20
		fill gradient(black, rgb(20, 20, 25))
		rect(15, 15, 210, 410)
		board_area = stack do
			@board = tetris_board(@board_x, @board_y)
		end
		@status_area = stack width: 210, height: 410, top: 15, left: 255 do
			background gradient(black, rgb(20, 20, 25))
			border white
			@next_area = stack width: 200, height: 200, top: 60, left: 53
			para "next piece", stroke: white, align: "center", displace_top: 40
			@score_and_rows = para " ", stroke: white, align: "center", displace_top: 240
		end
		update_score
		next_shape
		new_shape
		drop_shapes(@drop_speed)
		@game_started = true
	end
	
	def update_score
		@score_and_rows.text = "score: #{@score}\n\nrows cleared: #{@rows_cleared}"
	end
	
	def next_shape
		@next_shape = nil
		shape_code = rand(7)
		case shape_code
			when 0
				stack{@next_shape = tetris_o}
			when 1
				stack{@next_shape = tetris_i}
			when 2
				stack{@next_shape = tetris_l}
			when 3
				stack{@next_shape = tetris_j}
			when 4
				stack{@next_shape = tetris_t}
			when 5
				stack{@next_shape = tetris_s}
			when 6
				stack{@next_shape = tetris_z}
		end
		@next_area.append{@next_shape.set_coords(360 - (@next_shape.size / 2), 170 - (@next_shape.size / 2))}
	end
	
	def new_shape
		@shape = @next_shape
		@shape.set_coords(@board_x + 80, @board_y)
		@next_area.clear
		@shape.occupied_coords.each{|set|
			unless @board.field[set[1]][set[0]] == "empty"
				game_over
				break
			end
			
		}
		next_shape unless @game_over
	end
	
	def drop_shapes(speed)
		@falling = true
		@drop = animate(speed){
			@shape.y += 20
			@shape.set_coords(@shape.x, @shape.y)
			check_fall
		}
	end
	
	def check_fall
		@shape.occupied_coords.each{|set|
			x = set[0]; y = set[1] + 20
			if y == 420 || @board.field[y][x] != "empty"
				lock_shape
				new_shape
				break
			end
		}
	end
	
	def lock_shape
		@shape.lock
		@shape.occupied_coords.each{|set|
			@board.occupy_cell(set[0], set[1], set[2])
		}
		check_rows
	end
	
	def check_rows
		@board.field.each{|row, x_hash|
			to_clear = []
			x_hash.each{|x, value|
				to_clear << [row, x, value] unless value == "empty"
			}
			
			if to_clear.length == 10
				to_clear.each{|set|
					@y = set[0]; x = set[1]; block = set[2]
					@board.occupy_cell(x, @y, "empty")
					block.remove
				}
				drop_all_above(@y)
				@score += 50 * @drop_speed; @rows_cleared +=1
				speed_up_drop if @rows_cleared % 10 == 0
				update_score
				check_rows
			end
		}
	end
	
	def drop_all_above(y)
		blocks_to_drop = []
		@drop.stop
		@board.field.to_a.sort.reverse.each{|set|
			row_y = set[0]; x_hash = set[1]
			if row_y < y
				row_blocks_to_drop = []
				x_hash.each{|x, value|
					unless value == "empty"
						@board.occupy_cell(x, row_y, "empty")
						row_blocks_to_drop << value
					end
				}
				blocks_to_drop << row_blocks_to_drop
			end
		}
		unless blocks_to_drop.empty?
			blocks_to_drop.flatten.each{|block|
				@new_x = block.x; @new_y = block.y + 20
				@stroke_color = block.stroke_color; @fill_color = block.fill_color
				@board.occupy_cell(block.x, block.y, "empty")
				block.remove 
				@board.append{@new_block = tetris_block(@new_x, @new_y, @stroke_color, @fill_color)}
				@board.occupy_cell(@new_x, @new_y, @new_block)
			}
		end
		@drop.start
	end
	
	def speed_up_drop
		@drop_speed += 1
		@drop.stop; @drop = nil
		drop_shapes(@drop_speed)
	end
	
	def check_move(delta)
		@shape.occupied_coords.each{|set|
			x = set[0] + delta; y = set[1]
			if x < @board_x || x > @board_x + 200 || @board.field[y][x] != "empty"
				@occupied = true
				break
			else
				@occupied = false
			end
		}
	end
	
	def check_rotate
		@no_rotate = false
		if @shape.x + @shape.size > @board_x + 200
			@shape.set_coords((@board_x + 200) - @shape.size, @shape.y)
		end
		@shape.occupied_coords.each{|set|
			x = @shape.x + @shape.size; y = @shape.y + @shape.size
			if y > 400
				@no_rotate = true; break
			end
			if @board.field[y] && @board.field[y][x]
				if @board.field[y][x] != "empty" || @board.field[@shape.y][x] != "empty" || @board.field[@shape.y][x - 20] != "empty" || @board.field[y][x - 20] != "empty" || @board.field[y][@shape.x] != "empty"
					@no_rotate = true 
					break
				end
			end
		}
	end
	
	def game_over
		@game_over = true
		@game_started = false
		@drop.stop if @drop; @drop = nil
		@board.field.to_a.each{|set|
			x_hash = set[1]
			x_hash.each{|x, value|
				value.remove unless value == "empty"
			}
		}
		title "GAME OVER", left: 50, top: 120, stroke: white
		stack width: 200, left: 40, top: 250 do
		para "press space to restart", stroke: white
		end
	end
	
	
	keypress{|key|
		if @game_started
			unless @shape.locked? || @game_over
				@occupied = false
				case key
					when :up; check_rotate; @shape.rotate_shape unless @no_rotate
					when :down; @shape.y += 20 unless @shape.y > 300
						@shape.set_coords(@shape.x, @shape.y); check_fall
					when :left
						check_move(-20)
						@shape.set_coords(@shape.x - 20, @shape.y) unless @occupied
					when :right
						check_move(20)
						@shape.set_coords(@shape.x + 20, @shape.y) unless @occupied
					when " "
						if @falling
							@drop.stop; @falling = false
							@paused = title "paused", left: 45, top: 150, stroke: white
						else
							@drop.start; @falling = true
							@paused.remove
						end
				end
			end
		else
			if key == " "
				clear; init_game
			end
		end
	}
	
end		#Shoes.app