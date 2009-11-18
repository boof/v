#!/usr/bin/env ruby
# 
#  v.rb
#  v
#  
#  Created by Florian Aßmann on 2009-10-01.
#  Copyright 2009 Oniversus Media, Fork Unstable Media. All rights reserved.
# 

module V
  VERSION = [0,0,4]
end

require 'enumerator'
require 'open3'
require 'singleton'

begin
  require 'fastthread'
rescue
  RUBY_PLATFORM =~ /java/ or warn 'Please install fastthread.'
  require 'thread'
end

begin
  __dir__ = File.dirname __FILE__
  %w[ errors arguments operation worker future adapters ].
  each { |basename| require "#{ __dir__ }/v/#{ basename }" }
end
