require 'browsers/sports_interaction_browser'
require 'lib/betting_site'

browser = SportsInteractionBrowser.new("http://www.sportsinteraction.com/", "Sports Interaction", 2)

pages = {'2' => 'sportsbook/contentLoader.cfm?section=events&eventTypeID=25&sectionRequested=events&ajaxRequest=true',
        '3' => 'sportsbook/contentLoader.cfm?section=events&eventTypeID=3&sectionRequested=events&ajaxRequest=true',
        '4' => 'sportsbook/contentLoader.cfm?section=events&eventTypeID=15&sectionRequested=events&ajaxRequest=true',
        '5' => 'sportsbook/contentLoader.cfm?section=events&eventTypeID=31&sectionRequested=events&ajaxRequest=true'}
        
pages = {'4' => 'sportsbook/contentLoader.cfm?section=events&eventTypeID=15&sectionRequested=events&ajaxRequest=true'}
        
pages.keys.each do |key|
  browser.scrape(pages[key], key.to_i)
  sleep(5)
end
