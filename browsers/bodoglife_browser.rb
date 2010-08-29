require 'lib/browser'

class BodogLifeBrowser < Browser
  
  def scrape(page, sport)
    temp_file = "temp/bodoglife_temp.txt"
    web_page = @client.get_content(@url+page)
    File.open(temp_file, 'w') {|f| f.write(web_page) }
    parse(temp_file, sport)
  end
  
  def split_odds(str)
    if (str.include?(" ("))
      parts = str.split(" (")
      parts[1] = parts[1].gsub(")", "")
      if 'EVEN' == parts[1]
        parts[1] = 100
      end
    elsif str.include?("(")
      parts = str.split(")")
      parts[0] = parts[0].gsub("(", "")
      parts[1] = parts[1].gsub("o", "OVER")
      parts[1] = parts[1].gsub("u", "UNDER")
    else
      parts = [str, "-110"]
    end
    return parts
  end
  
  def normalize(name)
    translations = {'Houston' => 'Houston U',
                    'Pittsburgh' => 'Pittsburgh U',
                    'Minnesota' => 'Minnesota U',
                    'Cincinnati' => 'Cincinnati U',
                    'U Connecticut' => 'Connecticut',
                    'Wisc.Milwaukee' => 'Wisconsin Milwaukee'}
    if translations.key?(name)
      name = translations[name]
    end
    return Normalizer.replace_abbreviation(Normalizer.strip_characters(name))
  end
  
  def parse(file, sport)
    doc = open(file) { |f| Hpricot(f) }

    date = Date.new
    (doc/"div#event-schedule > div").each do |div|
			if div[:class] == "schedule-date"
			  date =  Date.parse((div/"strong").inner_html, '%B %d %Y')
			  
		  elsif div[:class] == "event"
		    names = (div/"div.competitor-name/a")
		    if (names.size > 1)
		      line1 = Line.new
		      line2 = Line.new
		      
		      name1 = names[0].inner_html
		      name2 = names[1].inner_html
		      if 5 == sport.to_i || 4 == sport.to_i
		        name1 = normalize(name1)
		        name2 = normalize(name2)
	        end
		      line1.team_id = get_team_id(name1, sport)
		      line2.team_id = get_team_id(name2, sport)

          odds = (div/"a.lineOdd")
          
          case odds.size
          when 2
            spread = split_odds(odds[0].inner_html)
		        line1.spread = spread[0]
		        line1.spread_vig = spread[1]
		        
  		      spread = split_odds(odds[1].inner_html)
		        line2.spread = spread[0]
		        line2.spread_vig = spread[1]
          when 6
            spread = split_odds(odds[0].inner_html)
		        line1.spread = spread[0]
		        line1.spread_vig = spread[1]

  	        money_line = odds[1].inner_html
  		      line1.money_line = money_line
  		      total_points = (div/"div.total-number/b").inner_html.gsub("\302\275", ".5")
  		      line1.total_points = total_points
  		      
  		      total_points = split_odds(odds[2].inner_html)
		        line1.over_under = total_points[1]
		        line1.total_points_vig = total_points[0]

  		      spread = split_odds(odds[4].inner_html)
		        line2.spread = spread[0]
		        line2.spread_vig = spread[1]
		        
  	        money_line = odds[5].inner_html
  		      line2.money_line = money_line
  		      total_points = (div/"div.total-number/b").inner_html.gsub("\302\275", ".5")
  		      line2.total_points = total_points
  		      total_points = split_odds(odds[3].inner_html)
		        line2.over_under = total_points[1]
		        line2.total_points_vig = total_points[0]
          end
                      
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