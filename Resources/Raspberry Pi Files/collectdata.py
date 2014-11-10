import math
import time
import csv
import RPi.GPIO as gpio
import dhtreader
import Adafruit_BMP.BMP085 as BMP085
import MySQLdb

# Setup
gpio.setwarnings(False)
gpio.setmode(gpio.BOARD)

# Clean Up
#gpio.cleanup()

# Setup Pins etc.
# Sonar Pins
sTrig = 7
sEcho = 12

gpio.setup(sTrig, gpio.OUT)
gpio.output(sTrig, 0)
gpio.setup(sEcho, gpio.IN)
time.sleep(0.1)

# DHT22 Pin & Type
dhtType = 22
dhtPin = 17
dhtreader.init()

# BMP
bmp = BMP085.BMP085()

# Status LED Pins
#gLEDPin = 13
#gpio.setup(gLEDPin, gpio.OUT)
rLEDPin = 16
gpio.setup(rLEDPin, gpio.OUT)
yLEDPin = 15
gpio.setup(yLEDPin, gpio.OUT)

# Setup DB
db = MySQLdb.connect("localhost", "root", "raspberry", "deployment1")
curs = db.cursor()

# Recording Frequency in Seconds
frequency = 2
amountToAVG = 60/frequency

# Target Number of Days to Record
hours = 0
minutes = 2
targetTime = (hours*60)+minutes
loop = (targetTime*60)/frequency

# Initialisations
gpio.output(rLEDPin, 0)
gpio.output(yLEDPin, 0)
#gpio.output(gLEDPin, 0)

# Time to timeout the sonar sensor if taking too long in seconds
timeoutTime = 1

def collectData(numberOfTimes):
	print "Begin Recording Data"
	
	sonarMeasurements = []
	temperatureMeasurements = []
	humidityMeasurements = []
	pressureMeasurements = []
	
	# LEDs
	gpio.output(rLEDPin, 1)
	#gpio.output(gLEDPin, 0)
	
	x = 0

	while True:	
		gpio.output(yLEDPin, 1)
		print "================================================================"
		print "Measurement number: "+str(x+1)
		# Start Sonar Measurement
		gpio.output(sTrig, 1)
		time.sleep(0.00001)
		gpio.output(sTrig, 0)
        
        	timeout = time.time() + timeoutTime
        	didTimeout = False
        
		# Wait for the echo
		while gpio.input(sEcho) == 0:
			if time.time() > timeout:
                		print "Sonar sensor has timed out... Skip this round."
                		didTimeout = True
                    		break
				#pass
		start = time.time()
        	if didTimeout == False:
			timeout = time.time() + timeoutTime
		
            		# Once we get the echo
           		while gpio.input(sEcho) == 1:
               	 		if time.time() > timeout:
                			print "Sonar sensor has timed out... Skip this round."
                			didTimeout = True
                    			break
					#pass
			stop = time.time()

        	if didTimeout == False:
			# Assuming sound travels at 340m/s
			# Remove a zero for distance in centimetres
			distance = (stop-start)*170000
			# Finish Sonar Measurement
		
			print "Got Sonar: "+str(distance)+"mm."
			try:
				# Start Fetching DHT22 Measurements
				readings = dhtreader.read(dhtType, dhtPin)
				temperature = readings[0]
				humidity = readings[1]
				# Finish DHT22 Measurements
				#print "DHT 22 Done"				
				
				bmpTemp = bmp.read_temperature()
				bmpPressure = bmp.read_pressure()
				
				#print readings
				print "Got DHT22: Temperature = "+str(temperature)+" Celsius. Humidity = "+str(humidity)+"%."
				print 'Got BMP180(085): Temperature = '+str(bmpTemp)+' Celsius. Pressure = '+str(bmpPressure)+' pa.'
				
				avgTemp = (temperature+bmpTemp)/2

				sonarMeasurements.append(distance)
				temperatureMeasurements.append(avgTemp)
				humidityMeasurements.append(humidity)
				pressureMeasurements.append(bmpPressure)
			except:
				print "Something happened... Fall back to previous measurement"
				if len(temperatureMeasurements) > 0:
					temperature = temperatureMeasurements[-1]
					humidity = humidityMeasurements[-1]
					pressure = pressureMeasurements[-1]

					sonarMeasurements.append(distance)
					temperatureMeasurements.append(temperature)
					humidityMeasurements.append(humidity)
					pressureMeasurements.append(pressure)
				else:
					print "Uh oh, got nothing to fall back on. Cancel this round."
		
			if len(sonarMeasurements) >= amountToAVG:
				avgSonar = 0
				for _sonar in sonarMeasurements:
					avgSonar = avgSonar + _sonar
				avgSonar = avgSonar/amountToAVG
				sonarMeasurements = []
		
				avgTemperature = 0
				for _temperature in temperatureMeasurements:
					avgTemperature = avgTemperature + _temperature
				avgTemperature = avgTemperature/amountToAVG
				temperatureMeasurements = []
			
				avgHumidity = 0
				for _humidity in humidityMeasurements:
					avgHumidity = avgHumidity + _humidity
				avgHumidity = avgHumidity/amountToAVG
				humidityMeasurements = []
				
				avgPressure = 0
				for _pressure in pressureMeasurements:
					avgPressure = avgPressure + _pressure
				avgPressure = avgPressure/amountToAVG
				pressureMeasurements = []

				print "----------------------------------------------------------------" 
				print "Got Average."

				# Insert Data into the Database Table
				with db:
					insertCode = "INSERT INTO data values (NOW(), "+str(avgSonar)+" ,"+str(avgTemperature)+" ,"+str(avgHumidity)+" ,"+str(avgPressure)+")"
					curs.execute(insertCode)
					print "Average has been inserted into the table."
				print "----------------------------------------------------------------"

		gpio.output(yLEDPin, 0)
		time.sleep(frequency)
		x = x + 1
	gpio.output(rLEDPin, 0)
	#gpio.output(gLEDPin, 1)
	print "================================================================"
	print "Finished Recording Data"
	print "Remember to run gpio.cleanup()!!!"
	#gpio.cleanup()

collectData(loop)
