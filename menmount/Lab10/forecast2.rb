#!/usr/bin/env ruby
#----------------------
#File: forecast2.rb
#Version: 1.2
#Date: 05/7/2021
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'awesome_print'
require 'aws-sdk-iam'
require 'aws-sdk-forecastservice'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab10"
$f1_version="1.2"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
bucket_name = 'menmountbucket'
#----------------------------------

#This script will:
#gem install aws-sdk-forecastservice
#gem install aws-sdk-forecastqueryservice
#-Delete forecast and predictor
#-Delete existing dataset import jobs
#-Delete existing datasets
#-Delete existing dataset groups
#-Create the dataset
#-Create the dataset group
#-Create the dataset import job

#Add Data Group ARN to end of output

def check_import_job_status(client)
  puts "Polling the status of the Import Job..."
  MyLog.log.info "Polling the status of the Import Job..."
  complete=false
  while(!complete)
    resp = client.list_dataset_import_jobs()
    #ACTIVE
    #CREATE_PENDING
    #CREATE_IN_PROGRESS
    #CREATE_FAILED
    #DELETE_PENDING
    #DELETE_IN_PROGRESS
    #DELETE_FAILED
    import_status=""
    match_found=false
    
    resp.dataset_import_jobs.each do |item|
      if(item.dataset_import_job_name=="MyDatasetImportJob")
        match_found=true
        import_status=item.status
      end
    end
    
    puts "Current status: #{import_status}"
    MyLog.log.info "Current status: #{import_status}"
    
    if(import_status=="ACTIVE")
      complete=true
    elsif (match_found==false)
      puts "ERROR! A matching Import Job was not found!"
      MyLog.log.info "ERROR! A matching Import Job was not found!"
      exit! 1
    end
    sleep(10)
  end
end


client = Aws::ForecastService::Client.new(region: 'us-east-1')

puts "Getting account number from current user information..."
MyLog.log.info "Getting account number from current user information..."
#Use the arn for user to get account ID
currentuser=Aws::IAM::CurrentUser.new(region: 'us-east-1')
acctnum=currentuser.arn.split(':')[4]
ap "Account Number: "+acctnum
MyLog.log.info "Account Number: "+acctnum

puts "--------"
MyLog.log.info "--------" 

#----------------Handle deletions first!!!!----------------------
#----------------Dataset Import Job
puts "Using account number to generate an ARN and check if dataset import job already exists..."
MyLog.log.info "Using account number to generate an ARN and check if dataset import job already exists..."
dsi_arn="arn:aws:forecast:us-east-1:"+acctnum+":dataset-import-job/MyDataset/MyDatasetImportJob"
ap "Dataset Import Job ARN: "+dsi_arn
MyLog.log.info "Dataset Import Job ARN: "+dsi_arn

puts "List of current dataset import job:"
MyLog.log.info "List of current dataset import job:"
resp = client.list_dataset_import_jobs()
item_exists=false
resp.dataset_import_jobs.each do |item|
  puts item.dataset_import_job_name
  MyLog.log.info item.dataset_import_job_name
  if(item.dataset_import_job_arn==dsi_arn)
    item_exists=true
  end
end
puts "--------"
MyLog.log.info "--------"
if(item_exists)
  puts "Match Found!"
  status_resp = client.describe_dataset_import_job({
    dataset_import_job_arn: dsi_arn, # required
  })
  if(status_resp.status!="ACTIVE" && status_resp.status!="CREATE_FAILED")
    puts "The dataset import job is not in a status of ACTIVE or CREATE_FAILED. It can not be deleted at this time."
    MyLog.log.info "The dataset import job is not in a status of ACTIVE or CREATE_FAILED. It can not be deleted at this time."
    puts "You will need to wait a few minutes for the import to finish before rerunning the script or you can try deleting the import in the AWS console."
    MyLog.log.info "You will need to wait a few minutes for the import to finish before rerunning the script or you can try deleting the import in the AWS console."
    exit! 1
  end
  puts "Deleting existing dataset import job..."
  MyLog.log.info "Deleting existing dataset import job..."
  resp = client.delete_dataset_import_job({
    dataset_import_job_arn: dsi_arn, # required
  })
  #Sleep so the change has time to take effect.
  sleep(20)
  puts "Response"
  ap resp
  MyLog.log.info resp.awesome_inspect
else
  puts "Match Not Found!"
end

sleep(10) #Need a delay here so that AWS has time to register that the item was deleted.

#----------------Dataset
puts "Using account number to generate an ARN and check if dataset already exists..."
MyLog.log.info "Using account number to generate an ARN and check if dataset already exists..."
ds_arn="arn:aws:forecast:us-east-1:"+acctnum+":dataset/MyDataset"
ap "Dataset ARN: "+ds_arn
MyLog.log.info "Dataset ARN: "+ds_arn

puts "List of current datasets:"
resp = client.list_datasets()
item_exists=false
resp.datasets.each do |item|
  puts item.dataset_name
  MyLog.log.info item.dataset_name
  if(item.dataset_arn==ds_arn)
    item_exists=true
  end
end

puts "--------"
MyLog.log.info "--------"

if(item_exists)
  puts "Match Found!"
  MyLog.log.info "Match Found!"
  
  status_resp = client.describe_dataset({
    dataset_arn: ds_arn, # required
  })
  
  if(status_resp.status!="ACTIVE" && status_resp.status!="CREATE_FAILED")
    puts "The dataset is not in a status of ACTIVE or CREATE_FAILED. It can not be deleted at this time."
    MyLog.log.info "The dataset is not in a status of ACTIVE or CREATE_FAILED. It can not be deleted at this time."
    puts "You will need to wait a few minutes for the status to change before rerunning the script or you can try deleting the dataset in the AWS console."
    MyLog.log.info "You will need to wait a few minutes for the status to change before rerunning the script or you can try deleting the dataset in the AWS console."
    exit! 1
  end
  
  puts "Deleting existing dataset..."
  MyLog.log.info "Deleting existing dataset..."
  resp = client.delete_dataset({
    dataset_arn: ds_arn, # required
  })
  #Sleep so the change has time to take effect.
  sleep(20)
  puts "Response"
  MyLog.log.info "Response"
  ap resp
  MyLog.log.info resp.awesome_inspect
else
  puts "Match Not Found!"
  MyLog.log.info "Match Not Found!"
end

sleep(10) #Need a delay here so that AWS has time to register that the item was deleted.

#----------------Dataset Group
puts "Using account number to generate an ARN and check if dataset group already exists..."
MyLog.log.info "Using account number to generate an ARN and check if dataset group already exists..."
dsg_arn="arn:aws:forecast:us-east-1:"+acctnum+":dataset-group/MyDatasetGroup"
ap "Dataset Group ARN: "+dsg_arn
MyLog.log.info "Dataset Group ARN: "+dsg_arn
  
puts "List of current datasets groups:"
MyLog.log.info "List of current datasets groups:"
resp = client.list_dataset_groups()
item_exists=false
resp.dataset_groups.each do |item|
  puts item.dataset_group_name
  MyLog.log.info item.dataset_group_name
  if(item.dataset_group_arn==dsg_arn)
    item_exists=true
  end
end

puts "--------"
MyLog.log.info "--------"

if(item_exists)
  puts "Match Found!"
  MyLog.log.info "Match Found!"
  
  status_resp = client.describe_dataset_group({
    dataset_group_arn: dsg_arn, # required
  })
  
  if(status_resp.status!="ACTIVE" && status_resp.status!="CREATE_FAILED")
    puts "The dataset group is not in a status of ACTIVE or CREATE_FAILED. It can not be deleted at this time."
    MyLog.log.info "The dataset group is not in a status of ACTIVE or CREATE_FAILED. It can not be deleted at this time."
    puts "You will need to wait a few minutes for the status to change before rerunning the script or you can try deleting the dataset group in the AWS console."
    MyLog.log.info "You will need to wait a few minutes for the status to change before rerunning the script or you can try deleting the dataset group in the AWS console."
    exit! 1
  end
  
  puts "Deleting existing dataset group..."
  MyLog.log.info "Deleting existing dataset group..."
  resp = client.delete_dataset_group({
    dataset_group_arn: dsg_arn, # required
  })
  #Sleep so the change has time to take effect.
  sleep(20)
  puts "Response"
  MyLog.log.info "Response"
  ap resp
  MyLog.log.info resp.awesome_inspect
else
  puts "Match Not Found!"
  MyLog.log.info "Match Not Found!"
end

puts "--------"  
MyLog.log.info "--------"  

sleep(10) #Need a delay here so that AWS has time to register that the item was deleted.

#----------------Handle creations second!!!!----------------------
#----------------Dataset
begin
  resp = client.create_dataset({
    dataset_name: "MyDataset", # required
    domain: "CUSTOM", # required, accepts RETAIL, CUSTOM, INVENTORY_PLANNING, EC2_CAPACITY, WORK_FORCE, WEB_TRAFFIC, METRICS
    dataset_type: "TARGET_TIME_SERIES", # required, accepts TARGET_TIME_SERIES, RELATED_TIME_SERIES, ITEM_METADATA
    data_frequency: "H",
    schema: { # required
      attributes: [
        {
          attribute_name: "timestamp",
          attribute_type: "timestamp", # accepts string, integer, float, timestamp
        },
        {
          attribute_name: "target_value",
          attribute_type: "float", # accepts string, integer, float, timestamp
        },
        {
          attribute_name: "item_id",
          attribute_type: "string", # accepts string, integer, float, timestamp
        },
      ],
    },
  })
rescue Exception => error  
  puts "There was an error during creation of the dataset! Please try running again..."
  MyLog.log.info "There was an error during creation of the dataset! Please try running again..."
  puts "Error:"
  MyLog.log.info "Error:"
  puts error
  MyLog.log.info error.awesome_inspect
  exit! 1
end 

puts "Dataset successfully created!"
MyLog.log.info "Dataset successfully created!"
ap resp
MyLog.log.info resp.awesome_inspect
ds_arn=resp.dataset_arn

puts "--------"
MyLog.log.info "--------"

#----------------Dataset Group
begin  
  resp = client.create_dataset_group({
    dataset_group_name: "MyDatasetGroup", # required
    domain: "CUSTOM", # required, accepts RETAIL, CUSTOM, INVENTORY_PLANNING, EC2_CAPACITY, WORK_FORCE, WEB_TRAFFIC, METRICS
    dataset_arns: [ds_arn],
  })  
rescue Exception => error  
  puts "There was an error during creation of the dataset group! Please try running again..."
  MyLog.log.info "There was an error during creation of the dataset group! Please try running again..."
  puts "Error:"
  MyLog.log.info "Error:"
  puts error
  MyLog.log.info error.awesome_inspect
  exit! 1
end 

puts "Dataset group successfully created!"
MyLog.log.info "Dataset group successfully created!"
ap resp
MyLog.log.info resp.awesome_inspect
dsg_arn=resp.dataset_group_arn

puts "--------"
MyLog.log.info "--------"

#----------------Dataset Import
starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

begin
  path="s3://"+bucket_name+"/electricityusagedata.csv"
  role_arn="arn:aws:iam::"+acctnum+":role/forecast_role"
  resp = client.create_dataset_import_job({
    dataset_import_job_name: "MyDatasetImportJob", # required
    dataset_arn: ds_arn, # required
    data_source: { # required
      s3_config: { # required
        path: path, # required
        role_arn: role_arn, # required
      },
    },
    #timestamp_format: "TimestampFormat",
  })
rescue Exception => error
  puts "There was an error during creation of the dataset import job! Please try running again..."
  MyLog.log.info "There was an error during creation of the dataset import job! Please try running again..."
  puts "Error:"
  MyLog.log.info "Error:"
  puts error
  MyLog.log.info error.awesome_inspect
  exit! 1
end 

#Wait for cimport to complete
check_import_job_status(client)
ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)

elapsed = ending - starting
elapsed =elapsed/60

puts "Import took #{elapsed} minutes to complete!"
MyLog.log.info "Import took #{elapsed} minutes to complete!"


puts "Dataset import job successfully created!"
MyLog.log.info "Dataset import job successfully created!"
ap resp
MyLog.log.info resp.awesome_inspect
dsi_arn=resp.dataset_import_job_arn

puts "--------"
MyLog.log.info "--------"

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)

