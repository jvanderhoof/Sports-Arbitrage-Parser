require 'activerecord'
require "yaml"

ActiveRecord::Base.establish_connection(YAML.load_file("config/database.yml"))

class Game < ActiveRecord::Base
  has_one :line
end