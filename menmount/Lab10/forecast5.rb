#!/usr/bin/env ruby
#----------------------
#File: forecast5.rb
#Version: 1.0
#Date: 01/26/2020
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'awesome_print'
require 'aws-sdk-forecastqueryservice'
require "gnuplot"

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab10"
$f1_version="1.0"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
forecast_arn="arn:aws:forecast:us-east-1:767398022705:forecast/MyForecast"
#----------------------------------

#This script will:
#-Pull and prepare training data
#-Query forecast data and prepare
#-Generate plot of results

# ForecastData Class
class ForecastData
  def initialize(name)  
    # Instance variables  
    @name = name  
  end  

  def setXvalues(x)
    @xvalues = x
  end
  
  def setYvalues(y)
    @yvalues = y
  end
  
  def getXvalues()
    return @xvalues
  end
  
  def getYvalues()
    return @yvalues
  end
  
  def getName()
    return @name
  end
end

client = Aws::ForecastQueryService::Client.new(region: 'us-east-1')

resp = client.query_forecast({
  forecast_arn: forecast_arn, # required
  start_date: "2015-01-01T01:00:00",
  end_date: "2015-01-02T12:00:00",
  filters: { # required
    "item_id" => "client_21",
  }
})

series=Array.new
resp.forecast.predictions.each do |stat|
  fd=ForecastData.new(stat[0])
  xvalues=Array.new
  yvalues=Array.new
  stat[1].each do |data|
    xvalues.push(data.timestamp)
    yvalues.push(data.value)
  end
  fd.setXvalues(xvalues)
  fd.setYvalues(yvalues)
  series.push(fd)
end



Gnuplot.open() do |gp|
    Gnuplot::Plot.new( gp ) do |plot|
        plot.terminal "png"
        #plot.terminal( 'postscript eps size 17cm,10cm font "Helvetica,12"')
        plot.output File.expand_path("../example.png", __FILE__)
    
    	plot.ylabel 'Electricty Usage'
    	#plot.xlabel "Time (starting at #{x[0]})"
    	plot.xlabel "Time"
    	plot.xdata "time"
    	plot.timefmt "'%Y-%m-%dT%H:%M:%S'"
    	plot.format "x '%Y-%m-%dT%H:%M:%S'"
    	#plot.xtics rotate
    	#set xtics rotate by 60 right
    	plot.set 'xtics rotate'
    	plot.style "data lines"
    	#plot.set 'terminal postscript color eps enhanced font "Helvetica,13" size 16cm,8cm'
    	
    	#plot.set "output 'temperature-pcb.ps'"
    	
    	series.each do |seriesdata|
        plot.data << Gnuplot::DataSet.new( [seriesdata.getXvalues(), seriesdata.getYvalues()] ) do |ds|
      		ds.with = "linespoints"
      		ds.linewidth = "3"
      		ds.title=seriesdata.getName()
      		ds.using = "1:2"
    	  end
      end
    	
    	
    end
end








#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)

