require 'lib/browser'
require 'json'
require 'net/http'
require 'open-uri'

class SportsInteractionBrowser < Browser
  def initialize(url, name, site_id)
    @url = url
    @site_id = site_id
    @name = name
    
    listener_name = name.gsub(" ", "").underscore + "_listener"
    @listener = Listener.new(listener_name, site_id)
  end
  
  def scrape(page, sport)
    scrape_json(page, sport)
  end
  
  def scrape_html(listener)
    parse(@url, listener)
  end
  
  def scrape_json(page, sport)
    resp = Net::HTTP.get_response(URI.parse(@url+page))
    data = resp.body
    result = JSON.parse(data)
    content = result["content"]
    temp_file = "temp/sportsinteraction_temp.txt"
    File.open(temp_file, 'w') {|f| f.write(content) }       
    parse(temp_file, sport)
  end
	
	def normalize_team(team, sport)
	  if 5 == sport.to_i || 4 == sport.to_i
  	  translations = {'Houston' => 'Houston U' }
      if translations.key?(team)
        team = translations[team]
      end
      return Normalizer.replace_abbreviation(team)
    else
      return Normalizer.city_to_city_team_name(team, sport)
    end
  end
	
  
  def parse(file, sport)
    doc = open(file) { |f| Hpricot(f) }
    summary = (doc/".game")
    current_date = ""
    summary.each do |row|
      date = row.search(".date").inner_html
      if date.length > 0
        current_date = DateTime.parse(date, "%B %d, %Y")
        #puts current_date 
      end
			unless (row.search("span.addRunner/span.price")[0].inner_html == 'Closed' || row.search("span.addRunner/span.price")[4].nil?) 

        # build lines
			  line1 = Line.new
			  #puts row.search("span/span.name")[0].inner_html
			  #puts row.search("span/span.name")[1].inner_html
	      line1.team_id = get_team_id(normalize_team(row.search("span/span.name")[0].inner_html, sport), sport)
				line1.spread = row.search("span/span.handicap")[0].inner_html.strip!
				line1.spread_vig = row.search("span.addRunner/span.price")[0].inner_html
			  money_line = row.search("span.addRunner/span.price")[4].inner_html
			  line1.money_line = money_line unless money_line == 'Closed'
        line1.over_under = row.search("span/span.name")[2].inner_html.upcase!
				line1.total_points = row.search("span/span.handicap")[2].inner_html.strip!
				total_points_vig = row.search("span.addRunner/span.price")[2].inner_html
				line1.total_points_vig = total_points_vig unless total_points_vig == 'Closed'
				line1.browser_id = @site_id
        
        line2 = Line.new
        line2.team_id = get_team_id(normalize_team(row.search("span/span.name")[1].inner_html, sport), sport)
				line2.spread = row.search("span/span.handicap")[1].inner_html.strip!
				line2.spread_vig = row.search("span.addRunner/span.price")[1].inner_html
				money_line = row.search("span.addRunner/span.price")[5].inner_html
				line2.money_line = money_line unless money_line == 'Closed'
	      line2.over_under = row.search("span/span.name")[3].inner_html.upcase!
				line2.total_points = row.search("span/span.handicap")[3].inner_html.strip!
				total_points_vig = row.search("span.addRunner/span.price")[3].inner_html
				line2.total_points_vig = total_points_vig unless total_points_vig == 'Closed'
				line2.browser_id = @site_id
        
        if !line1.team_id.nil? && !line2.team_id.nil?
          line1.game_id = line2.game_id = get_game_id(line1.team_id, line2.team_id, current_date)        
		      #puts line1.to_s
		      #puts line2.to_s
				  @listener.add(line1)
				  @listener.add(line2)
			  else
			    puts "sports interaction line failed to load line"
			  end
			end
    end
  end
end