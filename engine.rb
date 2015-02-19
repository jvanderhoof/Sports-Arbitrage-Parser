# threading engine to run all scrapers concurrently
require 'lib/betting_site'
require 'browsers/betus_browser'
require 'browsers/sports_book_browser'
require 'browsers/pinnacle_browser'
require 'browsers/sports_interaction_browser'
require 'browsers/bodoglife_browser'


threads = []


threads << Thread.new() {
  puts "start pinnacle"

  #proxy="http://sugar.bostonlogic.com/proxy.php?url="

  browser = PinnacleBrowser.new("http://www.pinnaclesports.com/", "Pinnacle", 1)

  pages = {'2' => 'League/Football/NFL/1/Lines.aspx',
          '3' => 'League/Basketball/NBA/1/Lines.aspx',
          '4' => 'League/Basketball/NCAA/1/Lines.aspx',
          '5' => 'League/Football/NCAA/127/Lines.aspx'}

  site = BettingSite.new
  site.process(browser, pages)
}

threads << Thread.new() {
  puts "start sports internaction"

  browser = SportsInteractionBrowser.new("http://www.sportsinteraction.com/", "Sports Interaction", 2)

  pages = {'2' => 'sportsbook/contentLoader.cfm?section=events&eventTypeID=25&sectionRequested=events&ajaxRequest=true',
          '3' => 'sportsbook/contentLoader.cfm?section=events&eventTypeID=3&sectionRequested=events&ajaxRequest=true',
          '4' => 'sportsbook/contentLoader.cfm?section=events&eventTypeID=15&sectionRequested=events&ajaxRequest=true',
          '5' => 'sportsbook/contentLoader.cfm?section=events&eventTypeID=31&sectionRequested=events&ajaxRequest=true'}

  site = BettingSite.new
  site.process(browser, pages)
}

threads << Thread.new() {
  puts "starting sportsbook"

  browser = SportsBookBrowser.new("https://sportsbook.gamingsystem.net/", "SportsBook", 3)

  pages = {'2' => 'sportsbook4/www.sportsbook.com/getodds.xgi?categoryId=203',
          '3' => 'sportsbook4/www.sportsbook.com/getodds.xgi?categoryId=200',
          '4' => 'sportsbook4/www.sportsbook.com/getodds.xgi?categoryId=201',
          '5' => 'sportsbook4/www.sportsbook.com/getodds.xgi?categoryId=206'}

  site = BettingSite.new
  site.process(browser, pages)
}


threads << Thread.new() {
  puts "starting bet us"

  browser = BetUsBrowser.new("http://www.betus.com/", "Bet Us", 4)

  pages = {'2' => 'sportsbook/nfl-football-game-lines.aspx',
          '3' => 'sportsbook/nba-basketball-lines.aspx',
          '4' => 'sportsbook/ncaa-basketball-lines.aspx',
          '5' => 'sportsbook/college-football-game-lines.aspx'}

  site = BettingSite.new
  site.process(browser, pages)
}

threads << Thread.new() {
  puts "start bodog life"

  browser = BodogLifeBrowser.new("http://sports.bodoglife.com/", "BodogLife", 6)

  pages = {'2' => 'sports-betting/nfl-football.jsp',
          '3' => 'sports-betting/nba-basketball.jsp',
          '4' => 'sports-betting/ncaa-college-basketball.jsp',
          '5' => 'sports-betting/ncaa-college-football.jsp'}

  site = BettingSite.new
  site.process(browser, pages)
}

threads.each { |aThread|  aThread.join }
