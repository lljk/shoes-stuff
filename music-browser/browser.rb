require 'observer'

class BrowserListManager < Shoes::Widget
	include Observable
	
  def initialize(array, selected=[])
		@selected = selected
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


class DirBrowser < Shoes::Widget
	include Observable
	
	def initialize(path)
		@homedir = File.expand_path(File.dirname(__FILE__))
		@leftpane = stack width: 200, height: 500
		@rightpane = flow width: -205, height: 500, scroll: true
		self.pathscan(path)
	end
	
	def pathscan(path)
		@leftpane.clear
		@rightpane.clear
		okfiles = %W[.mp3 .flac .ogg .wav]
		dirs = []
		files = []
		Dir.open(path){|dir|
			for entry in dir
				next if entry == '.'
				next if entry == '..'
				item = path + File::Separator + entry
				if File.directory?(item)
					dirs << item
				else
					okfiles.each{|ok| files << item if item.downcase.include?(ok)}
				end
			end
		}
		self.leftSide(path)
		@dirs = dirs.sort
		self.rightSideDirs(@dirs) if @dirs[0] != nil
		@files = files.sort
		@selected = []
		self.rightSideFiles(@files, @selected) if @files[0] != nil
	end
	
	def leftSide(path)
		self.getImage(path)
		@leftpane.append{
			para path, stroke: gray, width: 180, align: "center"
		}
		@leftpane.append{img = image(@img)
			img.style(width: 180, height: 180, displace_left: 10, top: 140)
			img.click{
				if @files[0] != nil
					@files.each{|f| @selected << f}
					self.rightSideFiles(@files, @selected)
				end
			}
		}
		@leftpane.append{btn = button("up"){
				new = File.split(path)[0]
				self.pathscan(new)
			}
			btn.style(top: 420, displace_left: 80)
		}
	end
	
	def rightSideDirs(dirs)
		dirs.each{|d|
			self.getImage(d)
			@rightpane.append{
				s = stack width:200 do
				i = image(@img)
				i.style(width: 190, height: 190, align: "center")
				para File.basename(d), stroke: gray, align: "center"
				end
				s.click{self.pathscan(d)}
			}
		}
	end
	
	def rightSideFiles(files, selected)
		@rightpane.clear
		@rightpane.append{
			th = (parent.height * 0.9).round.to_i
			bh = (parent.height * 0.1).round.to_i
			top = stack width: 1.0, height: th, scroll: true
			bottom = stack width: 1.0, height: bh, stroke: gray
		
			top.append{
				lm = browser_list_manager(files, selected)
				lm.add_observer(self)
			}
			
			bottom.append{
				btns = flow{
					button(">> list"){
						changed
						notify_observers("DB:prepend:#{@selected}")
						@selected = []
						self.rightSideFiles(files, @selected)
					}
					button("list <<"){
						changed
						notify_observers("DB:append:#{@selected}")
						@selected = []
						self.rightSideFiles(files, @selected)
					}
				}
				btns.style(top: 10, left: 20)
			}
		}
	end
	
	def getImage(path)
		Dir.chdir(path)
		imgfiles = Dir['*.{jpg,JPG,png,PNG,gif,GIF}']
		imgfile = imgfiles[0]
		imgfile = "nofile.jpg" if imgfile == nil
		if File.exist?(imgfile)
			@img = path + File::Separator + imgfile
		else
			@img = @homedir + File::Separator + "no_cover.jpg"
		end
	end
	
	def update(message)
		if message.include?("unselect")
			index = message.split(":")[-1]
			@selected.delete(index)
		else
		@selected << message
		end
	end
	
end	#class DirBrowser


Shoes.app title: "main"do
	
	def update(message)
		para message, stroke: gray
	end
	
	def browser(parent, basedir)
		window width: 820 do
			b = dir_browser(basedir)
			b.add_observer(parent)
		end
	end
	
	button("browser"){browser(self, "/home/jk/tunes")} ## CHANGE THIS!
	
end	#Shoes.app
