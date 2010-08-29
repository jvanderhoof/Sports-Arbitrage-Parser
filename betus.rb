# starter for the Bet Us site.  the goal is to get this page as simple as possible

require 'lib/betting_site'
require 'browsers/betus_browser'

# create an nfl browser - to scrape nfl page.
# takes a page url and sport id.  NFL = 2, NBA = 3
browser = BetUsBrowser.new("http://www.betus.com/", "Bet Us", 4)

pages = {'2' => 'sportsbook/nfl-football-game-lines.aspx',
        '3' => 'sportsbook/nba-basketball-lines.aspx',
        '4' => 'sportsbook/ncaa-basketball-lines.aspx',
        '5' => 'sportsbook/college-football-game-lines.aspx'}


pages = {'4' => 'sportsbook/ncaa-basketball-lines.aspx'}

pages.keys.each do |key|
  browser.scrape(pages[key], key.to_i)
  sleep(5)
end
