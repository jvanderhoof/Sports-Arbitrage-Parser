require 'browsers/pinnacle_browser'
require 'lib/betting_site'

proxy="http://sugar.bostonlogic.com/proxy.php?url="

browser = PinnacleBrowser.new(proxy+"www.pinnaclesports.com/", "Pinnacle", 1)

pages = {'2' => 'League/Football/NFL/1/Lines.aspx',
        '3' => 'League/Basketball/NBA/1/Lines.aspx',
        '4' => 'League/Basketball/NCAA/1/Lines.aspx',
        '5' => 'League/Football/NCAA/127/Lines.aspx'}
        
pages = {'4' =>'League/Basketball/NCAA/1/Lines.aspx'}
        
pages.keys.each do |key|
  browser.scrape(pages[key], key.to_i)
  sleep(5)
end
