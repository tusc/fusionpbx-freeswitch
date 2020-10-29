# FusionPBX/FreeSwitch for the UDM/UDM pro

## Distributed under MIT license

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


## Project Notes
**Author:** Carlos Talbot (@tusc69 on ubnt forums, @rlos on discord)

# Installing

This is a prebuilt image of Freeswitch & FusionPBX to run directly on a UDM or UDM PRO. The Docker image has been configured to perserve data between upgrades. If you have Unifi Talk running on your UDM Pro you will have to shut it down as there will be port conflicts for 5060 and 5080.

First step is to create a directory for perserving the database and settings between upgrades. You can choose /mnt/data/fusionpbx or /mnt/data_ext/fusionpbx if you have an external drive in the UDM Pro.
```
mkdir /mnt/data/fusionpbx
```

In order to install this image you will need to log into the UDM via ssh and type the following command:

```
podman run --name fusionpbx --net=host -v /etc/localtime:/etc/localtime:ro -v /mnt/data/fusionpbx:/data -e PGPASSWORD=passw0rd  tusc/fusionpbx-freeswitch
```
This will download the latest image to the UDM and start the container. 
The PGPASSWORD is for the PostgreSQL account. If you change this you'll need to update the password during the FusionPBX setup. You should see output from podman such as below:

![Blockgroup](/pics/pic1.png)

You'll need to connect to the WAN ip of your UDM to configure FusionPBX via https to port 9181. (e.g. https://WANIP:9181)
You should be greeted with the language screen

Go ahead and select your preferred language and click next.

![Blockgroup](/pics/setup1.png)

You should leave the defaults on the page. Click next.

![Blockgroup](/pics/setup2.png)

Next you'll want to specify an admin account and password for the FusionPBX interface. When the wizard completes, you will be prompted for this account to login.

![Blockgroup](/pics/setup3.png)

Finally, on the last page you want to specify a username and password for the PostgreSQL database. Specify Database username fusionpbx and password passw0rd (unless you changed this above).
When you click next you will wait for up to 20 seconds as it initializes the database and FreeSwitch. When complete, you will be prompted with the login below.

![Blockgroup](/pics/setup4.png)

At this point you can create an extension(Accounts, Extensions) and a gateway(Accounts, Gateways). If you have an account with Skyetel you'll note it's relatively easy to configure this provider as FusionPBX makes it easy to configure.
https://support.skyetel.com/hc/en-us/articles/360041177393-FusionPBX

**Please note** When configuring an endpoint, make sure you are specifying the WAN IP address of the UDM as the proxy address on your SIP device. FreeSwitch checks to see if it's running on a server with a direct WAN connection and will not listen to 5060 on the internal address.
This section goes over the process of configuring an endpoint in FusionPBX: https://docs.fusionpbx.com/en/latest/applications/provision.html

# Limitations

This image is based on FreeSwitch 1.10.3 and FusionPBX 4.4.1 using the latest packages from an Alpine docker container. Not all features of FreeSwitch are included with this build.
For now, music on hold is not working and I'm in the process of troubleshooting the issue.

## Building
Build on your UDM or build on another device using buildx and targeting arm64
```
docker buildx build --platform linux/arm64 -t fusionpbx-freeswitch:latest .
```
# Uninstalling

To remove the docker instance and image you'll need to type the following at the UDM ssh prompt:


```
podman stop fusionpbx
podman rm fusionpbx
podman rmi tusc/fusionpbx-freeswitch
```
