#!/usr/bin/env ruby
#----------------------
#File: lab_log.rb
#Version: 1.1
#Date: 08/03/2019
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$ll_version="1.1"
$LOAD_PATH << "."
require 'logger'

class MyLog
  
  def self.log
    #Delete old log file before writing out new log information
    if @logger.nil?
        if(FileTest.exist?("mylab.log"))
            File.delete("mylab.log")
        end
      @logger = Logger.new("mylab.log")
      @logger.level = Logger::DEBUG
      @logger.datetime_format = '%Y-%m-%d %H:%M:%S '
    end
    @logger
    
  end
end