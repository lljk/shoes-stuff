require "observer"

class Publisher
	include Observable
	attr_reader :shot
	def initialize
		@hits = [1, 3, 5, 7, 9]
	end
	
	def shoot
		50.times{|n|
			@shot = rand(10)
			if @hits.include?(@shot)
				changed
				notify_observers(n, @shot)
			end
		}
	end
	
end

Shoes.app do

	pub = Publisher.new

	def update(n, shot)
		para "shot ##{n} => #{shot}\n"
	end
	
	pub.add_observer(self)
	pub.shoot
	
end