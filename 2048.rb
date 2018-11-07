#! ruby

$KEY_CONV = {
"z" => "u",
"s" => "d",
"q" => "l",
"d" => "r"
}
$OPPOSITE = {
"u" => "d",
"d" => "u",
"l" => "r",
"r" => "l"
}
$START_POS = {
"u" => [0,1,2,3],
"d" => [12,13,14,15],
"l" => [0,4,8,12],
"r" => [3,7,11,15]
}


class Cell
	attr_accessor :value, :neighbors, :x, :y
	def initialize(x,y)
		@x = x
		@y = y
		@value = 0
		@neighbors = {
			"u" => nil,
			"d" => nil,
			"l" => nil,
			"r" => nil
		}
	end
	def to_s
		@value.to_s.center(6)
	end
	
	def movable(d)
		n = @neighbors[d]
		res = @value != 0 and n != nil and (n.value == 0 or n.value == @value)
		res
	end
end

class Game
	def initialize
		@grid = Array.new(16) {|i| Cell.new(i % 4, i / 4) }
		@grid.each_with_index do |c, i|
			x = i % 4
			y = i / 4	
			c.neighbors["l"] = @grid[(x - 1) + y * 4] if x > 0 
			c.neighbors["r"] = @grid[(x + 1) + y * 4] if x < 3 
			c.neighbors["u"] = @grid[x + (y - 1) * 4] if y > 0 
			c.neighbors["d"] = @grid[x + (y + 1) * 4] if y < 3 
		end
	end
	
	def new_cell
		val = rand() < 0.9 ? 2 : 4
		available = @grid.select {|c| c.value == 0 }
		return false if available.empty?
		i = rand() * available.size
		available[i].value = val
		return false unless @grid.any?{|c| c.movable("u") or c.movable("d") or c.movable("l") or c.movable("r") }
		true
	end
	
	def shift(c,d)
		changes = false
		while n = c.neighbors[d]
			changes ||= (c.value != n.value)
			c.value = n.value
			c = n
		end
		c.value = 0
		changes
	end
	
	def update(key)
		return false unless $KEY_CONV.has_key?(key)
		dir = $KEY_CONV[key]
		return false unless @grid.any?{|c| c.movable(dir) }
		
		$START_POS[dir].each do |x|
			c = @grid[x]
			changes = false
			while c != nil
				if c.value == 0
					break unless self.shift(c, $OPPOSITE[dir])
					c = @grid[x]
				end
				if c.value != 0
					if (n = c.neighbors[$OPPOSITE[dir]]) and c.value == n.value
						c.value = c.value * 2
						n.value = 0
						changes = true
					end
					c = c.neighbors[$OPPOSITE[dir]]
				end
			end 
		end	
		true
	end
	
	def to_s
		s = "-" * (4 * 7 + 2) + "\n"
		@grid.each_slice(4) do |r|
			s += "|" + r.map {|c| c.to_s}.join("|") + "|\n"
		end
		s+= "-" * (4 * 7 + 2) + "\n"
	end
end

game = Game.new
game.new_cell

while game.new_cell
	puts game
	key = STDIN.gets.chomp
	until game.update(key)
	end
end
puts "end"