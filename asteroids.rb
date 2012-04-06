# asteroids game by lljk
# have fun!


class LaserBulletThing < Shoes::Widget
	attr_accessor :x, :y, :x_vec, :y_vec
	def initialize(x, y)
		@x = x; @y = y
		@x_vec = 0; @y_vec = 0
		fill lime; oval(0, 0, 5)
		self.move(@x, @y)
	end	
end		#LaserBulletThing


class FirstClassFlyingShip < Shoes::Widget
	attr_accessor :center_x, :center_y, :shots, :paused
	
	def initialize(x, y)
		@paused = false
		@x = x - 10; @y = y - 12
		@center_x = x; @center_y = y
		@shots = []
		@x_vec = 0; @y_vec = 0
		@start_angle = 0
		@rotate_by = 0
		@slot = stack fill: black, stroke: lime
		@slot.move(@x, @y)
		draw_ship

		motion{|x, y|
			unless @paused
				@rads = Math.atan2(y - @center_y, x - @center_x)
				degs = 270 - (@rads * (180 / Math::PI)).round(2)
			
				@rotate_by = degs - @start_angle
				@start_angle = degs
			
				draw_ship
			end
		}
		
		#put this bit in a slot, or it won't work
		stack width: 700, height: 600, top: 0, left: 0 do
			click{|btn, x, y|
				unless @paused
					shoot if btn == 1
					if btn == 3
						@x_vec += 1 if x > @x + 20
						@x_vec -= 1 if x < @x
						@y_vec +=1 if y > @y + 24
						@y_vec -= 1 if y < @y
					end
				end
			}
		end
	end	#init
	
	def draw_ship
		@slot.clear
		@slot.append{
			rotate @rotate_by
			@ship = shape{
				move_to(10, 0)
				line_to(20, 24)
				line_to(10, 20)
				line_to(0, 24)
				line_to(10, 0)
			}
		}
	end
	
	def move_ship
		@x += @x_vec
		@y += @y_vec
		@x = 0 if @x > 700; @y = 0 if @y > 600
		@x = 700 if @x < 0; @y = 600 if @y < 0
		@center_x = @x + 10; @center_y = @y + 12
		@slot.move(@x, @y)
		draw_shots unless @shots.empty?
	end
	
	def shoot
		if @rads
		bullet_x = ((15 * Math.cos(@rads)) + @center_x).round
		bullet_y = ((15 * Math.sin(@rads)) + @center_y).round
		
		bullet = laser_bullet_thing(bullet_x, bullet_y)
		
		bullet.x_vec = bullet_x - @center_x
		bullet.y_vec = bullet_y - @center_y
		
		@shots << bullet
		end
	end
	
	def draw_shots
		@shots.each{|bullet|
			bullet.x += bullet.x_vec
			bullet.y += bullet.y_vec
			
			if bullet.x < 0 || bullet.x > 695 || bullet.y < 0 || bullet.y > 595
				bullet.remove
				@shots.delete(bullet)
			else
				bullet.move(bullet.x, bullet.y)
			end
		}
	end
end		#Ship


class Asteroid < Shoes::Widget
	attr_accessor :x, :y, :x_vec, :y_vec, :size, :area
	
	def initialize(size, x, y)
		@size = size
		@x_vec = 0; @y_vec = 0
		until @x_vec != 0
			@x_vec = (30 / size).round + ((rand(5) - 2) * (rand(3) - 1))
		end
		until @y_vec != 0
			@y_vec = (30 / size).round + ((rand(5) - 2) * (rand(3) - 1))
		end
		
		x1 = rand(size * 0.1).round + (size * 0.1); y1 = rand(size * 0.1).round + (size * 0.1)
		x2 = x1 + rand(size * 0.4).round; y2 = 0
		x3 = size - (rand(size * 0.1).round + (size * 0.1)); y3 = rand(size * 0.1).round + (size * 0.1)
		x4 = size - (rand(size * 0.1).round + (size * 0.1)); y4 = rand(size * 0.1).round + (size * 0.1)
		x5 = size; y5 = y4 + rand(size * 0.4).round
		x6 = size - (rand(size * 0.1).round + (size * 0.1)); y6 = size - (rand(size * 0.1).round + (size * 0.1))
		x7 = size - (rand(size * 0.1).round + (size * 0.1)); y7 = size - (rand(size * 0.1).round + (size * 0.1))
		x8 = x7 - rand(size * 0.4).round; y8 = size
		x9 = rand(size * 0.1).round + (size * 0.1); y9 = size - (rand(size * 0.1).round + (size * 0.1))
		x10 = rand(size * 0.1).round + (size * 0.1); y10 = size - (rand(size * 0.1).round + (size * 0.1))
		x11 = 0; y11 = y10 - rand(size * 0.4).round
		x12 = rand(size * 0.1).round + (size * 0.1); y12 = rand(size * 0.1).round + (size * 0.1)
		
		@slot = stack top: 30, do
			shape{
				fill black
				stroke lime
				move_to(x1, y1)
				line_to(x2, y2)
				line_to(x3, y3)
				line_to(x4, y4)
				line_to(x5, y5)
				line_to(x6, y6)
				line_to(x7, y7)
				line_to(x8, y8)
				line_to(x9, y9)
				line_to(x10, y10)
				line_to(x11, y11)
				line_to(x12, y12)
				line_to(x1, y1)
			}
		end
		set_coords(x, y)
	end
	
	def set_coords(x, y)
		x = 0 if x > 700; x = 700 if x < 0 - @size
		y = 0 if y > 600; y = 600 if y < 0
		@x = x; @y = y
		@area = [@x..(@x + @size), @y..(@y + @size)]
		self.move(@x, @y)
	end
	
	def move_asteroid
		x = @x + @x_vec; y = @y + @y_vec
		set_coords(x, y)
	end
	
	def check_hits(x, y)
		if @area[0].include?(x) && @area[1].include?(y)
			@hit = true
		end
	end
	
	def hit?
		@hit
	end
	
end		#Asteroid


#######################


Shoes.app width: 700, height: 630 do
	
	background black
	
	def init_game
		@lives = 3
		@score = 0
		@level = 1
		@rocks = []
		@game_over = false
		
		status_area = flow height: 30 do
			border lime
			@status_info = para " ", stroke: lime, align: "center", top: 2
		end
		
		init_level(1)
	end
	
	def init_level(level)
		update_status(@lives, @score, @level)
		
		unless @rocks.empty?
			@rocks.each{|rock| rock.remove}
			@rocks.clear
		end
		
		unless @level == 1 || @no_congrats
			salutations = ["Hey There", "Woah", "Nice One", "Well Done", "Awesome"]
			names = ["Dude", "Buddy", "Pal", "Friend", "Amigo"]
			actions = ["Rocked", "Destroyed", "Annihilated", "Kicked Butt On", "Creamed"]
			
			self.append{
				@congrats = title "#{salutations[rand(5)]} #{names[rand(5)]}, 
You #{actions[rand(5)]} Level #{@level - 1}!
On To...", stroke: lime, align: "center", top: 100
			}
			
			timer(3){@congrats.remove}
		end
		
		self.append{
			@level_info = banner "level #{@level}", stroke: lime, align: "center", top: 280
		}
		
		timer(3){
			@level_info.remove
			self.append{@ship = first_class_flying_ship(350, 300)}
			n = @level
			n.times{
				self.append{@rock = asteroid(60, rand(80) - 70, rand(80) - 70)}
				@rocks << @rock
			}
			@no_congrats = false
			start_motion
		}
	end
	
	def update_status(lives, level, score)
		@status_info.text = "lives: #{@lives}          score: #{@score}          level: #{@level}"
	end
	
	def break_rock(size, x, y)
		case size
			when 60
			self.append{@rock1 = asteroid(30, x + 25, y)}
			self.append{@rock2 = asteroid(30, x -25, y)}
			@rocks << @rock1 << @rock2
			@score += 25
			when 30
			self.append{@rock1 = asteroid(15, x + 25, y)}
			self.append{@rock2 = asteroid(15, x - 25, y)}
			self.append{@rock3 = asteroid(15, x, y - 25)}
			@rocks << @rock1 << @rock2 << @rock3
			@score += 50
			when 15
			@score += 100
		end
		update_status(@lives, @score, @level)
		new_level if @rocks.empty?
	end
	
	def new_level
		@game_motion.stop
		@level += 1
		update_status(@lives, @score, @level)
		@ship.remove
		init_level(@level)
	end
	
	def destroy_ship
		@game_motion.stop
		@ship.remove
		@debris = []

		fill lime
		50.times{
			blasted_bit = oval(@ship.center_x + (rand(51) - 25), (@ship.center_y + (rand(51) - 25) + 30), 3)
			@debris << blasted_bit
		}

		@lives -= 1
		update_status(@lives, @score, @level)
		if @lives == 0
			game_over
		else
			@no_congrats = true
			timer(3){
				@debris.each{|bit| bit.remove}
				init_level(@level)
			}
		end
	end
	
	def game_over
		@game_over = true
		
		sorry = stack width: 700 do
			banner "GAME OVER", stroke: lime, align: "center"
			title "press space to restart", stroke: lime, align: "center"
		end
		
		sorry.move(0, 200)
		
		keypress{|key|
			if key == " " && @game_over
				clear
				init_game
			end
		}
	end
	
	def start_motion
		@game_motion = animate(16){
			@ship.move_ship
			@rocks.each{|rock|
				rock.move_asteroid
				rock.check_hits(@ship.center_x, @ship.center_y)
				if rock.hit?
					destroy_ship
				end
			}
			
			unless @ship.shots.empty?
				@ship.shots.each{|bullet|
					@rocks.each{|rock|
						rock.check_hits(bullet.x, bullet.y)
						if rock.hit?
							@rocks.delete(rock); rock.remove
							@ship.shots.delete(bullet); bullet.remove
							break_rock(rock.size, rock.x, rock.y)
						end
					}
				}
			end
		}
	end
	
	@first_run = true
	
	intro = stack width: 700 do
		banner "ASTEROIDS!\n", stroke: lime, align: "center"
		para "move mouse to rotate ship", stroke: lime, align: "center"
		para "use right mouse button to accelerate towards the pointer", stroke: lime, align: "center"
		para "use left mouse button to shoot\n\n", stroke: lime, align: "center"
		title "press space to start and pause", stroke: lime, align: "center"
	end
	
	intro.move(0, 100)
	
	keypress{|key|
		if key == " "
			if @first_run
				clear
				init_game
				@first_run = false
			elsif @paused
				@pause_message.remove
				@game_motion.start; @paused = false; @ship.paused = false
			else
				@game_motion.stop; @paused = true; @ship.paused = true
				@pause_message = stack width: 700 do
					title "paused", stroke: lime, align: "center"
				end
				@pause_message.move(0, 200)
			end
		end
	}
	
end