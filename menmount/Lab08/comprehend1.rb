#!/usr/bin/env ruby
#----------------------
#File: comprehend1.rb
#Version: 1.2
#Date: 02/02/2020
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'awesome_print'
require 'aws-sdk-s3'
require 'aws-sdk-comprehend'
require 'json'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab8"

$f1_version="1.2"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
my_bucket = 'menmountbucket'
#----------------------------------

my_object = 'sample.txt'
s3 = Aws::S3::Client.new(region: 'us-east-1')

#https://s3.amazonaws.com/public-sample-us-east-1/TopicModeling/Sample.txt
s3.copy_object(bucket: my_bucket,copy_source: "public-sample-us-east-1/TopicModeling/Sample.txt",key: my_object)

puts "Objects in Bucket (#{my_bucket}):"
MyLog.log.info "Objects in Bucket (#{my_bucket}):"
s3.list_objects({bucket: my_bucket,}).contents.each do |item|
  puts "  Name:  #{item.key}"
  MyLog.log.info "  Name:  #{item.key}"
end

#Add Policy to bucket
policy =
{
    "Version" => "2012-10-17",
    "Statement" =>
    [
        {
            "Sid" => "Comprehend_s3:GetObject",
            "Effect" => "Allow",
            "Principal" =>
            {
                "Service" => ["comprehend.amazonaws.com"]
            },
            "Action" => "s3:GetObject",
            "Resource" => ["arn:aws:s3:::#{my_bucket}/*"]
        },
        {
            "Sid" => "Comprehend_s3:ListBucket",
            "Effect" => "Allow",
            "Principal" => 
            {
                "Service" => ["comprehend.amazonaws.com"]
            },
            "Action" => "s3:ListBucket",
            "Resource" => ["arn:aws:s3:::#{my_bucket}"]
        },
        {
            "Sid": "Comprehend_s3:PutObject",
            "Effect": "Allow",
            "Principal": {
                "Service": "comprehend.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::#{my_bucket}/*"
        }
    ]
}.to_json


  resp=s3.put_bucket_policy(
   bucket: my_bucket,
   policy: policy
  )
  
  ap resp
  MyLog.log.info "Add Policy:  #{resp}"

    #Retrieve object
    s3.get_object({
        bucket: my_bucket, 
        key: my_object,
        response_target: my_object
        })

    MyLog.log.info "Object saved to #{my_object}"

    client = Aws::Comprehend::Client.new(region: 'us-east-1')
    
    inputtxt=File.new(my_object).read
    inputtxt=inputtxt[0...4000]
    resp=client.detect_dominant_language({
        text: inputtxt,
    })
    
    ap resp
    MyLog.log.info "Response: #{resp}"

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)