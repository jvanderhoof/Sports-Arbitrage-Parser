require 'activerecord'
require "yaml"

ActiveRecord::Base.establish_connection(YAML.load_file("config/database.yml"))

class Sport < ActiveRecord::Base
  has_one :team
end