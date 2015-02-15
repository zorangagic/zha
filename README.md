# zha - AWS High availability Clustering
# https://github.com/zorangagic/zha
# http://blog.zorangagic.com/2015/02/high-availability-clustering-on-aws.html
#
# Zoran Gagic - zorang at gmail.com
#
# Copyright (C) 2015  Zoran Gagic

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

See http://blog.zorangagic.com/2015/02/high-availability-clustering-on-aws.html

Here is how to get started:
1. Create a Linux instance, tag it with key HA_ROLE value PRIMARY
2. Create a secondary ENI and attach it to the primary instance, this will be used for shared IP address
3. Create EBS volume(s) and attach to primary instance, this will be used for shared storage. Create entry in /etc/fstab and configure file system not to auto mount on boot.
4. Install application on shared EBS volume(s)
5. Test application
6. Copy all clustering files to /usr/local/zha, file structure will be:
       zha - primary clustering script (see below)
       zha.start - start zha clustering
       zha.stop - stop zha clustering
       zha.status - satus for zha clustering
       log - directory where cluster logs are kept
7. Create application start,stop,status scripts and place in /usr/local/zha. Use names:
      start-{app}.sh
      stop-{app}.sh
      status-{app}.sh
8.  Test start, stop of application
9.  Run application, then force failure such as:
         - run halt command
         - stop instance
         - cause Linux to panic
     Then restart Linux, manually attach shared EBS volume(s), manually attach shared ENI
     Test application start scripts until they can seamlessly initiate any required recovery sequence for that software start application. Repeat this step until it works.
10. Edit zha and change environment variables:
         supportemail=support@myemail.com          : In case of failure clustering will email ops team
         num_pings=10                              : Number of consecutive failed pings before failure detected
         ping_timeout=1                            : Timout in seconds for each ping
         wait_between_pings=10                     : Wait between pings in seconds
         wait_for_instance_stop=25                 : after instance stops wait time in seconds
         shared_ip=172.30.0.59                     : shared IP address
         shared_eni_id=eni-22522955                : shared IP address ENI
         shared_ebs_id=vol-6262b565                : shared EBS volume
         shared_fs_name=/data                      : shared file system
         app_start=$base/start-nfs.sh              : application start script
         app_stop=$base/stop-nfs.sh                : application stop script
         app_status=$base/status-nfs.sh            : application status script
10. Create AMI of primary
11. Create a new instance using AMI created in step 10 and tag it with key HA_ROLE value SECONDARY
12. Testing of zha:
         a) On primary:
                  - start Linux instance
                  - manually attach shared EBS volume(s)
                  - manually attach shared ENI
                  - run application start script /usr/local/zha/start-{app}.sh
         b) Test that application is running as expected on primary
         c) On secondary run zha clustering: /usr/local/zha/zha.start
         d) On secondary check that clustering is working:
                  - check status:  /usr/local/zha/zha.status
                  - check logs: cd  /usr/local/zha/logs; tail -f <logfile>
         e) Simulate failure on primary such as:
                   - ifconfig eth1 down (shared ENI)
                   - run halt command
                   - stop instance
                   - cause Linux to panic

Notes:
a) Cluster software (zha) can run on either primary or secondary. In case of genuine failure on primary the secondary will take over. In that case the primary instance can be recovered and can run the cluster software and take over if case of failure of secondary. To do this, on primary run /usr/local/zha/zha.start.
b) Cluster software:
         start: /usr/local/zha/zha.start
         stop: /usr/local/zha/zha.stop
         status: /usr/local/zha/zha.status and check /usr/local/zha/log/{logfile}
c) See example application start, stop, status scripts. Please note that status must return ok otherwise successful application takeover will not be reported.
d) If maintenance occurs on say primary node you do not want secondary node to takeover, hence stop clustering software on secondary: /usr/local/zha/zha.stop

