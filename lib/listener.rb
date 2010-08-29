#require 'socket'

class Listener
  def initialize(logger_name, browser_id)
    @name = logger_name
    @lines = {}
		@logger = Logger.new('logs/'+logger_name+'_changes.log')
		restore(browser_id)
  end
	
  def add(line)
    if @lines.length == 0 || !@lines.has_key?(line.team_id)
      @lines.merge!({line.team_id => line})
      line.save
      post_line(line)      
    else
			update(line)
    end
  end

	def update(line)
		if (!@lines[line.team_id].equals(line))
			@logger.info("new: "+line.to_s)
			@lines[line.team_id] = line
      line.save
      post_line(line)      
		end
	end
	
=begin
	def post_line(line)
    host = 'localhost'
    port = 2000
    s = TCPSocket.open(host, port)
    s.puts line.to_json
    s.close
  end
=end

	def restore(browser_id)
	  teams = Team.find(:all)
		teams.each do |team|
			line = Line.find(:last, :conditions => [ "team_id = ? and browser_id = ?", team.id, browser_id])
			unless line.nil?
			  post_line(line)
			  @lines.merge!({team.id => line})
		  end
		end
	end
end
