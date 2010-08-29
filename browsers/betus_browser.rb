require 'lib/browser'
# betus.com specific scraper

class BetUsBrowser < Browser

  # entry method
  def scrape(page, sport)
    temp_file = "temp/betus_temp.txt"
    # grab remote content
    web_page = @client.get_content(@url+page)
    # write scraped html to a temp local file for processing     
    File.open(temp_file, 'w') {|f| f.write(web_page) }
    #process local file    
    parse(temp_file, sport)
  end
  
  # takes the spread and breaks it into it's parts, returning a hash of the following form: 
  # {'spread' => 'spread value', 'odds' => 'spread moneyline'}
  def parse_spread(content)
    content = content.inner_html.strip
    #puts "content: #{content}"
    parts = content.split("\n")
    spread = parts[0].gsub("\302\275\r", ".5")
    odds = parts[1].gsub("\r", "").gsub("&nbsp;", "")
    if odds.eql?("Ev") 
      # may need to re-examine this
      odds = "0"
    end
    return {'spread' => spread, 'odds' => odds}
  end
  
  # normalize over under
  def over_under(value)
    if ("U".eql?(value))
      return "UNDER"
    end
    if ("O".eql?(value))
      return "OVER"
    end
  end
  
  # actual processing of the scraped html page
  def parse(file, sport)
    # open the html file using hpricot for processor - borrows the jquery syntax for selecting elements
    doc = open(file) { |f| Hpricot(f) }
    
    # grab all the game blocks - block for each day games occur on
    game_days = (doc/".game-block")

    # iterate through each game day
    game_days.each do |game_day|
      # grab the game date
      raw_date = (game_day/".date").inner_html.strip
      # clean
      raw_date = raw_date.gsub("EST", "").strip
      # turn it into a ruby date so it's normalized & can easily be saved to db
      date = Date.parse(raw_date, '%a, %b %d, %Y')
      
      # grab array of games for that day
      games = (game_day/"table.game-tbl")
      # iterate through games
      games.each do |game|
        # grab team 1 & team 2 name, remove whitespace, remove html line breaks
        team1 = game.search("tr.visitor/td.team").inner_html.strip.gsub("<br />", "")
        team2 = game.search("tr.home/td.team").inner_html.strip.gsub("<br />", "")
        if (5 == sport.to_i || 4 == sport.to_i)
          team1 = normalize(team1)
          team2 = normalize(team2)
        end
        # make sure there is a team 1 and team 2
        unless (team1.length == 0 || team2.length == 0)
          # create a new line object
          line1 = Line.new
          # get the team id - this is a browser level method
          line1.team_id = get_team_id(team1, sport)
          # grab the spread and parse to a hash
          spread1 = parse_spread(game.search("tr.visitor/td.points"))
          # assign the spread
          line1.spread = spread1['spread']
          # assign the spread vig
          line1.spread_vig = spread1["odds"]
          # grab money line - split create an array of elements based on provided seperator character
          line1.money_line = game.search("tr.visitor/td.money/span").inner_html.split("<")[0]
          # grab total points, switching 1/2 to .5 so we can understand it
          total_points = game.search("table#tblTotal/tr/td.tall").inner_html.strip.gsub("\302\275", ".5")
          line1.total_points = total_points
          # grab over under
          over_under = game.search("table#tblTotal/tr/td.wide/em")
          line1.over_under = over_under(over_under[0].inner_html.strip) unless over_under[0].nil?
          # grab total points
          total_points_vig = game.search("table#tblTotal/tr/td.wide")
          line1.total_points_vig = total_points_vig[0].inner_html.split(" ")[1].strip unless total_points_vig[0].nil?
          # browser id needs to be unique for each site scraped
          line1.browser_id = @site_id
          
          # repeat for second team
          line2 = Line.new
          line2.team_id = get_team_id(team2, sport)
          #puts "points: "+game.search("tr.home/td.points").inner_html
          spread2 = parse_spread(game.search("tr.home/td.points"))
          line2.spread = spread2['spread']
          line2.spread_vig = spread2["odds"]
          money_line = game.search("tr.home/td.money/span")
          line2.money_line = money_line.inner_html.split("<")[0] unless money_line.nil?
          line2.total_points = total_points
          over_under = game.search("table#tblTotal/tr/td.wide/em")
          line2.over_under = over_under(over_under[1].inner_html.strip) unless over_under[1].nil?
          total_points_vig = game.search("table#tblTotal/tr/td.wide")
          line2.total_points_vig = total_points_vig[1].inner_html.split(" ")[1].strip unless total_points_vig[1].nil?
          line2.browser_id = @site_id

          # grab game id - browser level method
          if !line1.team_id.nil? && !line2.team_id.nil?
            line1.game_id = line2.game_id = get_game_id(line1.team_id, line2.team_id, date)        
          
            #puts line1.to_s
            #puts line2.to_s
            
            #add lines to listener
            @listener.add(line1)
  			    @listener.add(line2)
			    else
  			    puts "bet us line failed to load line"
  		    end
        end
      end
    end
  end
  
  def normalize(name)
    translations = {
      'TCU Horned Frogs' => 'TCU',
      'Boise State Broncos' => 'Boise State',
      'Notre Dame Fighting Irish' => 'Notre Dame',
      'Hawaii Warriors' => 'Hawaii',
      'Florida Atlantic Owls' => 'Florida Atlantic',
      'Central Michigan Chippewas' => 'Central Michigan',
      'West Virginia Mountaineers' => 'West Virginia',
      'North Carolina Tar Heels' => 'North Carolina',
      'Wisconsin Badgers' => 'Wisconsin',
      'FSU Seminoles' => 'Florida State',
      'Miami Florida Hurricanes' => 'Miami Florida',
      'California Golden Bears' => 'California',
      'No Illinois Huskies' => 'Northern Illinois',
      'Louisiana Tech Bulldogs' => 'Louisiana Tech',
      'NC State Wolfpack' => 'North Carolina State',
      'Rutgers Scarlet Knights' => 'Rutgers',
      'Northwestern Wildcats' => 'Northwestern',
      'Missouri Tigers' => 'Missouri',
      'Nevada Wolf Pack' => 'Nevada Reno',
      'Maryland Terps' => 'Maryland',
      'Western Michigan Broncos' => 'Western Michigan',
      'Rice Owls' => 'Rice',
      'Oregon Ducks' => 'Oregon',
      'Oklahoma State Cowboys' => 'Oklahoma State',
      'Air Force Falcons' => 'Air Force',
      'Houston Cougars' => 'Houston University',
      'Pittsburgh Panthers' => 'Pittsburgh University',
      'Oregon State Beavers' => 'Oregon State',
      'Boston College Eagles' => 'Boston College',
      'Vanderbilt Commodores' => 'Vanderbilt',
      'Minnesota Golden Gophers' => 'Minnesota University',
      'Kansas Jayhawks' => 'Kansas',
      'LSU Fighting Tigers' => 'LSU',
      'Georgia Tech Yellow Jackets' => 'Georgia Tech',
      'Iowa Hawkeyes' => 'Iowa',
      'South Carolina Gamecocks' => 'South Carolina',
      'Clemson Tigers' => 'Clemson',
      'Nebraska Cornhuskers' => 'Nebraska',
      'Michigan State Spartans' => 'Michigan State',
      'Georgia Bulldogs' => 'Georgia',
      'Penn State Nittany Lions' => 'Penn State',
      'USC Trojans' => 'USC',
      'Virginia Tech Hokies' => 'Virginia Tech',
      'Cincinnati Bearcats' => 'Cincinnati University',
      'Mississippi Rebels' => 'Mississippi',
      'Texas Tech Red Raiders' => 'Texas Tech',
      'East Carolina Pirates' => 'Eastern Carolina',
      'Kentucky Wildcats' => 'Kentucky',
      'Utah Utes' => 'Utah',
      'Alabama Crimson Tide' => 'Alabama',
      'Buffalo Bulls' => 'Buffalo University',
      'Connecticut Huskies' => 'Connecticut',
      'Ohio State Buckeyes' => 'Ohio State',
      'Texas Longhorns' => 'Texas',
      'Ball State Cardinals' => 'Ball State',
      'Tulsa Golden Hurricanes' => 'Tulsa'}
    if translations.key?(name)
      name = translations[name]
    end
    return Normalizer.replace_abbreviation(Normalizer.strip_characters(name))
  end
  
=begin  
  def normalize_college(team) 
    teams = {
      'TCU Horned Frogs' => 'TCU',
      'Boise State Broncos' => 'Boise State',
      'Notre Dame Fighting Irish' => 'Notre Dame',
      'Hawaii Warriors' => 'Hawaii',
      'Florida Atlantic Owls' => 'Florida Atlantic',
      'Central Michigan Chippewas' => 'Central Michigan',
      'West Virginia Mountaineers' => 'West Virginia',
      'North Carolina Tar Heels' => 'North Carolina',
      'Wisconsin Badgers' => 'Wisconsin',
      'FSU Seminoles' => 'Florida State',
      'Miami Florida Hurricanes' => 'Miami Florida',
      'California Golden Bears' => 'California',
      'No Illinois Huskies' => 'Northern Illinois',
      'Louisiana Tech Bulldogs' => 'Louisiana Tech',
      'NC State Wolfpack' => 'North Carolina State',
      'Rutgers Scarlet Knights' => 'Rutgers',
      'Northwestern Wildcats' => 'Northwestern',
      'Missouri Tigers' => 'Missouri',
      'Nevada Wolf Pack' => 'Nevada Reno',
      'Maryland Terps' => 'Maryland',
      'Western Michigan Broncos' => 'Western Michigan',
      'Rice Owls' => 'Rice',
      'Oregon Ducks' => 'Oregon',
      'Oklahoma State Cowboys' => 'Oklahoma State',
      'Air Force Falcons' => 'Air Force',
      'Houston Cougars' => 'Houston University',
      'Pittsburgh Panthers' => 'Pittsburgh University',
      'Oregon State Beavers' => 'Oregon State',
      'Boston College Eagles' => 'Boston College',
      'Vanderbilt Commodores' => 'Vanderbilt',
      'Minnesota Golden Gophers' => 'Minnesota University',
      'Kansas Jayhawks' => 'Kansas',
      'LSU Fighting Tigers' => 'LSU',
      'Georgia Tech Yellow Jackets' => 'Georgia Tech',
      'Iowa Hawkeyes' => 'Iowa',
      'South Carolina Gamecocks' => 'South Carolina',
      'Clemson Tigers' => 'Clemson',
      'Nebraska Cornhuskers' => 'Nebraska',
      'Michigan State Spartans' => 'Michigan State',
      'Georgia Bulldogs' => 'Georgia',
      'Penn State Nittany Lions' => 'Penn State',
      'USC Trojans' => 'USC',
      'Virginia Tech Hokies' => 'Virginia Tech',
      'Cincinnati Bearcats' => 'Cincinnati University',
      'Mississippi Rebels' => 'Mississippi',
      'Texas Tech Red Raiders' => 'Texas Tech',
      'East Carolina Pirates' => 'Eastern Carolina',
      'Kentucky Wildcats' => 'Kentucky',
      'Utah Utes' => 'Utah',
      'Alabama Crimson Tide' => 'Alabama',
      'Buffalo Bulls' => 'Buffalo University',
      'Connecticut Huskies' => 'Connecticut',
      'Ohio State Buckeyes' => 'Ohio State',
      'Texas Longhorns' => 'Texas',
      'Ball State Cardinals' => 'Ball State',
      'Tulsa Golden Hurricanes' => 'Tulsa'}
    if (teams.key?(team))
      return teams[team]
    else
      return team
    end
      
  end
=end
end