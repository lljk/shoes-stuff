require 'observer'

class ListManager < Shoes::Widget
	include Observable
  def initialize(array)
		@selected = []
		self.show(array)
		keypress{|k|
			case k.to_s.downcase
				when 'up'
					@selected.each{|entry|
						i = array.index(entry)
						array.delete_at(i)
						i -= 1
						array.insert(i, entry)
					}
					@s.clear
					self.show(array)
				when 'down'
					@selected.each{|entry|
						i = array.index(entry)
						array.delete_at(i)
						i += 1
						i = 0 if i > array.length
						array.insert(i, entry)
					}
					@s.clear
					self.show(array)
			end
		}
	end
	
	def show(array)
		@s = stack{
			array.each{|item|
				if @selected.include?(item)
					cell = link(File.basename(item), stroke: yellow, underline: "none")
				else
					cell = link(File.basename(item), stroke: gray, underline: "none")
				end
				cell.hover{cell.style(fill: blue)}
				cell.leave{cell.style(fill: black)}
				cell.click{
					if @selected.include?(item)
						cell.style(stroke: gray)
						changed
						notify_observers("unselect:#{item}")
					else
						@selected << item
						cell.style(stroke: yellow)
						changed
						notify_observers(item)
					end
				}
				para cell
			}
		}
  end
end	#class ListManager

class PlayList < Shoes::Widget
	include Observable
	def initialize(h)
		@selected = []
		th = (h * 0.9).round.to_i
		bh = (h * 0.1).round.to_i
		@top = stack width: 1.0, height: th, scroll: true
		bottom = stack width: 1.0, height: bh, stroke: gray
		
		bottom.append{
			pb = button("play"){
				changed
				notify_observers("PL:play:#{@selected}")
			}
			pb.style(top: 10)
		}
	end
	
	def add(list)
		@top.append{
			lm = list_manager(list)
			lm.add_observer(self)
		}
	end
	
	def update(message)
		if message.include?("unselect")
			index = message.split(":")[-1]
			@selected.delete(index)
		else
		@selected << message
		end
	end
end	#class PlayList


Shoes.app title: "main" do
	
	r = (1..25)
	@list = []
	r.each{|n| @list << "entry ##{n}"}
	
	def update(message)
		case
			when message.include?("PL:play")
			selected = message.split(":")[-1]
			play(selected)
		end
	end
	
	def playlist(parent, list)
		window do
			pl = play_list(self.height)
			pl.add(list)
			pl.add_observer(parent)
		end
	end
	
	def play(selected)
		para "play: #{selected}", stroke: gray
	end
	
	button("playlist"){playlist(self, @list)}
	
end #Shoes.app