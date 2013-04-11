class PortfolioName < ActiveRecord::Base
  attr_accessible :name, :global
  has_many :portfolios
  validates_presence_of   :name
  validates_uniqueness_of :name
end
