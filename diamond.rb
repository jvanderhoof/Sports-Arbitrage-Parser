require 'browsers/diamond_browser'
require 'lib/betting_site'

browser = DiamondBrowser.new("http://www.2betdsi.com/", "Diamond", 5)

pages = {'2' => 'schedule.aspx?league=1',
        '3' => 'schedule.aspx?league=3',
        '4' => 'schedule.aspx?league=4',
        '5' => 'schedule.aspx?league=2'}

site = BettingSite.new
site.process(browser, pages)
