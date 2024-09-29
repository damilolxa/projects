#!/usr/bin/env ruby
#----------------------
#File: forecast4.rb
#Version: 1.0
#Date: 01/26/2020
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'awesome_print'
require 'aws-sdk-forecastservice'


require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab10"
$f1_version="1.0"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
predictor_arn="arn:aws:forecast:us-east-1:767398022705:predictor/MyPredictor"

#----------------------------------

#This script will:
#-Delete Forecast
#-Wait for deletion to complete
#-Create Forecast
#-Wait for creation to complete

#Takes about 26 minutes!!!!!!

def check_forecast_creation_status(client)
  puts "Polling the status of the Forecast creation..."
  MyLog.log.info "Polling the status of the Forecast creation..."
  complete=false
  while(!complete)
    resp = client.list_forecasts()  
    #ACTIVE
    #CREATE_IN_PROGRESS
    #CREATE_PENDING
    #DELETE_PENDING
    #DELETE_IN_PROGRESS
    forecast_status=""
    match_found=false
    resp.forecasts.each do |item|
      
      if(item.forecast_name=="MyForecast")
        match_found=true
        forecast_status=item.status
      end
    end
    
    puts "Current status: #{forecast_status}"
    MyLog.log.info "Current status: #{forecast_status}"
    
    if(forecast_status=="ACTIVE")
      complete=true
    elsif (match_found==false)
      puts "ERROR! A matching Forecast was not found!"
      MyLog.log.info "ERROR! A matching Forecast was not found!"
      exit! 1
    end
    sleep(10)
  end
end

def check_forecast_deletion_status(client)
  puts "Polling the status of the Forecast deletion..."
  MyLog.log.info "Polling the status of the Forecast deletion..."
  processing=true
  while(processing)
    resp = client.list_forecasts()  
    #ACTIVE
    #CREATE_IN_PROGRESS
    #CREATE_PENDING
    #DELETE_PENDING
    #DELETE_IN_PROGRESS
    forecast_status=""
    match_found=false
    resp.forecasts.each do |item|
      
      if(item.forecast_name=="MyForecast")
        match_found=true
        forecast_status=item.status
      end
    end
    
    puts "Current status: #{forecast_status}"
    MyLog.log.info "Current status: #{forecast_status}"
    
    if(forecast_status=="DELETE_PENDING" || forecast_status=="DELETE_IN_PROGRES")
      processing=true
    elsif(match_found==false)
      puts "Deletion Complete!"
      MyLog.log.info "Deletion Complete!"
      processing=false
    end
    sleep(10)
    forecast_status=""
  end
end

client = Aws::ForecastService::Client.new(region: 'us-east-1')

#Delete old predictor if it exists
process_delete=false
resp = client.list_forecasts()
resp.forecasts.each do |item|
  if(item.forecast_name=="MyForecast")
    oldarn=item.forecast_arn
    forecast_status=item.status
    if(forecast_status!="ACTIVE" && forecast_status!="CREATE_FAILED")
      puts "The Forecast is not in a status of ACTIVE or CREATE_FAILED. It can not be deleted at this time."
      MyLog.log.info "The Forecast is not in a status of ACTIVE or CREATE_FAILED. It can not be deleted at this time."
      puts "You will need to wait a few minutes for the status to change before rerunning the script or you can try deleting the Forecast in the AWS console."
      MyLog.log.info "You will need to wait a few minutes for the status to change before rerunning the script or you can try deleting the Forecast in the AWS console."
      exit! 1
    end
    
    puts "Deleting old Forecast!"
    MyLog.log.info "Deleting old Forecast!" 
    delresp = client.delete_forecast({
      forecast_arn: oldarn, # required
    })
    puts delresp
    MyLog.log.info delresp
    process_delete=true
  end
end

#Wait for deletion to complete
if(process_delete)
  check_forecast_deletion_status(client)
end


#Create Predictor
starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
resp = client.create_forecast({
  forecast_name: "MyForecast", # required
  predictor_arn: predictor_arn, # required
})

#Wait for creation to complete
check_forecast_creation_status(client)
ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)

elapsed = ending - starting
elapsed =elapsed/60

puts "Creation took #{elapsed} minutes to complete!"
MyLog.log.info "Creation took #{elapsed} minutes to complete!"

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)

