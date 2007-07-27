require 'rubygems'
require 'yaml'
require 'active_record'

module Beaver
  module DB
    class Log < ActiveRecord::Base
      validates_presence_of :name, :shasum, :source, :logdate, :status
      validates_inclusion_of :status, :in => [
        'found',
        'compressed',
        'renamed',
        'transferring',
        'transferred',
        'waiting',
      ]
    end
  end
end