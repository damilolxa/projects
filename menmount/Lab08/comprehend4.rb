#!/usr/bin/env ruby
#----------------------
#File: comprehend4.rb
#Version: 1.2
#Date: 02/02/2020
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'awesome_print'
require 'aws-sdk-comprehend'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab8"

$f1_version="1.2"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
my_bucket = 'menmountbucket'
arn = 'arn:aws:iam::767398022705:role/ComprehendRole'
#----------------------------------

my_object = 'sample.txt'

client = Aws::Comprehend::Client.new(region: 'us-east-1')
  resp = client.start_topics_detection_job({
   input_data_config: { # required
      s3_uri: "s3://"+my_bucket+"/"+my_object, # required
      input_format: "ONE_DOC_PER_LINE", # accepts ONE_DOC_PER_FILE, ONE_DOC_PER_LINE
   },
   output_data_config: { # required
      s3_uri: "s3://"+my_bucket+"/", # required
   },
   data_access_role_arn: arn, # required
   job_name: "ITEC427",
   number_of_topics: 10,
  })
 
ap resp
MyLog.log.info "Job Creation Response: #{resp}"
#Store job_id to pull status later
jobid=resp.job_id
MyLog.log.info "Job ID: #{jobid}"
 
sleep(10)
#Need to wait for the datasource tasks to complete
complete=false
#Pull status and print once
resp = client.describe_topics_detection_job({
        job_id: "#{jobid}", # required
    })
ap resp
MyLog.log.info "Job Check Response: #{resp}"
complete=(resp.topics_detection_job_properties.job_status=="COMPLETED")
while complete==false
    puts "Polling the status of job..."
    MyLog.log.info "Polling the status of job..."
    resp = client.describe_topics_detection_job({
        job_id: "#{jobid}", # required
    })
    puts "Current Job Status: "+resp.topics_detection_job_properties.job_status
    MyLog.log.info "Current Job Status: #{resp.topics_detection_job_properties.job_status}"
    #Make the code wait 10 second before polling the status
    sleep(10)
    complete=(resp.topics_detection_job_properties.job_status=="COMPLETED")
end

puts "Topics Detection Completed Successfully!!!"
MyLog.log.info "Topics Detection Completed Successfully!!!"
ap resp
MyLog.log.info "Final Response: #{resp}"

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)