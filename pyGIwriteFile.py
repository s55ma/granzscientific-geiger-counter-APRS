#!/usr/bin/env python
#This is modified pyGIconsole.py
#It writes into file instead of console.
import logging
import time
from pyGI.configurator import cfg

#setup logging
log = logging.getLogger()
log.setLevel(cfg.get('logging','level'))
formatter = logging.Formatter('%(asctime)s %(levelname)s %(name)s: %(message)s')
if cfg.getboolean('logging','write_file'):
    filehandler = logging.FileHandler(cfg.get('logging','filename'))
    filehandler.setFormatter(formatter)
    log.addHandler(filehandler)
streamhandler = logging.StreamHandler()
streamhandler.setFormatter(formatter)
log.addHandler(streamhandler)

if __name__ == "__main__":
    log.info("Starting pyGIconsole")
    from pyGI import geigercounter,geigerlog
    try:
        # get last totalcount from db
        (last_total,last_total_dtc) = geigerlog.get_last_totalcount()
        log.info("Last total: %d, total_dtc: %d"%(last_total, last_total_dtc))

        # start geigercounter
        geiger = geigercounter.Geigercounter(total=last_total, total_dtc=last_total_dtc)

        # start geigercounter logging
        geigerlog = geigerlog.GeigerLog(geiger)

        # loop, reporting rates

        last_ticks = geiger.totalcount
        log.info("Starting ticks update loop")
	while True:
	        ticks = geiger.totalcount-last_ticks
        	last_ticks = geiger.totalcount
        	file = open("radiation.txt","w")
        	file.write(str(geiger.cpm)+"\n")
		time.sleep(0.5)

    except KeyboardInterrupt:
        log.info("Stopping pyGIconsole")
        geiger.reset() # stop hardware HV generator
