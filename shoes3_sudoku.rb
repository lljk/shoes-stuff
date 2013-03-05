 ### a simple sudoku game for Shoes3
 ### by lljk
 
 ### hover mouse over a cell to enter numbers
 ### any other key will clear cell
 ### selecting 'auto-check' will check entries as you play
 
 ### Sudoku module provides some output to the console
 ### ...still working on making more difficult puzzles!
 
module Sudoku
	attr_accessor :grid
	
	class Sudoku_Cell
		include Sudoku
		
		attr_reader :row, :col, :box
		attr_accessor :possibles, :entry, :hidden_entry
		
		def initialize(row, col)
			@row = row; @col = col
			case
		  	when row < 3
		  		@box = 0 if col < 3
		  		@box = 1 if col > 2 && col < 6
		  		@box = 2 if col > 5
		  	when row > 2 && row < 6
		  		@box = 3 if col < 3
		  		@box = 4 if col > 2 && @col < 6
		  		@box = 5 if col > 5
		  	when row > 5
		  		@box = 6 if col < 3
		  		@box = 7 if col > 2 && col < 6
		  		@box = 8 if col > 5
		  	end
		end
		
	end	#Sudoku_Cell
	
	def init_puzzle
		build_new_solution
	end
	
	def build_new_solution
		init_grid
			
		@grid.each{|row|
			row.each{|cell|
				if cell.box == 0 || cell.box == 4 || cell.box == 8
					entry = rand(9) + 1
					while instance_variable_get("@box#{cell.box}").values.include?(entry)
						entry = rand(9) + 1
					end
					set(cell, entry)
				end
				}
		}
		
		fill_cells
	end
	
	def init_grid
		9.times{|i| instance_variable_set("@row#{i}", Hash.new)}
		9.times{|i| instance_variable_set("@col#{i}", Hash.new)}
		9.times{|i| instance_variable_set("@box#{i}", Hash.new)}
		
		@grid = Array.new(9){Array.new}
		@grid.each_with_index{|row, row_index|   
			9.times{|col_index|
				row << cell = Sudoku_Cell.new(row_index, col_index)
				set(cell, 0)
			}
		}
	end
	
	def fill_cells
		find_empty_cells
		cell = @empty_cells[0]
		if cell
			if cell.possibles.length == 0
				p "gimmie a sec..."
				build_new_solution
			elsif cell.possibles.length == 1
				set(cell, cell.possibles[0])
				fill_cells
			else
				set(cell, cell.possibles[rand(cell.possibles.length)])
				fill_cells
			end
		else
			double_check
		end
	end
	
	def find_empty_cells
		@empty_cells = []
		@grid.each{|row|
			row.each{|cell|
				if cell.entry == 0
					find_possibles(cell)
					@empty_cells << cell
				end
			}
		}
		@empty_cells.sort!{|a, b| a.possibles.length <=> b.possibles.length}
	end
	
	def find_possibles(cell)
		row_entries = instance_variable_get("@row#{cell.row}").values 
		col_entries = instance_variable_get("@col#{cell.col}").values
		box_entries = instance_variable_get("@box#{cell.box}").values
		cell.possibles = [1, 2, 3, 4, 5, 6, 7, 8, 9] - (row_entries + col_entries + box_entries)
	end
	
	def set(cell, entry)
		cell.entry = entry
		instance_variable_get("@row#{cell.row}")[cell] = entry
		instance_variable_get("@col#{cell.col}")[cell] = entry
		instance_variable_get("@box#{cell.box}")[cell] = entry
	end
	
	def double_check
		ok = true
		9.times{|i|
			ok = false if instance_variable_get("@row#{i}").values.uniq! 
			ok = false if instance_variable_get("@col#{i}").values.uniq!
			ok = false if instance_variable_get("@box#{i}").values.uniq!
			ok = false if instance_variable_get("@row#{i}").values.include?(0)
			ok = false if instance_variable_get("@col#{i}").values.include?(0)
			ok = false if instance_variable_get("@box#{i}").values.include?(0)
		}
		if ok
			p "ok"
			output
			hide_cells
		else
			p "woah! double check failed! hang on..."
			build_new_solution
		end
	end
	
	def hide_cells
		rows = [0, 1, 2, 3, 4, 5, 6, 7, 8].shuffle
		cols = [0, 1, 2, 3, 4, 5, 6, 7, 8].shuffle
		
		rows.each{|r|
			cols.each{|c|
					cell = @grid[r][c]
					entry = cell.entry
					set(cell, 0)
					find_possibles(cell)
					if cell.possibles.length == 1
						cell.hidden_entry = entry
					else
						set(cell, entry)
					end
			}
		}
		
		p "..............................."
		output
		
		givens = []
		@grid.each{|r|
			r.each{|c|
				givens << c.entry unless c.entry == 0
			}
		}
		p "givens: #{givens.length}"
	end
	
	def output
		@solution = Array.new(9){Array.new}
		@grid.each_with_index{|row, index| row.each{|cell| @solution[index] << cell.entry}}
		@solution.each{|row| p row}
	end
	
end	#module Sudoku

#######################################
#######################################

 
 Shoes.app width: 296, height: 336, title: "Shoes Sudoku" do
	  App.class_eval{include Sudoku}
		
		def new_puzzle
			self.clear
			background gradient(rgb(30, 30, 30), black)
			init_puzzle
			@x = 10; @y = 10; @r = 0; @c = 0
			@hidden_cells = {}
			
			flow top: 295 do
				
				### this is weird, i know.  is there some easier way...
				steal_focus = check right: 100, width: 0, height: 0
				
				@check_while_playing = check left: 5, width: 25;  inscription "auto-check", stroke: gray
				@check_while_playing.click{steal_focus.focus}  ### ...to release the focus of this checkbox?
				
				button("new", right: 20, top: 5, height: 20) do
					new_ puzzle if confirm("start new game?")
				end
				
			end
			
			draw_puzzle
		end
		
		def draw_puzzle
			@clue = true
			grid.each{|r|
				r.each{|c|
					make_cell(c)
					@c += 1
					@x += 3 if @c % 3 == 0
				}
				@x = 10; @y += 30
				@r +=1
				@y += 3 if @r % 3 == 0
			}
			@clue = false
		end
		
		### this is weird too - but #hover and #leave don't always tell the truth
		def hovering?(slot)
			area = [(slot.left..(slot.left + slot.width)).to_a, (slot.top..(slot.top + slot.height))]
			pointer = [mouse[1], mouse[2]]
			if area[0].include?(pointer[0]) && area[1].include?(pointer[1])
				true
			else
				return false
			end
		end
		###
	
		def make_cell(cell)
			slot = stack width: 30, height: 30, top: @y, left: @x do
				draw_cell(cell.entry)
				@x += 30
			end
			if cell.entry == 0
				slot.hover{
					slot.append{border gradient(green, lime)}
					keypress{|entry| set_entry(slot, cell, entry) if hovering?(slot)}  ### doesn't work so well without #hovering?
																																																						 ### the 'hovering?' business...
				}
				slot.leave{slot.append{border black}}  ### ...even if i call 'keypress{}' in the leave block 
																																				### to avoid entries when the mouse is no longer over the cell
				@hidden_cells[slot] = cell
			end
		end
		
		def draw_cell(entry)
				background gradient(darkgray, gainsboro)
				border black
				num = para entry, align: "center" unless entry == 0
				num.weight = "bold" if num && @clue
		end
		
		def set_entry(slot, cell, entry)
			slot.clear
			if %q[1, 2, 3, 4, 5, 6, 7, 8, 9].include?(entry)
				slot.append{draw_cell(entry)}
				cell.entry = entry.to_i
				check_hidden_cells
			else
				slot.append{draw_cell(0)}
				cell.entry = 0
			end
		end
		
		def check_hidden_cells
			@complete = true
			@hidden_cells.each{|slot, cell|
				@complete = false if cell.entry == 0
				show_errors(slot, cell) if @check_while_playing.checked?
			}
			if @complete
				@hidden_cells.each{|slot, cell|
					unless cell.entry == cell.hidden_entry
						show_errors(slot, cell)
						@contains_errors = true
					else
						@contains_errors = false
					end
				}
				unless @contains_errors
					if confirm "nice one! play again?"
						new_puzzle
					end
				end
			end
		end
		
		def show_errors(slot, cell)
			slot.contents.each{|e|
				if e.class == Shoes::Para
					e.stroke = red unless cell.entry == cell.hidden_entry
				end
			}
		end
		
		new_puzzle
		
 end	#Shoes.app
 
