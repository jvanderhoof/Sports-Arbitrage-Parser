require 'browsers/sports_book_browser'
require 'lib/betting_site'

browser = SportsBookBrowser.new("https://sportsbook.gamingsystem.net/", "SportsBook", 3)

pages = {'2' => 'sportsbook4/www.sportsbook.com/getodds.xgi?categoryId=203',
        '3' => 'sportsbook4/www.sportsbook.com/getodds.xgi?categoryId=200',
        '4' => 'sportsbook4/www.sportsbook.com/getodds.xgi?categoryId=201',
        '5' => 'sportsbook4/www.sportsbook.com/getodds.xgi?categoryId=206'}

pages = {'4' => 'sportsbook4/www.sportsbook.com/getodds.xgi?categoryId=201'}
        
pages.keys.each do |key|
  browser.scrape(pages[key], key.to_i)
  sleep(5)
end
