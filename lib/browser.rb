# ruby gems
require 'rubygems'
require 'hpricot'
require 'httpclient'
#require 'rfuzz/client'

# ruby libraries
require 'date'

# custom classes
require 'lib/team'
require 'lib/line'
require 'lib/game'
require 'lib/team_synonym'
require 'lib/listener'
require 'lib/normalizer'
require 'activesupport'

class Browser
  
  def initialize(url, name, site_id)
    @url = url
    @site_id = site_id
    @name = name
    
    listener_name = name.gsub(" ", "").underscore + "_listener"
    @listener = Listener.new(listener_name, site_id)
    
    # sets up http client to grab remote html content
    @client = HTTPClient.new()
  end
  
  def name
    @name
  end
  
  # looks up team id - for obvious performance reasons, this needs to be turned into a hash lookup rather then db lookup
  def get_team_id(team_name, sport)
    # normalize - mostely for college sports
    # looks up team - active record method
    team_name = Normalizer.strip_characters(team_name)
    team = Team.find(:first, :conditions => ["name = ? and sport_id = ?", team_name, sport])
    if team.nil? || team.name.nil?
      synonym = TeamSynonym.find(:first, :conditions => ["synonym =? and sport_id = ?", team_name, sport])
      
      team = Team.find(:first, :conditions => ["id = ? and sport_id = ?", synonym.team_id, sport]) unless synonym.nil?      
    end
    # if team name is not found - log and complain to console
    if (team.nil? || team.name.nil?)
      
      error_log = Logger.new('logs/missing_teams.log')
      puts "team not found: "+team_name.inspect+", sport: #{sport}"
      #puts team_name
      error_log.error("team not found: "+team_name.inspect+", sport: #{sport}")
      #return 0
    else
      #puts "id: #{team.id}"
      return team.id
    end
    # return team id
  end
  
  # lookup the game id based on teams and game time
  def get_game_id(team1_id, team2_id, game_time)
    # search for game - active record method
    game = Game.find(:first, :conditions => ["game_time = ? and (team1_id = ? or team2_id = ?)", game_time, team1_id, team1_id])
    # if game is found, return its id, otherwise create a new game
    unless game.nil?
      return game.id
    else
      game = Game.new
      game.team1_id = team1_id
      game.team2_id = team2_id
      game.game_time = game_time
      game.save 
      return game.id
    end
  end
end