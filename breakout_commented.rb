# a dumb little breakout game by lljk

# use the mouse or left and right keys to move the paddle
# space bar or left click to launch ball
# space bar while ball is moving to pause game


# First, we'll make widgets for the ball, bricks, paddle, and bonus stars

class BreakoutBall < Shoes::Widget
	attr_accessor :x, :y, :x_vec, :y_vec, :area
	
	def initialize(stroke_color, fill_color)
		stroke stroke_color
		fill fill_color
		oval(0, 0, 10)
	end
	
	def set_coords(x, y)
		@x = x; @y = y
		@area = [@x..(@x + 10), @y..(@y+10)]
		self.move(@x, @y) # the `move` method is a handy one...
	end
	
	def set_vectors(x, y)
		@x_vec = x
		@y_vec = y
	end
	
end		#BreakoutBall


class BreakoutBrick < Shoes::Widget
	attr_accessor :x, :y, :area, :value, :special
	
	def initialize(value, special=false)
		@special = special
		@value = value
		
		case value
			when 10
				stroke_color = darkslategray
				fill_color = gray
			when 25
				stroke_color = indigo
				fill_color = purple
			when 50
				stroke_color = darkgoldenrod
				fill_color = gold
		end
		
		strokewidth 2
		stroke stroke_color
		fill fill_color
		rect(0, 0, 40, 20, 3)
	end
	
	def set_coords(x, y)
		@x = x; @y = y
		@area = [@x..(@x + 40), @y..(@y+20)]
		self.move(@x, @y)
	end
	
	def special?
		@special
	end
	
end		#BreakoutBrick


class BreakoutPaddle < Shoes::Widget
	attr_accessor :x, :y, :width, :area
	
	def initialize(w)
		@width = w
		stroke lime
		fill green
		rect(0, 0, @width, 10, 3)
	end
	
	def set_coords(x, y)
		@x = x; @y = y
		@area = [@x..(@x + @width), @y..(@y+10)]
		self.move(@x, @y)
	end
	
end		#BreakoutPaddle


class BreakoutBonusStar < Shoes::Widget
	attr_accessor :x, :y, :type
	
	def initialize(type)
		@type = type
		case type
			when "expand-paddle"
				stroke_color = gold; fill_color = green
			when "slow-down"
				stroke_color = crimson; fill_color = yellow
			when "multi-ball"
				stroke_color = darkorange; fill_color = red
		end
		
		stroke stroke_color
		fill fill_color
		@bonus_star= star(0, 0, 5, 10, 5)
		@bonus_star.hide # we want to hide the star until its coordinates are set
	end
	
	def set_coords(x, y)
		@x = x; @y = y
		self.move(@x, @y)
		@bonus_star.show # now we can show it
	end
	
end		#BreakoutBonusStar


###########################

# ...and now the main app...

Shoes.app do
	
	def init_game
		@lives = 3
		@score = 0
		@level = 1
		@bricks = []
		@wall_rows = 5
		@bg_colors = [midnightblue, blueviolet, darkblue, darkgoldenrod,
			darkslateblue, darkslategray, olive, indigo, maroon, orangered]
		
		@status_area = flow top: 0, height: 30
		@main = flow
		# we'll append stuff to the @status_area and @main slots later...
		
		set_background
	end
	
	def set_background # we'll set a random background color for each level
		clr = @bg_colors[rand(@bg_colors.length)]
		bg = gradient(clr, black) # the `gradient` method creates, well,  a gradient
		status_bg = gradient(black, clr)

		@status_area.background(status_bg) # the `background` method does what you'd expect
		@status_area.border(white) # ...as does the `border` method
		update_status_bar(@lives, @level, @score)

		bg = @main.background(bg)
		bg.top = 30 # we've got to drop the @main background down to account for the @status_area
	end
	
	def update_status_bar(lives, level, score)
		@status_bar.remove if @status_bar
		@status_area.append{
			@status_bar = para "Lives: #{@lives}     Level: #{@level}     Score: #{@score}", stroke: white, align: "center", top: 2
		}
		# for some reason using the #text= method doesn't work after setting the background,
		# so we'll just get rid of the @status_bar para with the `remove` method, and make a new one
	end
	
	def start_up
		if @timer
			@timer.stop; @timer = nil
		end
		if @bonus_timer
			@bonus_timer.stop; @bonus_timer = nil
		end
		@ball = nil
		@falling_stars = []
		
		# notice that the BreakoutBall widget is called with `breakout_ball`,
		@main.append{@ball = breakout_ball(lime, silver)}
		@ball.set_coords(320, 459)
		@ball.set_vectors(1, -5)
		
		# and the BreakoutPaddle with `breakout_paddle` - Shoes magic...
		@main.append{@paddle = breakout_paddle(40)}
		@paddle.set_coords(300, 470)
		
		@balls = [@ball]
	end
	
	def make_new_wall(height)
		@bricks.clear
		@pattern = []
		@values = [10, 10, 10, 25, 25, 50]
		
		# to make the wall, first we make a random symetrical array of  1's and 0's,
		# and randomly assign a value to each brick
		height.times{
			@half_row = []
			@row = []
			len = (rand(6) + 2) * 2
			(len / 2).times{
				entry = [rand(2), @values[rand(6)]]
				@half_row << entry
			}
			@half_row.each{|e| @row << e}
			@half_row.reverse.each{|e| @row << e}
			@pattern << @row
		}
		
		# then we draw a brick with a certain value wherever there's a 1 in our array
		y = 80
		@pattern.each{|row|
			x = (600 - (row.length * 42)) / 2
			row.each{|entry|
				case entry[0]
					when 1
					@main.append{
						brick = breakout_brick(entry[1])
						brick.set_coords(x, y)
						@bricks << brick
					}
				end
				x += 42
			}
			y += 22
		}
		
		# and now we make 3 of those bricks 'special'
		3.times{@bricks[rand(@bricks.length)].special= true}
	end
	
	# the rest of this is basically just plain old ruby...
	
	def intersect?(range1, range2)
		range2.to_a.each{|n|
			if range1.include?(n)
				return true; break
			end
		}
		return false
	end
	
	def possible_hit?(ball)
		low_y = @bricks[-1].area[1].to_a[-1] + 30
		if ball.y > 440 || ball.y < low_y || ball.x > 570 || ball.x < 30
			return true
		else
			return false
		end
	end
	
	def check_hits(ball)
		# a Shoes app is 600 x 500 pixels by default, and our @status area is 30 pixels high,
		# so we'll use those numbers as the limits for the ball
		ball.x_vec = ball.x_vec.abs if ball.x < 1
		ball.x_vec = ball.x_vec.abs * -1 if ball.x > 589
		ball.y_vec = ball.y_vec.abs if ball.y < 41
		
		# the paddle's y coordinate is 470, remember? so....
		if ball.y > 459 && intersect?(@paddle.area[0], ball.area[0])
			p_center = @paddle.x + (@paddle.width / 2)
			b_center = ball.x + 5
			ball.x_vec = ((b_center - p_center) / 3).round
			ball.y_vec *= -1
		end
	
		@bricks.each{|brick|
			if brick.area[1].include?(ball.y) && intersect?(brick.area[0], ball.area[0])
				ball.y_vec *= -1
				special_brick(brick) if brick.special
				brick.remove
				@score += brick.value
				update_status_bar(@lives, @level, @score)
				@bricks.delete(brick)
				new_level if @bricks.empty?
				break
			end
		}
	end
	
	def move_ball
		@moving = true
		get_faster = 0
		@timer = animate(16){ # do this 16 times a second...
			@balls.each{|ball|
				check_hits(ball) if possible_hit?(ball)
				get_faster += 1
				if get_faster == 80
					if ball.x_vec < 0
						ball.x_vec -= 1
					else
						ball.x_vec += 1
					end
					if ball.y_vec < 0
						ball.y_vec -= 1 unless ball.y_vec < -28
					else
						ball.y_vec += 1 unless ball.y_vec > 28
					end
					get_faster = 0
				end
				ball.x += ball.x_vec
				ball.y += ball.y_vec
				
				ball.set_coords(ball.x, ball.y)
				
				if ball.y > 490
					ball.remove
					@balls.delete(ball)
					if @balls.empty?
						@timer.stop; @timer = nil
						@moving = false
						@lives -= 1
						update_status_bar(@lives, @level, @score)
						if @lives == 0
							game_over
						else
							@balls.each{|ball| ball.remove; ball = nil}
							@balls = []
							@paddle.remove
							@falling_stars.each{|bonus_star| bonus_star.remove; bonus_star = nil}
							@falling_stars.clear
							start_up
						end
					else
						ball.remove
						@balls.delete(ball)
						ball = nil
					end
				end
			}
		}
	end

	def new_level
		@timer.stop; @timer = nil
		if @bonus_timer
			@bonus_timer.stop; @bonus_timer = nil
		end
		@moving = false
		@balls.clear		
		@main.clear
		
		salutations = ["Hey There", "Woah", "Nice One", "Well Done", "Awesome"]
		names = ["Dude", "Buddy", "Pal", "Friend", "Amigo"]
		actions = ["Rocked", "Destroyed", "Annihilated", "Kicked Butt On", "Creamed"]
		
		@main.background(black)
		@main.append{
			title "#{salutations[rand(5)]} #{names[rand(5)]}, 
You #{actions[rand(5)]} Level #{@level}!
On To Level #{@level + 1}...", stroke: white, align: "center", top: 70
		}
		
		timer(2){ # the `timer` method calls its block once, after the specified time (in seconds) 
			@main.clear # `clear` removes everything from a slot
			@wall_rows += 1 unless @wall_rows == 10
			@level += 1
			set_background
			start_up
			make_new_wall(@wall_rows)
			update_status_bar(@lives, @level, @score)
		}
	end
	
	def game_over
		@moving = true
		@timer.stop; @timer = nil
		if @bonus_timer
			@bonus_timer.stop; @bonus_timer = nil
		end
		
		banner "GAME OVER", top: 90, align: "center", stroke: lime
		para "press space to restart", top: 170, align: "center", stroke: lime
		
		keypress{|key|
			if key == " "
				@status_area.remove
				init_game
				start_up
				make_new_wall(@wall_rows)
				@moving = false
			end
		}
	end
	
	def special_brick(brick)
		x = brick.x + 20; y = brick.y
		bonus_types = ["expand-paddle", "slow-down", "multi-ball"]
		bonus_type = bonus_types[rand(3)]
		
		@main.append{
			bonus_star = breakout_bonus_star(bonus_type)
			@falling_stars << bonus_star
			bonus_star.x = x; bonus_star.y = y
		}
		unless @bonus_timer
			@bonus_timer = animate(16){
				unless @moving
					if @bonus_timer
						@bonus_timer.stop; @bonus_timer = nil
					end
					@falling_stars.each{|bonus_star| bonus_star.remove; bonus_star = nil}
					@falling_stars.clear
				else
					@falling_stars.each{|bonus_star|
						bonus_star.y += 2
						bonus_star.set_coords(bonus_star.x, bonus_star.y)
				
						if bonus_star.y > 465 && bonus_star.y < 485 && @paddle.area[0].include?(bonus_star.x)
							bonus_star.remove
							@falling_stars.delete(bonus_star)
							if @falling_stars.empty?
								@bonus_timer.stop; @bonus_timer = nil
							end
							award_bonus(bonus_star)
						elsif bonus_star.y > 499
							bonus_star.remove
							@falling_stars.delete(bonus_star)
							if @falling_stars.empty?
								@bonus_timer.stop; @bonus_timer = nil
							end
						end
					}
				end
			}
		end
	end
	
	def award_bonus(bonus_star)
		@score += 100
		update_status_bar(@lives, @level, @score)

		bonus_type = bonus_star.type
		case bonus_type
			when "expand-paddle"
				unless @paddle.width == 60
					x = @paddle.x -= 10
					@paddle.remove
					@main.append{@paddle = breakout_paddle(60)}
					@paddle.set_coords(x, 470)
				end
			when "slow-down"
				@balls.each{|ball|
					ball.x_vec = (ball.x_vec * 0.5).round unless ball.x_vec.abs < 3
					ball.y_vec = (ball.y_vec * 0.5).round unless ball.y_vec.abs < 3
				}
			when "multi-ball"
				@main.append{
					@ball1 = breakout_ball(lime, silver)
					@ball1.set_coords(@balls[0].x - 5, @balls[0].y)
					@ball1.set_vectors(@balls[0].x_vec.abs * -1, @balls[0].y_vec.abs * -1)
					@ball2 = breakout_ball(lime, silver)
					@ball2.set_coords(@balls[0].x + 5, @balls[0].y)
					@ball2.set_vectors(@balls[0].x_vec.abs, @balls[0].y_vec.abs * -1)
				}
				@balls << @ball1; @balls << @ball2
		end
	end
	
	
	init_game
	start_up
	make_new_wall(@wall_rows)
	
	
	keypress{|key|
		case key
			when :left; @paddle.x -= 5  
			when :right; @paddle.x += 5
			when " "
			if @moving
				if @paused
					@timer.start
					@bonus_timer.start if @bonus_timer
					@paused = false
				else
					@timer.stop
					@bonus_timer.stop if @bonus_timer
					@paused = true
				end
			else
				move_ball
				@moving = true
			end
		end
		@paddle.set_coords(@paddle.x, 470)
		unless @moving
			@ball.x = @paddle.x + (@paddle.width / 2) + 2
			@ball.set_coords(@ball.x, 459)
		end
	}
	
	motion{|left, top|
		x = left - (@paddle.width / 2)
		@paddle.set_coords(x, 470)
		unless @moving
			@ball.x = left + 2
			@ball.set_coords(@ball.x, 459)
		end
	}
	
	click{|b| move_ball unless @moving}
	
	
end		#Shoes.app
