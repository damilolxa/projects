#!/usr/bin/env ruby
#----------------------
#File: forecast3.rb
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
dataset_group_arn="arn:aws:forecast:us-east-1:767398022705:dataset-group/MyDatasetGroup"
#----------------------------------

learning_algorithm_ARN="arn:aws:forecast:::algorithm/ETS"

#This script will:
#-Delete Predictor
#-Wait for deletion to complete
#-Create Predictor
#-Wait for creation to complete

#Add in a place where it spits out the ARN for the predictor.
#Takes about 25 minutes!!!!!!

def check_predictor_creation_status(client)
  puts "Polling the status of the Predictor creation..."
  MyLog.log.info "Polling the status of the Predictor creation..."
  complete=false
  while(!complete)
    resp = client.list_predictors()  
    #ACTIVE
    #CREATE_IN_PROGRESS
    #CREATE_PENDING
    #DELETE_PENDING
    #DELETE_IN_PROGRESS
    predictor_status=""
    match_found=false
    resp.predictors.each do |item|
      
      if(item.predictor_name=="MyPredictor")
        match_found=true
        predictor_status=item.status
      end
    end
    
    puts "Current status: #{predictor_status}"
    MyLog.log.info "Current status: #{predictor_status}"
    
    if(predictor_status=="ACTIVE")
      complete=true
    elsif (match_found==false)
      puts "ERROR! A matching Predictor was not found!"
      MyLog.log.info "ERROR! A matching Predictor was not found!"
      exit! 1
    end
    sleep(10)
  end
end

def check_predictor_deletion_status(client)
  puts "Polling the status of the Predictor deletion..."
  MyLog.log.info "Polling the status of the Predictor deletion..."
  processing=true
  while(processing)
    resp = client.list_predictors()  
    #ACTIVE
    #CREATE_IN_PROGRESS
    #CREATE_PENDING
    #DELETE_PENDING
    #DELETE_IN_PROGRESS
    predictor_status=""
    match_found=false
    resp.predictors.each do |item|
      
      if(item.predictor_name=="MyPredictor")
        match_found=true
        predictor_status=item.status
      end
    end
    
    puts "Current status: #{predictor_status}"
    MyLog.log.info "Current status: #{predictor_status}"
    
    if(predictor_status=="DELETE_PENDING" || predictor_status=="DELETE_IN_PROGRES")
      processing=true
    elsif(match_found==false)
      puts "Deletion Complete!"
      MyLog.log.info "Deletion Complete!"
      processing=false
    end
    sleep(10)
    predictor_status=""
  end
end

client = Aws::ForecastService::Client.new(region: 'us-east-1')

#Delete old predictor if it exists
process_delete=false
resp = client.list_predictors()
resp.predictors.each do |item|
  if(item.predictor_name=="MyPredictor")
    oldarn=item.predictor_arn
    predictor_status=item.status
    if(predictor_status!="ACTIVE" && predictor_status!="CREATE_FAILED")
      puts "The Predictor is not in a status of ACTIVE or CREATE_FAILED. It can not be deleted at this time."
      MyLog.log.info "The Predictor is not in a status of ACTIVE or CREATE_FAILED. It can not be deleted at this time."
      puts "You will need to wait a few minutes for the status to change before rerunning the script or you can try deleting the Predictor in the AWS console."
      MyLog.log.info "You will need to wait a few minutes for the status to change before rerunning the script or you can try deleting the Predictor in the AWS console."
      exit! 1
    end
    
    puts "Deleting old Predictor!"
    MyLog.log.info "Deleting old Predictor!" 
    delresp = client.delete_predictor({
      predictor_arn: oldarn, # required
    })
    puts delresp
    MyLog.log.info delresp
    process_delete=true
  end
end

#Wait for deletion to complete
if(process_delete)
  check_predictor_deletion_status(client)
end


#Create Predictor
starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
resp = client.create_predictor({
  predictor_name: "MyPredictor", # required
  algorithm_arn: learning_algorithm_ARN,
  forecast_horizon: 36, # required
  input_data_config: { # required
    dataset_group_arn: dataset_group_arn, # required
  },
  featurization_config: { # required
    forecast_frequency: "H", # required
  }
})


#Wait for creation to complete
check_predictor_creation_status(client)
ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)

elapsed = ending - starting
elapsed =elapsed/60

puts "Creation took #{elapsed} minutes to complete!"
MyLog.log.info "Creation took #{elapsed} minutes to complete!"

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)

