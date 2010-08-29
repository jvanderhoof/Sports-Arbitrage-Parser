require 'lib/browser'

class PinnacleBrowser < Browser
	
  def scrape(page, sport)
	  temp_file = "temp/pinnacle_temp.txt"
    web_page = @client.get_content(@url+page)
    File.open(temp_file, 'w') {|f| f.write(web_page) }    
	  parse(temp_file, sport)
  end
	
	def normalize(name)
    translations = {'No Illinois' => 'Northern Illinois',
                    'Nevada' => 'Nevada Reno'}
    if translations.key?(name)
      name = translations[name]
    end
    name = Normalizer.replace_abbreviation(Normalizer.strip_characters(name))
    return name
  end
	
  def parse(file, sport)
		doc = open(file) { |f| Hpricot(f) }

		summary = (doc/"table")
		teams = []

		summary.search("tr").each do |row|  
			columns = (row/"td")
			if columns.size > 5
				teams << columns
			end
		end

		i = 0
		while i<teams.size
			game_date = teams[i][0].inner_html

      full_date_parts = game_date.split(" ")
			now = DateTime::now()
			date_str = full_date_parts[1] + "/#{now.year}"
			date = DateTime.parse(date_str, '%m/%d/%Y')
			if date.month.to_i == 1 && now.month.to_i == 12
				date_str = full_date_parts[1] + "/#{now.year+1}"
  			date = DateTime.parse(date_str, '%m/%d/%Y')
			end
			
			unless teams[i][3].inner_html.eql?("Offline")
				spread_parts1 = teams[i][3].inner_html.gsub("&nbsp;", " ").split(" ")
				spread_parts2 = teams[i+1][3].inner_html.gsub("&nbsp;", " ").split(" ")
				
				points_parts1 = teams[i][5].inner_html.gsub("&nbsp;", " ").split(" ")
				points_parts2 = teams[i+1][5].inner_html.gsub("&nbsp;", " ").split(" ")

			  line1 = Line.new
			  team1 = Normalizer.strip_characters(teams[i][2].inner_html.gsub("&nbsp;", ""))
			  if 5 == sport.to_i || 4 == sport.to_i
			    team1 = normalize(team1)
		    end
			  line1.team_id = get_team_id(team1, sport)
			  line1.spread = spread_parts1[0]
			  line1.spread_vig = spread_parts1[1]
			  line1.money_line = teams[i][4].inner_html
			  line1.over_under = points_parts1[0]
			  line1.total_points = points_parts1[1]
			  line1.total_points_vig = points_parts1[2]
			  line1.browser_id = @site_id

			  line2 = Line.new
			  team2 = Normalizer.strip_characters(teams[i+1][2].inner_html.gsub("&nbsp;", ""))
			  if 5 == sport.to_i || sport.to_i
			    team2 = normalize(team2)
		    end
			  line2.team_id = get_team_id(team2, sport)
			  line2.spread = spread_parts2[0]
			  line2.spread_vig = spread_parts2[1]
			  line2.money_line = teams[i+1][4].inner_html
			  line2.over_under = points_parts2[0]
			  line2.total_points = points_parts2[1]
			  line2.total_points_vig = points_parts2[2]
			  line2.browser_id = @site_id
        
        if !line1.team_id.nil? && !line2.team_id.nil?
          line1.game_id = line2.game_id = get_game_id(line1.team_id, line2.team_id, date)        
				  @listener.add(line1)
				  @listener.add(line2)
			  else 
			    puts "pinnecle line failed to load line"
        end
			end				
			i+=2
		end 
	end
end
