#!/usr/bin/env ruby
#----------------------
#File: forecast1.rb
#Version: 1.1
#Date: 04/30/2020
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'awesome_print'
require 'aws-sdk-iam'
require 'aws-sdk-s3'

require 'fileutils'
require 'open-uri'
require 'zip'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab10"
$f1_version="1.0"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
bucket_name = 'menmountbucket'
#----------------------------------

#gem install fileutils
#gem install rubyzip

#This script will:
#-Download the data in a zip file
#-Unzip the CSV contents
#-Upload the data to S3
#-Create a trust policy
#-Create a permissions policy
#-Create an IAM role

#Method for extracting from zip files
def extract_zip(file, destination)
  FileUtils.mkdir_p(destination)

  Zip::File.open(file) do |zip_file|
    zip_file.each do |f|
      fpath = File.join(destination, f.name)
      zip_file.extract(f, fpath) unless File.exist?(fpath)
    end
  end
end

#Download the following zip file
#https://docs.aws.amazon.com/forecast/latest/dg/samples/electricityusagedata.zip
#puts "Downloading zip file to environment..."
#my_file = 'electricityusagedata.zip'
#open(my_file, 'wb') do |file|
 # file << open('https://docs.aws.amazon.com/forecast/latest/dg/samples/electricityusagedata.zip').read
#end
#puts "Downloaded zip file!"
#MyLog.log.info "Downloaded zip file!"

#Extract the zip file contents
#puts "Extracting zip file contents to environment..."
#extract_zip(my_file, ".")
#puts "Extracted zip file!"
#MyLog.log.info "Extracted zip file!" 

#Upload the file to S3
my_object = 'electricityusagedata.csv'
s3 = Aws::S3::Client.new(region: 'us-east-1')
puts "Uploading CSV file to S3..."
file1 = File.new(my_object)
resp=s3.put_object({
  body: file1, 
  bucket: bucket_name, 
  key: my_object, 
})

puts "Response:"
ap resp
MyLog.log.info resp.awesome_inspect

puts "--------"

client = Aws::IAM::Client.new(region: 'us-east-1')
iam = Aws::IAM::Resource.new(client: client)

puts "Creating trust policy document for new IAM role for Forecast..."
forecast_trust_policy={
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "forecast.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}.to_json

puts "Trust Policy Document:"
ap forecast_trust_policy
MyLog.log.info forecast_trust_policy.awesome_inspect

puts "--------"

rolename='forecast_role'
puts "Checking if role name is already in use..."
resp = client.list_roles({
})
MyLog.log.info resp.awesome_inspect

puts "Existing roles:"
role_exists=false
resp.roles.each do |r|
  puts r.role_name
  if(r.role_name==rolename)
    role_exists=true
  end
end

puts "--------"

if(role_exists)
  puts "Match Found!"
  puts "Detaching policies from role..."
  role=iam.role(rolename)
  role.attached_policies().each do |p|
    role.detach_policy({
      policy_arn: p.arn, # required
    })
  end
  puts "Policies Detached!"
  
  puts "Deleting existing role..."
  resp = client.delete_role({
    role_name: rolename, 
  })
  puts "Response"
  ap resp
  MyLog.log.info resp.awesome_inspect
else
  puts "Match Not Found!"
end

puts "--------"

puts "Creating new IAM role for Forecast from document..."
role = iam.create_role({
 role_name: 'forecast_role',
 assume_role_policy_document: forecast_trust_policy
})
puts "New role created!"
ap role
MyLog.log.info role.awesome_inspect

puts "--------"

puts "Creating permission policy document for IAM role for Forecast..."
forecast_permission_policy={
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ]
        }
    ]
}.to_json
puts "Permission Policy Document:"
ap forecast_permission_policy
MyLog.log.info forecast_permission_policy.awesome_inspect

puts "--------"

policyname='forecast_policy'
puts "Checking if policy name is already in use..."
resp = client.list_policies({
})

puts "Existing policies:"
policy_exists=false
forecast_policy_arn=""
resp.policies.each do |p|
  puts p.policy_name
  if(p.policy_name==policyname)
    policy_exists=true
    forecast_policy_arn=p.arn
  end
end

puts "--------"

if(policy_exists)
  puts "Match Found!"
  puts "Deleting existing policy..."
  resp = client.delete_policy({
    policy_arn: forecast_policy_arn, # required
  })
  puts "Response"
  ap resp
  MyLog.log.info resp.awesome_inspect
else
  puts "Match Not Found!"
end

puts "--------"

puts "Creating new permission policy from document..."
create_policy_response = iam.create_policy({
  policy_name: 'forecast_policy',
  policy_document: forecast_permission_policy
})
puts "New policy created!"
forecast_policy_arn = create_policy_response.arn
puts "Policy ARN: #{forecast_policy_arn}"
MyLog.log.info "Policy ARN: #{forecast_policy_arn}"

puts "--------"

puts "Attaching permission policy to role..."
role.attach_policy({
  policy_arn: forecast_policy_arn
})
puts "Policy attached!"

MyLog.log.info role.awesome_inspect

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)

