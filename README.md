# granzscientific-geiger-counter-APRS + Munin plugin

This scripts will read data from granzscientific geiger counter (https://www.tindie.com/products/granzscientific/raspberry-pi-zero-iot-geiger-counter/) and push it to the APRS network.

1. Install original Software. 
Follow this instructions: https://github.com/granzscientific/pi-zero-geiger-counter

2. Move to the PiZeroGeigerCounter/pi-software/ directory.

```
wget https://raw.githubusercontent.com/s55ma/granzscientific-geiger-counter-APRS/master/aprs_radiation.sh
wget https://raw.githubusercontent.com/s55ma/granzscientific-geiger-counter-APRS/master/pyGIwriteFile.py
chmod +x aprs_radiation.sh pyGIwriteFile.py
```

3. Run pyGIwriteFile.py at reboot.
```
crontab -e
@reboot cd /path/to/PiZeroGeigerCounter/pi-software/; python pyGIwriteFile.py &
```
4. Start pyGiwriteFile.py, it will start automatically at reboot next time.
```
./pyGIwriteFile.py &
```
5. Edit aprs_radiation.sh to your own specifications.
Run it every 3 minutes with crontab. Don't set it to 1 minute because APRS network will consider it as spam and your IP will get blocked.
```
crontab -e
*/3 * * * * cd /path/to/PiZeroGeigerCounter/pi-software/; bash aprs_radiation.sh
```
![alt text](https://i.imgur.com/05xyMjX.png)

6. This is optionally, non APRS related. You can install Munin monitoring tool and install radiation plugin. It will plot daily, weekly, monthly and yearly graphs of the radiation. Installation and configuration of the Munin is beyond this project. Get the plugin:

```
cd /etc/munin/plugins/
wget https://raw.githubusercontent.com/s55ma/granzscientific-geiger-counter-APRS/master/munin-radiation.sh
chmod +x munin-radiation-sh
```
![alt text](https://i.imgur.com/aPyUiku.png)
