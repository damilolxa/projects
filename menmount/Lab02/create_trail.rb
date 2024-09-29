#!/usr/bin/env ruby
#----------------------
#File: create_trail.rb
#Version: 1.3
#Date: 01/24/2021
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'awesome_print'
require 'aws-sdk-cloudtrail'
require 'aws-sdk-s3'
require 'aws-sdk-sts'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab2"

$f1_version="1.3"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
bucket="menmountbucket"
name="menmounttrail"
#----------------------------------

attach_policy = true

# Attach IAM policy to bucket
def add_policy(bucket)
  # Get account ID using STS
  sts_client = Aws::STS::Client.new(region: 'us-east-1')
  resp = sts_client.get_caller_identity({})
  account_id = resp.account

  # Attach policy to S3 bucket
  s3_client = Aws::S3::Client.new(region: 'us-east-1')

  begin
    policy = {
      'Version' => '2012-10-17',
      'Statement' => [
        {
          'Sid' => 'AWSCloudTrailAclCheck20150319',
          'Effect' => 'Allow',
          'Principal' => {
            'Service' => 'cloudtrail.amazonaws.com',
          },
          'Action' => 's3:GetBucketAcl',
          'Resource' => 'arn:aws:s3:::' + bucket,
        },
        {
          'Sid' => 'AWSCloudTrailWrite20150319',
          'Effect' => 'Allow',
          'Principal' => {
            'Service' => 'cloudtrail.amazonaws.com',
          },
          'Action' => 's3:PutObject',
          'Resource' => 'arn:aws:s3:::' + bucket + '/AWSLogs/' + account_id + '/*',
          'Condition' => {
            'StringEquals' => {
              's3:x-amz-acl' => 'bucket-owner-full-control',
            },
          },
        },
      ]
    }.to_json
    MyLog.log.info "Attaching policy to bucket."
    s3_client.put_bucket_policy(
      bucket: bucket,
      policy: policy
    )

    puts 'Successfully added policy to bucket ' + bucket
    MyLog.log.info "Successfully added policy to bucket #{bucket}"
  rescue StandardError => err
    puts 'Got error trying to add policy to bucket ' + bucket + ':'
    puts err
    MyLog.log.info "Got error trying to add policy to bucket  #{bucket}"
    exit 1
  end
end

# ------------- main
puts "Bucket requested is #{bucket}."
MyLog.log.info "Bucket requested is #{bucket}."
puts "Requested name for Trail is #{name}"
MyLog.log.info "Requested name for Trail is #{name}"


if attach_policy
  add_policy(bucket)
end

# Create client in us-east-2
client = Aws::CloudTrail::Client.new(region: 'us-east-1')

begin
  resp = client.create_trail({
    name: name, # required
    s3_bucket_name: bucket, # required
  })
  ap resp
  MyLog.log.info resp
  puts 'Successfully created CloudTrail ' + name + ' in us-east-1'
  MyLog.log.info "Successfully created CloudTrail #{name} in us-east-1"
rescue StandardError => err
  puts 'Got error trying to create trail ' + name + ':'
  puts err
  MyLog.log.info "Got error trying to create trail #{name}:"
  MyLog.log.info err
  exit 1
end

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)
