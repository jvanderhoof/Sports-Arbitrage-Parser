class Normalizer
  @nba = {"Boston" => "Boston Celtics",
    "New Jersey" => "New Jersey Nets",
    "New York" => "New York Knicks",
    "Philadelphia" => "Philadelphia 76ers",
    "Toronto" => "Toronto Raptors",
    "Chicago" => "Chicago Bulls",
    "Cleveland" => "Cleveland Cavaliers",
    "Detroit" => "Detroit Pistons",
    "Indiana" => "Indiana Pacers",
    "Milwaukee" => "Milwaukee Bucks",
    "Atlanta" => "Atlanta Hawks",
    "Charlotte" => "Charlotte Bobcats",
    "Miami" => "Miami Heat",
    "Orlando" => "Orlando Magic",
    "Washington" => "Washington Wizards",
    "Dallas" => "Dallas Mavericks",
    "Houston" => "Houston Rockets",
    "Memphis" => "Memphis Grizzlies",
    "New Orleans" => "New Orleans Hornets",
    "San Antonio" => "San Antonio Spurs",
    "Denver" => "Denver Nuggets",
    "Minnesota" => "Minnesota Timberwolves",
    "Oklahoma City" => "Oklahoma City Thunder",
    "Portland" => "Portland Trail Blazers",
    "Utah" => "Utah Jazz",
    "Golden State" => "Golden State Warriors",
    "LA Clippers" => "Los Angeles Clippers",
    "La Clippers" => "Los Angeles Clippers",
    "LA Lakers" => "Los Angeles Lakers",
    "La Lakers" => "Los Angeles Lakers",
    "Phoenix" => "Phoenix Suns",
    "Sacramento" => "Sacramento Kings"}
    
  @nfl =  {"Buffalo" => "Buffalo Bills",
    "Miami" => "Miami Dolphins",
    "New England" => "New England Patriots",
    "Baltimore" => "Baltimore Ravens",
    "Cincinnati" => "Cincinnati Bengals",
    "Cleveland" => "Cleveland Browns",
    "Pittsburgh" => "Pittsburgh Steelers",
    "Houston" => "Houston Texans",
    "Indianapolis" => "Indianapolis Colts",
    "Jacksonville" => "Jacksonville Jaguars",
    "Tennessee" => "Tennessee Titans",
    "Denver" => "Denver Broncos",
    "Kansas City" => "Kansas City Chiefs",
    "Oakland" => "Oakland Raiders",
    "San Diego" => "San Diego Chargers",
    "Dallas" => "Dallas Cowboys",
    "Philadelphia" => "Philadelphia Eagles",
    "Washington" => "Washington Redskins",
    "Chicago" => "Chicago Bears",
    "Detroit" => "Detroit Lions",
    "Green Bay" => "Green Bay Packers",
    "Minnesota" => "Minnesota Vikings",
    "Atlanta" => "Atlanta Falcons",
    "Carolina" => "Carolina Panthers",
    "New Orleans" => "New Orleans Saints",
    "Tampa Bay" => "Tampa Bay Buccaneers",
    "Arizona" => "Arizona Cardinals",
    "St. Louis" => "St Louis Rams",
    "San Francisco" => "San Francisco 49ers",
    "Seattle" => "Seattle Seahawks",
    "Ny Jets" => "New York Jets",
    "Ny Giants" => "New York Giants"}
  

  def self.city_to_city_team_name(city, sport)
    case sport
    when 2
      if (@nfl.key?(city))
        return @nfl[city]
      else
        return city
      end
    when 3
      if (@nba.key?(city))
        return @nba[city]
      else
        return city
      end
    when 5
      return replace_abbreviation(city)
    end
  end
  
  def self.replace_abbreviation(team_str)
    team_str = strip_characters(team_str.downcase)
    team = team_str.split(" ")
    # probable flipping this would be faster
    translations = {'u' => 'university',
                    'st' => 'state',
                    's' => 'south',
                    'so' => 'south',
                    'ga' => 'georgia',
                    'w' => 'west',
                    'nc' => 'north carolina',
                    'fla' => 'florida',
                    'c' => 'central',
                    'atl' => 'atlantic',
                    'coll' => 'college',
                    'mich' => 'michigan',
                    'e' => 'eastern',
                    'east' => 'eastern',
                    'va' => 'virginia',
                    'se' => 'southeast',
                    'cs' => 'cal state',
                    'wisc' => 'wisconsin',
                    'tenn' => 'tennessee',
                    'northrn' => 'northern',
                    'ky' => 'kentucky',
                    'chi' => 'chicago',
                    'ill' => 'illinois',
                    'md' => 'maryland',
                    'n' => 'north',
                    'byu' => 'BYU',
                    'lsu' => 'LSU',
                    'usc' => 'USC',
                    'tcu' => 'TCU'}
    translations.keys.each do |key|
      if (!team.index(key).nil?)
        team[team.index(key)] = translations[key]
      end
    end
    if (team.size == 1 && team[0].size < 4)
      team = team[0]
    else
      team = team.join(" ").titleize()
    end
    return team
    
  end

  def self.strip_characters(team)
    team = team.strip
    team = team.gsub("\302\240", "")
    team = team.gsub("'", "")
    team = team.gsub(".", "")
    team = team.gsub("(", "")
    team = team.gsub(")", "")
    team = team.gsub("-", " ")
    team = team.gsub("\r\n", "")
    return team
  end
  
end

=begin  
  # normalizes team name across sites - mostely for college teams
	
	def translate_team(team, sport)
    team = team.strip
    case sport
    when 2
      case team
        nfl =
      else
        return team
      end
    when 3
      case team
        nba = 
      else
        return team
      end
    when 5
      #puts "team before abbr: #{team}"
      if 'Houston' == team
        team = 'houston u'
      end
      team = replace_abbreviation(team.downcase.split(" "))
      #puts "team after abbr: #{team}"
      return team 
    else
      puts "sport not found: #{sport}"
    end
    #New York Jets
    #New York Giants
  end

    
  
end
=end