# Dynamic-Tags

Dynamic Tags uses the create-tags API, meta-data service and some system monitoring utilities.
AWS CLI needs to be installed and configured with the appropriate tagging permissions.

This is what it looks like:

![Image](media/Dynamic-Tags.png)


## Permissions
Here is an IAM policy example for the instance profile using a least privilege model. 
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "ec2:CreateTags",
            "Resource": "*"
        }
    ]
}
```

## Script
This has been tested on Amazon Linux 1 and 2.
```
#!/bin/bash
#Push the systems load average and available disk space to your EC2 console as a Tag.
Aws=`which aws`
Id=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
Load=`uptime | tail -c 17 | tr ', ' '_'`
Disk=`df -h --output=avail / | sed -n '2p' | tr ' ' '_'`
Region=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}'`
$Aws ec2 create-tags --resources $Id --tags Key=LoadAverage,Value=$Load Key=DiskSpace,Value=$Disk --region $Region
```

## Executable permissions
The script needs executable permissions so that Cron can run it.
```$ chmod 700 /root/tagger.sh```

## Crontab
Here is the entry you need to make. It will run every five minutes.
```
$ crontab -e
*/5 * * * * /root/tagger.sh
$ crontab -l
```

## User Data
Add Dynamic Tags on launch of an EC2 instance.
```
#!/bin/bash
cat  > /root/tagger.sh <<__EOF__
#!/bin/bash
#Push the systems load average and available disk space to your EC2 console as a Tag.
Aws=\`which aws\`
Id=\`curl -s http://169.254.169.254/latest/meta-data/instance-id\`
Load=\`uptime | tail -c 17 | tr ', ' '_'\`
Disk=\`df -h --output=avail / | sed -n '2p' | tr ' ' '_'\`
Region=\`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print \$4}'\`
\$Aws ec2 create-tags --resources \$Id --tags Key=LoadAverage,Value=\$Load Key=DiskSpace,Value=\$Disk --region \$Region
__EOF__
chmod 700 /root/tagger.sh
crontab -l | { cat; echo "*/5 * * * * /root/tagger.sh"; } | crontab -
```

## Logging/Debugging
Execution problems will be logged here:
```
tail -f /var/log/cron
tail -f /var/mail/root
```
