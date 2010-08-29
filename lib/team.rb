require 'activerecord'
require "yaml"

ActiveRecord::Base.establish_connection(YAML.load_file("config/database.yml"))

class Team < ActiveRecord::Base
  has_one :line
  has_many :team_synonyms
  belongs_to :sport
end
