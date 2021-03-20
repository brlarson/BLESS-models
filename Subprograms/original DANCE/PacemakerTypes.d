--PacemakerTypes.d

--this holds type declarations and constant definitions for
--the PACEMAKER system

face PacemakerTypes
is

import toString toFloating from builtInInteger:Arithmetic
import toString toInteger from builtInFloating:Arithmetic
  
--pulses per minute (always positive)
type ppm is integer

--minutes
type minute is integer

--seconds
type s is floating

--milliseconds (may be negative)
type millisecond is integer

--voltage
type volts is floating
type mv is floating  --millivolts

--percent
type percent is range 0..100

--cardiac cycles
type cc is integer

--acceleration in thousanths of a G (Earth's gravity at sea level)
type milliG is integer

--rate-adaptive pacing activity threshold
type ActivityThreshold is
	(VLow Low MedLow Med MedHigh High VHigh)

--rate-adaptive pacing response factor
type ResponseFactor is range 1..16
	
--3.5.1.	Brady Operating Modes 
--	The following modes shall be programmable: 
--Off, DDD(R), VDD(R), DDI(R), DOO(R), VOO(R), 
--AOO(R), VVI(R), AAI(R), DDD, VDD, DDI, DOO, VOO, 
--AOO, VVI, AAI, VVT and AAT.   
--OVO, OAO, ODO, and OOO
--shall be available in temporary operation.
type BradyMode is (Off DDDR VDDR DDIR DOOR VOOR
	AOOR VVIR AAIR DDD VDD DDI DOO VOO AOO VVI 
	AAI VVT AAT)
type TemporaryMode is (OVO OAO ODO OOO)

--3.5.2.	Brady States
--The following bradycardia states shall be available: 
--Permanent, Temporary, Pace-Now, Magnet, and POR.  
--Operating states shall be mutually exclusive.
type BradyState is (permanent temporary pacenow magnet POR)

--4. Bradycardia Therapy
--Table 3 Programmable Parameters for Brady Therapy

type LowerRateLimitModes is 
	(DDDR VDDR DDIR DOOR VOOR AOOR VVIR AAIR 
	DDD VDD DDI DOO VOO AOO VVI AAI VVT AAT)

type MaximumSensorRateModes is
	(DDDR VDDR DDIR DOOR VOOR AOOR VVIR AAIR)

type FixedAvDelayModes is
	(DDD VDD DDI DOO DDDR VDDR DDIR DOOR)
	
type DynamicAvDelayModes is (VDD DDD VDDR DDDR)

type SensedAvDelayOffsetModes is (DDD DDDR)

--used for both Atrial Amplitude and Atrial Pulse Width
type AtrialPacingModes is
	(DDDR DDIR DOOR AOOR AAIR 
	DDD DDI DOO AOO AAI  AAT)

--used for both Ventricular Amplitude and Ventricular Pulse Width
type VentricularPacingModes is
	(DDDR VDDR DDIR DOOR VOOR VVIR 
	DDD VDD DDI DOO VOO VVI VVT)

type AtrialSensingModes is
	(AAT AAI DDI DDD AAIR DDIR DDDR)

--used for both Ventricular Sensitivity and Refractory
type VentricularSensingModes is
	(VVT VVI VDD DDI DDD VVIR VDDR DDIR DDDR)

type ArpPvarpModes is
	(AAT AAI VDD DDI DDD AAIR VDDR DDIR DDDR)
	
type PvarpExtensionModes is (VDD DDD VDDR DDDR)

type VentricularHysteresisModes is (VVI DDD VVIR DDDR)

type AtrialHysteresisModes is (AAI AAIR)

type RateSmoothingModes is
	(AAI VVI VDD DDD AAIR VVIR VDDR DDDR)

--used for ATR Duration, ATR Fallback Mode, and ATR Fallback Time
type AtrModes is (VDD DDD VDDR DDDR)

--used for Activity Threshold, Reaction Time, Response Factor,
--and Recovery Time	
type RateResponseModes is 
	(DDDR VDDR DDIR DOOR VOOR AOOR VVIR AAIR)
--end of Table 6

--define AXX, VXX and DXX modes
--used for 4.1 Lower Rate Limit
type AxxModes is (AOOR AAIR AOO AAI  AAT)
type VxxModes is (VVT VVI VDD VVIR VDDR VOO VOOR)
type DxxModes is (DDDR DDIR DOOR DDD DDI DOO)

--Table 7 Programmable Parameters
--Lower Rate Limit
-- 30-50 ppm, increment 5
-- 50-90 ppm, increment 1
-- 90-175 ppm, increment 5
type lrlValues is
	(30 35 40 45 50 51 52 53 54 55 56 57 58 59 60
	61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76
	77 78 79 80 81 82 83 84 85 86 87 88 89 90
	95 100 105 110 115 120 125 130 135 140 145 150 
	155 160 165 170 175)
function LRLvalid(rate:ppm) return isValid:boolean
constant LRLnominal:ppm:=60	--LRL nominal is 60 ppm
constant LRLtolerance:s:=0.008	--tolerance +/- 8 ms

--Upper Rate Limit
-- 50-175 ppm, increment 5
type urlValues is
	(55 60 65 70 75 80 85 90 95 100 105 110 115 120 
	125 130 135 140 145 150 155 160 165 170 175)
function URLvalid(rate:ppm) return isValid:boolean
constant URLnominal:ppm:=120	--URL nominal is 120 ppm
constant URLtolerance:s:=0.008	--tolerance +/- 8 ms

--Maximum Sensor Rate
-- 50-175 ppm, increment 5
type msrValues is
	(55 60 65 70 75 80 85 90 95 100 105 110 115 120 
	125 130 135 140 145 150 155 160 165 170 175)
function MSRvalid(rate:ppm) return isValid:boolean
constant MSRnominal:ppm:=120	--MSR nominal is 120 ppm
constant MSRtolerance:s:=0.004	--tolerance +/- 4 ms

--Fixed AV Delay
-- 70-300 ms, increment 10
type favDelay is
	(70 80 90 100 110 120 130 140 150 160 170 180
	190 200 210 220 230 240 250 260 270 280 290 300)
function FAVvalid(delay:s) return isValid:boolean
constant FAVnominal:s:=0.150	--fixed AV delay nominal is 150 ms
constant FAVtolerance:s:=0.008	--tolerance +/- 8 ms

--Dynamic AV Delay
-- Off/On  use boolean, true=On
constant DAVnominal:boolean==false

--Sensed AV Delay Offset
-- Off, =0
-- -10 to -100 ms, increment -10 ms 
type savdo is
	(0 -10 -20 -30 -40 -50 -60 -70 -80 -90 -100)
function SensedAvDelayOffsetValid(delay:s) return isValid:boolean
constant SensedAvDelayOffsetNominal:s:=0.0
constant SensedAvDelayOffsetTolerance:s:=0.001	--tolerance +/- 1 ms

--A or V Pulse Amplitude Regulated
-- Off, = 0.0
-- 0.5 to 3.2V, increment 0.1V
-- 3.5 to 7.0V, increment 0.5V
type pulseAmplitude is
	(`0.0' `0.5' `0.6' `0.7' `0.8' `0.9'
	`1.0' `1.1' `1.2' `1.3' `1.4' `1.5' `1.6' `1.7' `1.8' `1.9'
	`2.0' `2.1' `2.2' `2.3' `2.4' `2.5' `2.6' `2.7' `2.8' `2.9'
	`3.0' `3.1' `3.2' `3.5' `4.0' `4.5' `5.0' `5.5' `6.0' `6.5' `7.0')
function PulseAmplitudeValid(amplitude:volts) return isValid:boolean
constant PulseAmplitudeNominal:volts:=3.5
constant PulseAmplitudeTolerance:percent:=12	--tolerance +/- 12%

--A or V Pulse Amplitude Unregulated
-- Off, = 0.0
-- 1.25, 2.5, 3.75, 5.0
type unregulatedAmplitude is
	(`0.0' `1.25' `2.5' `3.75' `5.0')
function PulseAmplitudeUnregulatedValid(amplitude:volts) return isValid:boolean
constant PulseAmplitudeUnregulatedNominal:volts:=3.75

--A or V Pulse Width
-- 0.05 ms = 50 us
-- 0.1 to 1.9 ms, increment 0.1 ms
type pulseWidth is
	(50 100 200 300 400 500 600 700 800 900 1000
	1100 1200 1300 1400 1500 1600 1700 1800 1900) 
function PulseWidthValid(width:s) return isValid:boolean
constant PulseWidthNominal:s:=0.0004	--0.4 ms
constant PulseWidthTolerance:s:=0.0002	-- +/- 0.2 ms

--A or V Sensitivity
-- 0.25, 0.5, 0.75, mV
-- 1.0 to 10.0 mV, increment 0.5 mV

--holds programmable pacing parameters
type PaceParameter is
	record
		mode:BradyMode
		lrl:ppm			--lower rate limit
		lrl_period:s	--lower rate limit period
		url:ppm 		--upper rate limit
		url_period:s 	--upper rate limit period
		msr:ppm 		--maximum sensor rate
		msr_period:s 	--maximum sensor rate period
		avDelay:s 		--Fixed AV Delay
		useDynamicAvDelay:boolean	--use Dynamic AV Delay
		minAvDelay:s	--Minumum Dynamic AV Delay
		sensedAvDelayOffset:s	--Sensed AV Delay Offset
		aAmplitude:volts	--Atrial Pulse Amplitude Regulated
		vAmplitude:volts	--Ventricular Pulse Amplitude Regulated
		aWidth:s		--Atrial Pulse Width
		vWidth:s		--Ventricular Pulse Width
		aSensitivity:mv	--Atrial Sensitivity
		vSensitivity:mv	--Ventricular Sensitivity
		vrp:s	--Ventricular Refractory
		arp:s	--Atrial Refractory
		pvarp:s		--post-ventricular atrial refractory period
		pvarpExtension:s	--PVARP extension
		hysteresisPacingOn:boolean	--Hysteresis Pacing enabled
		hysteresisLRL:ppm	--hysteresis rate
		hysteresis_period:s	--hysteresis rate as period
		rateSmoothingOn:boolean	--Rate Smoothing is enabled
		rateSmoothingUp:percent	--maximum increase in V pacing rate when tracking
		rateSmoothingDown:percent	--maximum decrease in V pacing rate when tracking
		atrMode:boolean		--ATR Mode
		atrDuration:cc		--ATR Duration
		atrFallback:minute	--ATR Fallback Time
		vBlank:s			--Ventricular Blanking
		activityThreshold:ActivityThreshold	--Accelerometer Activity Threshold
		responseFactor:ResponseFactor	--determines target sensor rate from accelerometer
		reactionTime:s			--determines how fast sensor rate reflects changes in increased activity
		recoveryTime:minute			--determines how fast sensor rate reflects changes in decreased activity
	end record


-- 3.4.2.3.2.	The Pace-Now Pace parameter values are as follows:
-- 1.	The mode Pace-Now pace parameter shall have a value of VVI.
-- 2.	The lower rate limit Pace-Now pace parameter shall have a value of 65 ppm + 8 ms.
-- 3.	The amplitude Pace-Now pace parameter shall have a value of 5.0 +  0.5 V.
-- 4.	The pulse width Pace-Now pace parameter shall have a value of 1.00 ms +  0.02 ms.
-- 5.	The ventricular refractory Pace-Now pace parameter shall have a value of 320 ms + 8 ms.
-- 6.	The ventricular sensitivity shall have a value of 1.5 mV.
constant paceNowParameters:PaceParameter:=
	(mode=>`VVI' lrl=>65 amplitude=>5.0 width=>0.001 refractory=>0.320 vSensitivity=>1.5)
	

--3.4.2.5.4.	 The POR parameter values are as follows:
--1.	The mode POR pace parameter shall have a value of VVI.
--2.	The lower rate limit POR pace parameter shall have a value of 65 ppm + 8 ms.
--3.	The amplitude POR pace parameter shall have a value of 5.0 +  0.5 V.
--4.	The pulse width POR pace parameter shall have a value of 0.5 ms +  0.02 ms.
--5.	The ventricular refractory POR pace parameter shall have a value of 320 ms + 8 ms.
--6.	The ventricular sensitivity shall have a value of 1.5 mV.
constant porParameters:PaceParameter:=
	(mode=>`VVI' lrl=>65 amplitude=>5.0 width=>0.0005 refractory=>0.320 vSensitivity=>1.5)

--Nominal Parameters
-- from TABLE 7 Programmable Parameters	
--PARAMETER					NOMINAL
--Mode						DDD
--Lower Rate Limit			60 ppm
--Upper Rate Limit			120 ppm
--Maximum Sensor Rate		120 ppm
--Fixed AV Delay			150 ms
--Dynamic AV Delay			Off
--Minumum Dynamic AV Delay	50 ms
--Sensed AV Delay Offset	Off
--A or V Pulse Amplitude 
--  Regulated				3.5V
--A or V Pulse Width		0.4 ms
--V Sensitivity				2.5mV
--A Sensitivity				0.75mV
--Ventricular Refractory	320 ms
--Atrial Refractory			250 ms
--PVARP						250 ms
--PVARP Extension			0 ms
--Hysteresis (SSI only)		false
--rate smoothing			0%
--ATR mode					false
--ATR duration				20 cardiac cycles
--ATR Fallback Time			1 minute
--Ventricular Blanking		40 ms
--Activity Threshold		Medium
--Reaction Time				30 sec
constant nominalParameters:PaceParameter:=
	(mode=>DDD lrl=>60 url=>120 msr=>120 avDelay=>0.150 
	useDynamicAvDelay=>false minAvDelay=>0.050
	sensedAvDelayOffset=>0.0 aAmplitude=>3.5  vAmplitude=>3.5 aWidth=>0.0004  
	vWidth=>0.0004 aSensitivity=>0.75 vSensitivity=>2.5 vrp=>0.320
	arp=>0.250 pvarp=>0.250 pvarpExtensiton=>false hysteresis=>false
	rateSmoothing=>0 atrMode=>false atrDuration=>20 atrFallback=>1
	vBlanking=>0.040 activityThreshold=>Med rt=>30.0)

--3.4.2.3.2.	The Pace-Now Pace parameter values are as follows:
--1.	The mode Pace-Now pace parameter shall have a value of VVI.
--2.	The lower rate limit Pace-Now pace parameter shall have a value of 65 ppm + 8 ms.
--3.	The amplitude Pace-Now pace parameter shall have a value of 5.0 +  0.5 V.
--4.	The pulse width Pace-Now pace parameter shall have a value of 1.00 ms +  0.02 ms.
--5.	The ventricular refractory Pace-Now pace parameter shall have a value of 320 ms + 8 ms.
--6.	The ventricular sensitivity shall have a value of 1.5 mV.
constant pacenowParameters:PaceParameter:=
	(mode=>VVI lrl=>65 url=>120 msr=>120 avDelay=>0.150 
	useDynamicAvDelay=>false minAvDelay=>0.050
	sensedAvDelayOffset=>0.0 aAmplitude=>3.5  vAmplitude=>5.0 aWidth=>1.000  
	vWidth=>1.000 aSensitivity=>0.75 vSensitivity=>1.5 vrp=>0.320
	arp=>0.250 pvarp=>0.250 pvarpExtensiton=>false hysteresis=>false
	rateSmoothing=>0 atrMode=>false atrDuration=>20 atrFallback=>1
	vBlanking=>0.040 activityThreshold=>Med rt=>30.0)

--3.4.2.5.4.	 The POR parameter values are as follows:
--1.	The mode POR pace parameter shall have a value of VVI.
--2.	The lower rate limit POR pace parameter shall have a value of 65 ppm + 8 ms.
--3.	The amplitude POR pace parameter shall have a value of 5.0 +  0.5 V.
--4.	The pulse width POR pace parameter shall have a value of 0.5 ms +  0.02 ms.
--5.	The ventricular refractory POR pace parameter shall have a value of 320 ms + 8 ms.
--6.	The ventricular sensitivity shall have a value of 1.5 mV.
constant porParameters:PaceParameter:=
	(mode=>VVI lrl=>65 url=>120 msr=>120 avDelay=>0.150 
	useDynamicAvDelay=>false minAvDelay=>0.050
	sensedAvDelayOffset=>0.0 aAmplitude=>3.5  vAmplitude=>5.0 aWidth=>0.500  
	vWidth=>0.500 aSensitivity=>0.75 vSensitivity=>1.5 vrp=>0.320
	arp=>0.250 pvarp=>0.250 pvarpExtensiton=>false hysteresis=>false
	rateSmoothing=>0 atrMode=>false atrDuration=>20 atrFallback=>1
	vBlanking=>0.040 activityThreshold=>Med rt=>30.0)

--magnet parameters must be computed when magnet is applied according to 3.6.2
constant magnetParameters:PaceParameter:=nominalParameters

--used by rate adaptive pacing to determine sensor rate
constant secretScalingNumber:floating:=5.0	

type AE is	--atrial event
	record
		t:s	--time of occurance
		as:boolean	--is sense
		ap:boolean  --is pace
		ns:boolean	--noise on atrial channel
	end record

type VE is  --ventricular event
	record
		t:s	--time of occurance
		vs:boolean	--is ventricular sense
		vp:boolean  --is ventricular pace
		ns:boolean	--noise on ventricular channel		
	end record

function ppmToS(rate:ppm) return duration:s
	{duration=60.0/toFloating(rate)}

function sToPpm(duration:s) return rate:ppm
	{rate=toInteger(60.0/duration)}

function sToMilliseconds(duration:s) return rate:millisecond
	{rate=toInteger(1000.0*duration)}

function percentToFloat(p:percent) return f:floating
	{f=toFloating(p)/100.0}

function minutesToS(t:minute) return m:s
	{m=toFloating(t)*60.0}

type AtrialMarkerKinds is 
	(
	mkrAS	--Atrial sensed
	mkrAP	--Atrial paced
	mkrAT	--A-Tachy Sense	
	mkrATN	--Noise Indication, atrial channel				
	mkrASref	--Atrial sense	in refractory
	)	--end of AtrialMarkerKinds

type AtrialMarker is
	record
		kind:AtrialMarkerKinds
		t:s
	end record

type VentricularMarkerKinds is 
	(
	mkrVS	--Ventricular sensed	
	mkrVP	--Ventricular paced
	mkrHy	--pace at Hysteresis Rate
	mkrPVC	--Premature Vent. Contraction
	mkrSr	--pace at Sensor Rate
	mkrUp	--Rate smoothing up
	mkrDn	--Rate smoothing down
	mkrVTN	--Noise Indication, ventricular channel				
	mkrVSref	--Ventricular sense in refractory		
	mkrPVCref	--PVC in refractory	
	)  --end of VentricularMarkerKinds

type VentricularMarker is
	record
		kind:VentricularMarkerKinds
		t:s
	end record

type AugmentationMarkerKinds is
	(
	mkrATRFB	--Fallback Started	
	mkrATRDur	--Onset Started
	mkrATREnd	--Fallback Ended
	mkrPVP	--PVARP Extension
	)  --end of AugmentationMarkerKinds

type AugmentationMarker is
	record
		kind:AugmentationMarkerKinds
		t:s
	end record

	--define "new" operator, x was false and is now true
	{ new:x: x and not x^-1 }	

end face  --of PacemakerTypes


------------------------------------------------------------------------------------------------------------

body pacemakerTypes:PacemakerTypes
is

import toString from Arithmetic

function sToMilliseconds(duration:s) return rate:millisecond
	{rate=toInteger(1000.0*duration)}
	is
	begin
		rate:=toInteger(1000.0*duration)
	end


function LRLvalid(rate:ppm) return isValid:boolean
	is
	begin
		isValid == rate in lrlValues
	end

function URLvalid(rate:ppm) return isValid:boolean
	is
	begin
		isValid == rate in urlValues
	end

function MSRvalid(rate:ppm) return isValid:boolean
	is
	begin
		isValid == rate in msrValues
	end

function FAVvalid(delay:s) return isValid:boolean
	is
	begin
		isValid == sToMilliseconds(delay) in favDelay
	end

function SensedAvDelayOffsetValid(delay:s) return isValid:boolean
	is
	begin
		isValid == sToMilliseconds(delay) in savdo
	end

function PulseAmplitudeValid(amplitude:volts) return isValid:boolean
	is
	begin
		isValid == toString(amplitude) in pulseAmplitude
	end

function PulseAmplitudeUnregulatedValid(amplitude:volts) return isValid:boolean
	is
	begin
		isValid == toString(amplitude) in unregulatedAmplitude
	end

function PulseWidthValid(width:s) return isValid:boolean
	is
	begin
		isValid == sToMilliseconds(width) in pulseWidth
	end

function ppmToS(rate:ppm) return duration:s
	{duration=60.0/toFloating(rate)}
	is
	begin
		duration:=60.0/toFloating(rate) 
	end

function sToPpm(duration:s) return rate:ppm
	{rate=toInteger(60.0/duration)}
	is
	begin 
		rate:=toInteger(60.0/duration)
	end

function percentToFloat(p:percent) return f:floating
	{f=toFloating(p)/100.0}
	is
	begin 
		f:=toFloating(p)/100.0
	end


function minutesToS(t:minute) return m:s
	{m=toFloating(t*60)}
	is
	begin 
		m:=toFloating(t*60)
	end


end body	--of PacemakerTypes

