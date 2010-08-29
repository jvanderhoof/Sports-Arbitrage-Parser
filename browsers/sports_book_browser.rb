require 'lib/browser'

class SportsBookBrowser < Browser
  
  def scrape(page, sport)
    temp_file = "temp/sportsbook_temp.txt"
    web_page = @client.get_content(@url+page)
    File.open(temp_file, 'w') {|f| f.write(web_page) }
    
    parse(temp_file, sport)
  end

  def format_team(team, sport)
    if (team.include?("("))
      team_parts = team.split("(")
      name = team_parts[0]
      name = normalize_team(name)
      city = team_parts[1].chomp!(")")
      city.gsub!(/[A-Z]/) { |p| ' ' + p }
      city = normalize_city(city)
      return "#{city} #{name}"
    else
      if 5 == sport || 4 == sport
        if team == 'Troy'
          team = "TroySt"
        elsif team == 'Cincinnati'
          team = 'CincinnatiU'
        elsif team == 'Nevada'
          team = 'NevadaReno'
        elsif team == 'WMichigan'
          team = 'WesternMichigan'
        end
        team = seperate_college_formatting(team.underscore())
      end
      return team
    end
  end
  
  def normalize_team(str)
    return_str= str
    unless str.eql?("Trail Blazers")
      return_str = str.gsub("Blazers", "Trail Blazers")
    end
    return return_str
  end
  
  def normalize_city(str)
    return_str = str.gsub("L A", "Los Angeles")
    return return_str
  end
  
  def seperate_college_formatting(team)
    team_parts = team.gsub("_", " ")
    team = Normalizer.replace_abbreviation(team_parts)
    return team 
  end

  def parse_spread(spread)
    if (spread.include?("("))
      spread_parts = spread.split("(")
      return {'spread' => spread_parts[0], 'spread_vig' => spread_parts[1].chomp!(")")}      
    else
      return {'spread' => spread, 'spread_vig' => "-110"}
    end
  end

  def parse_total_overunder(total)
    total_raw = total.split(" ")
    return {'total' => total_raw[1], 'over/under' => total_raw[0].upcase!}
  end
  
  def parse(file, sport)
    doc = open(file) { |f| Hpricot(f) }
    summary = (doc/"#wagerTable")
    teams = []

    summary.search("tr").each do |row|
      columns = (row/"td")
      if columns.size == 9
        teams << columns
      end
    end

    count = 0
    while count < teams.size
      team1 = teams[count]
      count += 1
      team2 = teams[count]
      date = Date.parse(team1[0].inner_html, '%d/%m/%Y')

      unless team1[3].inner_text.eql?("OFF")
  		  line1 = Line.new
  		  team1_name = format_team(team1[2].inner_text, sport).strip
  		  line1.team_id = get_team_id(team1_name, sport)
  		  line1.spread = parse_spread(team1[5].inner_text)['spread']
  		  line1.spread_vig = parse_spread(team1[5].inner_text)['spread_vig']
  		  line1.money_line = team1[3].inner_text
        line1.over_under = parse_total_overunder(team1[7].inner_text)['over/under']
  		  line1.total_points = parse_total_overunder(team1[7].inner_text)['total']
  		  line1.total_points_vig = "-110"
  		  line1.browser_id = @site_id

        line2 = Line.new
        team2_name = format_team(team2[2].inner_text, sport).strip
        line2.team_id = get_team_id(team2_name, sport)
  		  line2.spread = parse_spread(team2[5].inner_text)['spread']
  		  line2.spread_vig = parse_spread(team2[5].inner_text)['spread_vig']
  		  line2.money_line = team2[3].inner_text
        line2.over_under = parse_total_overunder(team2[7].inner_text)['over/under']
  		  line2.total_points = parse_total_overunder(team2[7].inner_text)['total']
  		  line2.total_points_vig = "-110"
  		  line2.browser_id = @site_id
        
        if !line1.team_id.nil? && !line2.team_id.nil?
          line1.game_id = line2.game_id = get_game_id(line1.team_id, line2.team_id, date)        
          #puts line1
          #puts line2
    		  @listener.add(line1)
  			  @listener.add(line2)
			  else
			    puts "sports book line failed to load line"
        end
		  end
			count += 1
		end
  end
end