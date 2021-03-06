@ZWave
Feature: ZWave Utilitech Water Leak Detector Driver Test

	These scenarios test the functionality of the ZWave Utilitech Water Leak Detector driver.

	Background:
		Given the ZW_Utilitech_Leak_Detector.driver has been initialized
			And the driver variable lastBatteryRptTime is 0
				
	Scenario: Driver reports capabilities to platform. 
		When a base:GetAttributes command is placed on the platform bus
		Then the driver should place a base:GetAttributesResponse message on the platform bus
			And the message's base:caps attribute list should be ['base', 'dev', 'devadv', 'devpow', 'devconn', 'leakh2o']
			And the message's dev:devtypehint attribute should be Water Leak
			And the message's devadv:drivername attribute should be ZWaveUtilitechLeakDetectorDriver 
			And the message's devadv:driverversion attribute should be 1.0
			And the message's devpow:source attribute should be BATTERY
			And the message's devpow:linecapable attribute should be false		
		Then both busses should be empty
	
	Scenario: Device connected
		When the device connects to the platform
		Then the driver should place a base:ValueChange message on the platform bus 
	
	Scenario Outline: Device reports alarm state 
		When the device response with sensor_alarm report
			And with parameter sensortype 5
			And with parameter sensorstate <sensorstate>
			And send to driver
		Then the platform attribute leakh2o:state should change to <status>	
			And the driver should place a base:ValueChange message on the platform bus
			
		Examples:
		  | sensorstate  | status |
		  | 0            | SAFE   |
		  | 1            | SAFE   |
		  | 2            | SAFE   |
		  | 4            | SAFE   |
		  | 8            | SAFE   |
		  | 16           | SAFE   |
		  | 32           | SAFE   |
		  | 64           | SAFE   |
		  | -128         | SAFE   |
		  | -1           | LEAK   |

	Scenario: Platform turns the alarm off via attribute change. 
		When a base:SetAttributes command with the value of leakh2o:state SAFE is placed on the platform bus
		Then the driver should send basic set 
			And with parameter value 0

	Scenario: Device reports alarm Low Battery
		When the device response with alarm report 
			And with parameter alarmtype 1
			And send to driver
		Then the platform attribute devpow:battery should change to 0
			And the driver should place a base:ValueChange message on the platform bus
		Then both busses should be empty

	Scenario Outline: Device reports battery level
		When the device response with battery report 
			And with parameter level <level-arg>
			And send to driver 
		Then the platform attribute devpow:battery should change to <battery-attr>
			And the driver should place a base:ValueChange message on the platform bus
		Then both busses should be empty

		Examples:
		  | level-arg | battery-attr |
		  | -1        | 0            |
		  | 1         | 1            |
		  | 100       | 100          |
