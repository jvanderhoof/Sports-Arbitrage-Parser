require 'activerecord'
require "yaml"

ActiveRecord::Base.establish_connection(YAML.load_file("config/database.yml"))

class Line < ActiveRecord::Base
  
  belongs_to :team
  belongs_to :game

  def to_s
    "team: #{self.team.name}, date: #{self.game.game_time}, spread: #{self.spread}, spread_vig: #{self.spread_vig},  money line: #{self.money_line}, over/under: #{self.over_under}, total points: #{self.total_points}, total points vig: #{self.total_points_vig}, browser_id: #{self.browser_id}"
  end
  
  def to_json
    return '{"team_id":"#{self.team.id}","game_id":"#{self.game.id}","browser_id":"#{self.browser_id}","money_line":"#{self.money_line}"}'
  end
  
  def change(past, current)
    change = past.to_f - current.to_f
    if change < 0
      return 1
    elsif change > 0
      return -1
    else
      return 0
    end
  end

	def equals(line)
	  equal = true
		if (self.spread != line.spread)
			puts "spread is different"
			line.spread_movement = change(self.spread, line.spread)
			equal = false
		end
		if (self.spread_vig != line.spread_vig)
			puts "spread vig is different"
			line.spread_vig_movement = change(self.spread_vig, line.spread_vig)
			equal = false
		end
		if (self.money_line != line.money_line)
		  line.money_line_movement = change(self.money_line, line.money_line)
			puts "money line is different"
			equal = false
		end
		if (self.over_under != line.over_under)
			puts "over under is different"
			equal = false
		end
		if (self.total_points != line.total_points)
			line.total_points_movement = change(self.total_points, line.total_points)
			puts "total points is different"
			equal = false
		end
		if (self.total_points_vig != line.total_points_vig)
			line.total_points_vig_movement = change(self.total_points_vig, line.total_points_vig)
			puts "total points vig is different"
			equal = false
		end
		return equal
	end

end
