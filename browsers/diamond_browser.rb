require 'lib/browser'
require 'lib/selenium'

class DiamondBrowser < Browser
  
  def initialize(url, name, site_id)
    @url = url
    @site_id = site_id
    @name = name
    
    listener_name = name.gsub(" ", "").underscore + "_listener"
    @listener = Listener.new(listener_name, site_id)
    
    @selenium = Selenium::SeleniumDriver.new("localhost", 4444, "*chrome", @url, 10000);
    @selenium.start
  end
  
    
  def scrape(page, sport)
    @selenium.open(@url+page)
    temp_file = 'temp/diamond_temp.txt'
    content = @selenium.get_html_source()
    File.open(temp_file, 'w') {|f| f.write(content) }    
    parse(temp_file, sport)
  end
  
  def split_line(str)
    str = str.gsub("\302\275", ".5")
    first_character = str[0,1]
    remainder = str[1,str.length-1]
    if remainder.include?("-")
      parts = remainder.split("-")
      parts[1] = "-"+parts[1]
    elsif remainder.include?("+")
      parts = remainder.split("+")
      parts[1] = "+"+parts[1]
    else
      parts = []
      parts[0] = remainder.gsub("EV", "")
      parts[1] = 0
    end
    
    case first_character
    when "o"
      parts[2] = "OVER"
    when "u"
      parts[2] = "UNDER"
    else
      parts[0] = first_character+parts[0]
    end    
    return parts
  end
  
  def normalize(name)
		name = Normalizer.strip_characters(name)
    translations = {'North Car' => 'North Carolina',
                    'No Illinois' => 'Northern Illinois',
                    'Nevada' => 'Nevada Reno',
                    'Bos College' => 'Boston College',
                    'South Car' => 'South Carolina',
                    'East Car' => 'Eastern Carolina'}
    if translations.key?(name)
      name = translations[name]
    end
    return Normalizer.replace_abbreviation(name)
  end
  

  def parse(file, sport)
    doc = open(file) { |f| Hpricot(f) }
		count = 0
		date = Date.new
		(doc/"div.lines_container > div").each do |div|
			if div[:class] == "lines_banner"
				date_title = (div/".lines_banner_in")
				unless date_title.size > 1					
				  date_string = date_title.inner_html.strip
				  date_str_part = date_string.split(" - ")[1]				  
					now = DateTime::now()
					date_str = date_str_part + " #{now.year}"
					date = DateTime.parse(date_str, '%b %d %Y')
					if date.month.to_i == 1 && now.month.to_i == 12
						date_str = date_str_part + " #{now.year+1}"
						date = DateTime.parse(date_str, '%b %d %Y')
					end
			  end
			end
			if div[:class] == "lines_game_odd" || div[:class] == "lines_game_even"
				line1 = Line.new
				line2 = Line.new
				
				team1_name = (div/".lines_teamName")[0].inner_html.strip.titleize
				team2_name = (div/".lines_teamName")[1].inner_html.strip.titleize
				if 5 == sport.to_i
				  team1 = normalize(team1_name)
				  team2 = normalize(team2_name)
			  else
					team1 = Normalizer.city_to_city_team_name(team1_name, sport)
  				team2 = Normalizer.city_to_city_team_name(team2_name, sport)
    		end
				line1.team_id = get_team_id(team1, sport)
				line2.team_id = get_team_id(team2, sport)
				
				lines = (div/".lines_OddsItem")
				if lines.length > 3
  				parts = split_line(lines[0].inner_html.strip) 
  				line1.spread = parts[0]
  				line1.spread_vig = parts[1]

  				parts = split_line(lines[2].inner_html.strip) 
  				line1.over_under = parts[2]
  				line1.total_points = parts[0]
  				line1.total_points_vig = parts[1]

  				parts = split_line(lines[1].inner_html.strip) 
  				line2.spread = parts[0]
  				line2.spread_vig = parts[1]

  				parts = split_line(lines[3].inner_html.strip) 
  				line2.over_under = parts[2]
  				line2.total_points = parts[0]
  				line2.total_points_vig = parts[1]
  				
  				if !line1.team_id.nil? && !line2.team_id.nil?
  					line1.game_id = line2.game_id = get_game_id(line1.team_id, line2.team_id, date)
    				line1.browser_id = line2.browser_id = @site_id
  				
  					#puts line1.to_s
  					#puts line2.to_s

  		      @listener.add(line1)
  		      @listener.add(line2)
          end  				
			  end
		  end
		end
	end
end
