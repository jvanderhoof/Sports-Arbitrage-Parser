require 'lib/betting_site'
require 'browsers/bodoglife_browser'

browser = BodogLifeBrowser.new("http://sports.bodoglife.com/", "BodogLife", 6)

pages = {'2' => 'sports-betting/nfl-football.jsp',
        '3' => 'sports-betting/nba-basketball.jsp',
        '4' => 'sports-betting/ncaa-college-basketball.jsp',
        '5' => 'sports-betting/ncaa-college-football.jsp'}
        
pages.keys.each do |key|
  browser.scrape(pages[key], key.to_i)
  sleep(5)
end

