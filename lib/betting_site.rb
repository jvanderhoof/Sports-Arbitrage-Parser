# this class abstracts out the iterative scraping of a betting site.  simplifies error catching, as 
# similar set of errors are thrown acrossed all the sites

#require 'lib/browser'
require 'logger'

class BettingSite
  
  def handle_error(error, browser, log)
		log.error("(#{Time.now})#{browser} error: #{error}")
		puts "(#{Time.now}) #{browser} error: #{error}"
		puts "error caught"
		sleep(10)
  end

  # handles actual scrap, waiting 5 seconds between each scrape, catches and logs errors
  #
  # args: sports - array of browser objects
  # args: listener - listener object
  # args: browser_name - name of browser to be used for logging purposes
  #
  def process(browser, pages)
=begin    
    listener_name = browser_name.gsub(" ", "").underscore + "_listener"
    #puts "listener(#{site_id}): #{listener_name}"
    listener = Listener.new(listener_name, site_id)
    
=end    
    logger =  Logger.new('logs/logfile.log')
    logger.info("starting #{browser.name} browser....")
    # infinite loop 
    while (true)
      # iterate through each item in the array
      pages.keys.each do |key|
        puts "Scraper: #{browser.name}, sport: #{key}"
        sleep(5)
        begin
          browser.scrape(pages[key], key.to_i)
          sleep(5)
        rescue NameError
          handle_error($!, browser.name, logger)
        rescue Errno::ECONNRESET
          handle_error($!, browser.name, logger)
      	rescue Timeout::Error
          handle_error($!, browser.name, logger)
      	rescue RuntimeError
          handle_error($!, browser.name, logger)
      	rescue NoMethodError
          handle_error($!, browser.name, logger)
      	rescue TypeError
          handle_error($!, browser.name, logger)          
        rescue OpenURI::HTTPError
          handle_error($!, browser.name, logger)          
        rescue EOFError
          handle_error($!, browser.name, logger)          
        rescue NoMemoryError
          handle_error($!, browser.name, logger)          
        rescue Errno::ETIMEDOUT
          handle_error($!, browser.name, logger)          
        rescue JSON::ParserError
          handle_error($!, browser.name, logger)          
        rescue HTTPClient::Session::KeepAliveDisconnected	  	  
          handle_error($!, browser.name, logger)
        end
      end
        
      # iterate through each item in the array
#      sports.each do |sport| 
#        begin
##          sport.scrape(listener)
#          sleep(5)
#      end
    end
  end
end