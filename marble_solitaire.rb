# little marble solitaire game
# by lljk

class SolitaireMarble < Shoes::Widget
	attr_accessor :x, :y
	
	def initialize(x, y)
		@x = x; @y = y
		stack width: 50, height: 50 do
			stroke darkgreen; fill gradient(lime, green)
			@o = oval(11, 11, 27)
			click{yield if block_given?}
		end
		self.move(x, y)
	end
	
	def pick_up
		@o.stroke = gold
		motion{|x, y| self.move(x - 25, y - 25)}
	end
	
	def drop
		@o.stroke = darkgreen
		motion{}
	end
	
	def set_coords(x, y)
		@x = x; @y = y
		self.move(x, y)
	end
end		#SolitaireMarble


class SolitaireCell < Shoes::Widget
	attr_accessor :x, :y, :occupied
	
	def initialize(x, y, occupied)

		@x = x; @y = y
		@occupied = occupied
		stack width: 50, height: 50 do
			stroke gradient(gray, silver)
			rect(0, 0, 49, 49, 5).fill = gradient(rgb(55, 55, 55), dimgray)
			stroke gradient(black, gray)
			o = oval(10, 10, 29).fill = gradient(black, rgb(55, 55, 55))
		end
		
		set_coords(x, y)
	end
	
	def set_coords(x, y)
		@x = x; @y = y
		self.move(x, y)
	end
end		#SolitaireCell


########################


Shoes.app title: "Shoes Marble Solitaire", width: 470, height: 470 do
	
	def init_game
		background gradient(dimgray, rgb(55, 55, 55))
		
		shape_array = [
			[0, 0, 0, 1, 1, 1, 0, 0, 0],
			[0, 0, 0, 1, 1, 1, 0, 0, 0],
			[0, 0, 0, 1, 1, 1, 0, 0, 0],
			[1, 1, 1, 1, 1, 1, 1, 1, 1],
			[1, 1, 1, 1, 2, 1, 1, 1, 1],
			[1, 1, 1, 1, 1, 1, 1, 1, 1],
			[0, 0, 0, 1, 1, 1, 0, 0, 0],
			[0, 0, 0, 1, 1, 1, 0, 0, 0],
			[0, 0, 0, 1, 1, 1, 0, 0, 0]
		]
		
		@board = {}
		@marbles = {}
		@undo_state = {}
		
		self.append{
		
			y = 10
			shape_array.each{|row|
				x = 10
				row.each{|pos|
					case pos
						when 0
							@board[[x, y]] = "no_cell"
							x +=50
						when 1
							cell = solitaire_cell(x, y, true)
							@board[[x, y]] = cell
							x += 50
						when 2
							cell = solitaire_cell(x, y, false)
							@board[[x, y]] = cell
							x += 50
					end
				}
				y += 50
			}
		
			@board.each{|pos, cell|
				unless cell == "no_cell"
					if cell.occupied
						x = pos[0]; y = pos[1]
						marble = solitaire_marble(x, y){move_marble(marble)}
						@marbles[[x, y]] = marble
					end
				end
			}
			
			undo_btn = link("undo", stroke: black, underline: "none"){undo_move}
			para undo_btn, top: 0, left: 0
			
			restart_btn = link("new", stroke: black, underline: "none"){
				if confirm("start new game?")
					clear; init_game
				end
			}
			para restart_btn, top: 0, left: 430
			
		}
	end		#init_game
	
	def move_marble(marble)
		@board.each{|k, v|
			if v == "no_cell"
				@undo_state[k] = v
			elsif v.occupied
				@undo_state[k] = "occupied"
			else
				@undo_state[k] = "empty"
			end
		}
		
		marble.pick_up
		@direction = nil
		
		release{|btn, x, y|
			marble.drop
			
			if x > marble.x + 70 && x < marble.x + 135; @direction = "right"
				elsif x < marble.x - 20 && x > marble.x - 85; @direction = "left"
				elsif y > marble.y + 70 && y < marble.y + 135; @direction = "down"
				elsif y < marble.y - 20 && y > marble.y - 85; @direction = "up"
				else marble.set_coords(marble.x, marble.y)
			end
		
			if @direction
				case @direction
					when "right"
						jump_over = [marble.x + 50, marble.y]
						jump_to = [marble.x + 100, marble.y]
					when "left"
						jump_over = [marble.x - 50, marble.y]
						jump_to = [marble.x - 100, marble.y]
					when "down"
						jump_over = [marble.x, marble.y + 50]
						jump_to = [marble.x, marble.y + 100]
					when "up"
						jump_over = [marble.x, marble.y - 50]
						jump_to = [marble.x, marble.y - 100]
				end
	
				if @board[jump_over].class == SolitaireCell &&
				@board[jump_over].occupied == true &&
				@board[jump_to].class == SolitaireCell &&
				@board[jump_to].occupied == false
					@marbles.delete([marble.x, marble.y])
					@board[[marble.x, marble.y]].occupied = false
					marble.set_coords(jump_to[0], jump_to[1])
					@board[jump_to].occupied = true
					@marbles[jump_to] = marble
					@marbles[jump_over].remove
					@marbles.delete(jump_over)
					@board[jump_over].occupied = false
				else
					marble.set_coords(marble.x, marble.y)
				end
			end
		}
	end		#move_marble
	
	def undo_move
		@marbles.each{|pos, marble| marble.remove}
		@marbles.clear
		
		@undo_state.each{|pos, cell|
			unless cell == "no_cell"
				x = pos[0]; y = pos[1]
				if cell == "occupied"
					@board[[x, y]].occupied = true
					self.append{marble = solitaire_marble(x, y){move_marble(marble)}
					@marbles[[x, y]] = marble}
				else
					@board[[x, y]].occupied = false
				end
			end
		}
	end
	
	init_game
	
end		#Shoes.app
