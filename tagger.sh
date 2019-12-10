#!/bin/bash
#Push the systems load average and available disk space to your EC2 console as a Tag.
Aws=`which aws`
Id=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
Load=`uptime | tail -c 17 | tr ', ' '_'`
Disk=`df -h --output=avail / | sed -n '2p' | tr ' ' '_'`
Region=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}'`
$Aws ec2 create-tags --resources $Id --tags Key=LoadAverage,Value=$Load Key=DiskSpace,Value=$Disk --region $Region
