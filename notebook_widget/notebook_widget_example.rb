class Page < Shoes::Widget
	attr_accessor :body
	
	def initialize(name)
		@name = name
		@body = flow
		@body.hide
	end
	
	def add
		@body.append{yield}
	end
	
end


class NoteBook < Shoes::Widget
	attr_reader :pages
	
	def initialize(first_page)
		@pages = {}
		
		@f = flow width: self.parent.width, height: 50, displace_top: 0

		add_page(first_page)
		@pages[first_page].body.show
	end

	def add_page(name)
		@f.append{@tab = button(name)}
		
		@pages[name] = page(name)
		
		@tab.click{
			@pages.each{|k, v| v.body.hide}
			@pages[name].body.show
		}
	end
	
end


Shoes.app do
	
	nb = note_book("tiddlywinks")
	nb.pages["tiddlywinks"].add{
		10.times{para "tiddlywinks!! ", stroke: red}
	}
	
	nb.add_page("seamonkeys")
	nb.pages["seamonkeys"].add{
		100.times{para "seamonkeys!!", stroke: blue}
	}
	
		nb.pages["tiddlywinks"].add{
		10.times{para "more tiddlywinks!! ", stroke: orange}
	}
	
end
