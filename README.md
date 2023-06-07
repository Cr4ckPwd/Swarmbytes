# SwarmBytes Setup
1. Download package

Download Swarmbytes:
.deb (for Debian based linux)
.rpm (for Redhat based linux)
.apk (Alpine Linux package)
2. Run package

Run dpkg -i swarmbytes.deb or rpm -i swarmbytes.rpm as a super user (sudo).
3. Create Swarmbytes configuration file config.yaml:

either by running swarmbytes to generate a configuration file (file ./config.yml will be created);
or use sample configuration (see below).
4. Place the generated config.yaml in one of the following directories:

/etc/swarmbytes/
~/.swarmbytes/
./ (directory from which you start swarmbytes)
5. Edit the configuration file:

fill in your API key;
enumerate local IPs that the Swarmbytes app should bind to.
6. IPs and IP ranges can be in any of the following formats:

Single IP: xx.xx.xx.xx
An IP range: xx.xx.xx.xx-xx.xx.xx.yy
An IP subnet: xx.xx.xx.xx/yy
7. Run $ ulimit -n 65535

8. Run $ swarmbytes

use any of the ways to put it into background ( nohup, screen, tmux, bg or others );
service / daemonization options will be added in future releases.
Run in debug mode
to run swarmbytes in debug mode with more verbose logging, use -debug flag.
example of storing the log file in debug mode and run in the background: swarmbytes -debug 2>&1 >> swb_output.log &.
Verify flag
Verify flag -verify: will run swarmbytes app in configuration verification mode. It will test the configured IPs sequentially, verifying that IP's are configuration correctly and can be accessed from outside.
Suggestions on keeping the app running
You as a provider must be concerned in keeping Swarmbytes application running at all times since it directly affects your DACIP count, thus your monthly earnings.

Sometimes Swarmbytes application may crash due to variety of reasons (e.g. lack of resources and OOM, network connection interruptions, etc.) so it’s a good idea to ensure that you always have enough resources for Swarmbytes to run and monitor its state.

One of the things you can also consider is restarting swarmbytes application if it crashes for any reason. You can do this by:

Using process manager in order to monitor Swarmbytes process and respawn it on exit ( supervisord, PM2, forever, or any other solution of your choice).
Write a simple yet effective custom script for keeping Swarmbytes application alive. Example bash script for achieving that:
#!/bin/bash 
while ! swarmbytes 
do 
  sleep 1 
  echo "Restarting swarmbytes application..." 
done
and run this script instead of directly running swarmbytes.
