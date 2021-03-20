--Pacemaker.d

--this file is the main behavior of PACEMAKER

module Pacemaker is
	clock CLK
	import  --types 
		ppm minute s millisecond mv percent cc milliG
		ActivityThreshold BradyMode TemporaryMode  PaceParameter
		BradyState LowerRateLimitModes MaximumSensorRateModes 
		FixedAvDelayModes DynamicAvDelayModes SensedAvDelayOffsetModes 
		AtrialPacingModes VentricularPacingModes 
		AtrialSensingModes VentricularSensingModes
		VentricularHysteresisModes AtrialHysteresisModes 
		RateSmoothingModes
		AxxModes VxxModes DxxModes 
		nominalParameters pacenowParameters porParameters magnetParameters
		ppmToS sToPpm percentToFloat sToMilliseconds minutesToS
		AE VE secretScalingNumber
		AtrialMarker AtrialMarkerKinds
		VentricularMarker VentricularMarkerKinds
		AugmentationMarker AugmentationMarkerKinds
		MSRtolerance  --used because it's the smaller than LRLtolerance or URLtolerance, wierd 
		{ new }
	from pacemakerTypes:PacemakerTypes
	
	import now from System
	
--	import toFloating toInteger min max from Arithmetic
	import toString toFloating min max from builtInInteger:Arithmetic
	import toString toInteger min max from builtInFloating:Arithmetic
 	
	--define "new" operator, x was false and is now true
--	{ new:x: x and not x^-1 }	

--------------------------Input Ports-------------------------------------------	
	--pp holds currently-used pacing parameters
	port pp is clocked in PaceParameter
	
	port accelerometer is clocked in milliG

	--ae indicates atrial events
	port ae is immediate in AE	

	--ve indicates atrial events
	port ve is immediate in VE	

--------------------------Output Ports-------------------------------------------	
	--aPace tells hardware to pace atriun
	port aPace is immediate out signal
		{APace:: all t:s are 
			aPace@t => exists t2:s in t..t+MSRtolerance that 
				ae.ap@t2}	--the next atrial event will be a pace

	--vPace tells hardware to pace ventricle
	port vPace is immediate out signal
		{VPace:: all t:s are 
			vPace@t => exists t2:s in t..t+MSRtolerance that 
				ve.vp@t2}	--the next ventricular event will be a pace

	--ports for markers
	port atrialMarker is immediate out AtrialMarker

	port ventricularMarker is immediate out VentricularMarker

	port augmentationMarker is immediate out AugmentationMarker

--------------------Refractories------------------------------------------

--Ventricular Refractory Period (VRP)
		--5.4.1.	Ventricular Paced Refractory Period (VRP)
		--  The Ventricular Refractory Period shall be the programmed 
		--  time interval following a ventricular paced event during 
		--  which time ventricular events shall not inhibit nor trigger pacing.
	{inVRP:theTime: 
		exists t:s in t<theTime and (ve.vs or ve.vp)@t --there is some previous time with a V event
			that t+pp.vrp>=theTime  }  --that happened within vrp of theTime
			
--Atrial Refractory Period (ARP)
		--5.4.2.	Atrial Refractory Period (ARP)
		--  For single chamber atrial modes, the Atrial Refractory Period (ARP) 
		--  shall be the programmed time interval following an atrial event.  
		--  Atrial events shall not inhibit nor trigger pacing during this time period.
	{inARP:theTime:  pp.mode in AxxModes and  --single-chamber atrial mode
		(exists t:s in t<theTime and (ae.as or ae.ap)@t --there is some previous time with A event
			that t+pp.arp>=theTime)  }  --that happened within arp of theTime
	
--Post Ventricular Atrial Refractory Period (PVARP)
		--5.4.3.	Post Ventricular Atrial Refractory Period (PVARP)
		-- The Post Ventricular Atrial Refractory Period shall be available 
		--  in modes with ventricular pacing and atrial sensing. 
		-- The Post Ventricular Atrial Refractory Period shall be the programmable 
		--  time interval following a ventricular event when an atrial cardiac 
		--  event shall not 
		--  1.	Inhibit an atrial pace.
		--  2.	Trigger a ventricular pace.  
	{inPVARP:theTime: 
		exists t:s in t<theTime and (ve.vs or ve.vp)@t --there is some previous time with a V event
			that t+pp.pvarp>=theTime }  --that happened within pvarp of theTime

--Premature Ventricular Contraction (PVC)
		--5.4.4.	Premature Ventricular Contraction (PVC)
		-- A ventricular sense is deemed to be a premature ventricular 
		--  contraction if there has been no atrial event since the previous 
		--  ventricular event.
	{PVC:ve: --is ve a PVC?
		ve.vs and	--event must be a sense to be PVC
		(exists t:s in t<ve.t and (ve.vs or ve.vp)@t --there is some previous time with a V event
			that not (exists t2:s in t<t2 and t2<ve.t	--there is no a event between ve's
				that (ae.as or ae.ap)@t2) )	
	}  --end of PVC
		
--Extended PVARP
		--5.4.5.	Extended PVARP
		--  The Extended PVARP works as follows:
		--  1.	When Extended PVARP is enabled, an occurrence of a sensed 
		--    PVC shall cause the pulse generator to increase the  PVARP by 
		--    a programmable value.  
		--  2.	The PVARP shall always return to its normal programmed value 
		--    on the subsequent cardiac cycle regardless of PVC and other events.  
		--  3.	The maximum frequency of PVARP extensions shall be one of every 
		--    two cardiac cycles.
	{inExtendedPVARP:theTime:  
		pp.pvarpExtension@theTime > 0.0	--there is PVARP extension enabled
		and	--there was a PVC before theTime
		(exists t:s in t<theTime and PVC(ve@t)
			that --occurred at most pvarp+extendedPvarp before theTime
			t+pp.pvarpExtension@theTime>=theTime 
			and	--there was a recent vs or vp not in refractory or PVC
			(exists t2:s in t2<t and t2>t-pp.pvarp@theTime
--expect complaints here about recursive predicate operator!
				that not inExtendedPVARP(t2)	--not in extended PVARP
					and not PVC(ve@t2)  	--and not a PVC 
			)
		) 
	}	--end of inExtendedPVARP

--Refractory During AV
		--5.4.6.	Refractory During the AV Interval
		-- The PG shall also be in refractory to atrial senses during the 
		--  AV interval.  In this context, refractory means the pacemaker 
		--  does not track or inhibit based on the sensed activity.
	{inAV:theTime: 
		exists t:s in t<theTime and 
				ae.ap@t --there is some previous time with A pace
			that t+pp.avDelay>=theTime  }  --that happened within the AV delay
	
--In Any Atrial Refractory
	{inArefractory:theTime: inExtendedPVARP(theTime) or 
		inPVARP(theTime) or inARP(theTime) or inAV(theTime) }

--------------------------Upper and Lower Rate Limits--------------------------

--The Time Between Non-Refractory Events Does Not Exceed
--used by LRL, rate smoothing and rate adaptive
--makes an affirmative statement that pacing will occur
	{TheTimeBetweenNonRefractoryEventsDoesNotExceed:
		theTime	--the applicable time, usually now
		rl	--the applicable rate limit in ppm, usually LRL, sometimes sensor rate
		:
		(pp.mode@theTime in VentricularPacingModes
			=> --the time between the previous two ventricular events did not exceed rl
			exists t:s in t<theTime and (ve.vs or ve.vp)@t	--last ventricular event @t
					and 1=(numberof tn:s in t..theTime that 
						are (ve.vs or ve.vp)@tn)  
				that
			exists t2:s in t2<t and	(ve.vs or ve.vp)@t2	--the event before that @t2
					 and 2=(numberof tn:s in t2..theTime that 
					 	are (ve.vs or ve.vp)@tn)  
				that
				(t-t2 <= ppmToS(rl) 
				and not inVrefractory(t)
				and not inVrefractory(t2))
		)
		and	--atrium-only modes
		(pp.mode@theTime in AxxModes
			=> --the time between the previous two atrial events did not exceed rl
			exists t:s in t<theTime and (ae.as or ae.ap)@t   --last atrial event @t
					and 1=(numberof tn:s in t..theTime that are 
						(ae.as or ae.ap)@tn)  
				that
			exists t2:s in t2<t and	(ae.as or ae.ap)@t2   --the event before that
					and 2=(numberof tn:s in t2..theTime that are 
						(ae.as or ae.ap)@tn)  
				that
				(t-t2 <= ppmToS(rl) 
				and not inArefractory(t)
				and not inArefractory(t2))
		)
	}  --end of TheTimeBetweenNonRefractoryEventsDoesNotExceed

--lower rate limit (LRL)
		--5.1.	Lower Rate Limit (LRL)
		--  The Lower Rate Limit is the number of generator pace pulses 
		--  delivered per minute (atrium or ventricle) in the absence of
		--		Sensed intrinsic activity.
		--		Sensor-controlled pacing at a higher rate.
		--5.1.1.	When Rate Hysteresis is disabled, the LRL shall define 
		--  the longest allowable pacing interval.			
	{LRL:theTime:	--pacing at LRL at theTime
		not pp.hysteresisPacingOn@theTime =>	--no hysteresis pacing
		TheTimeBetweenNonRefractoryEventsDoesNotExceed(theTime,pp.lrl@theTime) }

--upper rate limit (URL)
		--5.2.	Upper Rate Limit (URL) The Upper Rate Limit is the maximum 
		--  rate at which the paced ventricular rate will track sensed atrial events.  
		--  The URL interval is the minimum time between a ventricular 
		--  event and the next ventricular pace.
	{URL:: --between any two v events, second of which is v pace
		(all t,t2:s in t<t2 and ve.vp@t2
				and (ve.vp or ve.vs)@t
			are
			t2-t >= pp.url_period@t) }	--will be at least url_period apart
	
-------------------------------AV Delay--------------------------------------
--Paced AV Delay (PAV)
 		--5.3.1.	Paced AV Delay
		-- A paced AV (PAV) delay shall occur when the AV delay is 
		--  triggered by an atrial pace. 		
	{PAV::  --paced AV Delay 
		all t:s in ae.ap@t 	--following atrial pace
			are
			((exists t2:s in t2>t and ve.vs@t2 that --there is a later ventricular sense
					t2-t<pp.avDelay@t )	--within AV Delay
			or vPace@(t+pp.avDelay@t)) }	--or a pace at t+avDelay
	
		--5.3.2.	Sensed AV Delay
		-- A sensed AV (SAV) delay shall occur when the AV delay is 
		--  triggered by an atrial sense.  
		--5.3.4.	Sensed AV Delay Offset 
		--  The Sensed AV Delay Offset option shall shorten the AV delay 
		--  following a tracked atrial sense. 
		--  Depending on which option is functioning, the SAV offset shall 
		--  be applied to the following: 
		--  1.	The fixed AV delay
	{SAV::  --sensed AV delay 
		all t:s in ae.as@t 	--following atrial sense
			are
			((exists t2:s in t2>t and ve.vs@t2 that --there is a later ventricular sense
					t2-t<pp.avDelay@t+pp.sensedAvDelayOffset@t )	--within Sensed AV Delay
			or vPace@(t+pp.avDelay@t+pp.sensedAvDelayOffset@t)) }	--or a pace at t+Sensed AV Delay

		--5.3.	AV Delay
		-- The AV delay shall be the programmable time period from 
		--  an atrial event (either intrinsic or paced) to a ventricular pace.  
		-- In atrial tracking modes, ventricular pacing shall occur 
		--  in the absence of a sensed ventricular event within the 
		--  programmed AV delay when the sensed atrial rate is between 
		--  the programmed LRL and URL.
		--	AV delay shall either be
		--  1. Fixed (absolute time)
--Fixed AV Delay (FixedAV)
 	{FixedAVdelay:: 
		all t:s in not (pp.useDynamicAvDelay@t and pp.mode@t in DynamicAvDelayModes) 
			are (PAV and SAV) }

--Previous Cardiac Cycle Length (PCCL)
		--3.4.3.	Rate Sensing and Rates
		--  Rate sensing shall be accomplished using bipolar electrodes 
		--  and sensing circuits.  All rate detection decisions shall be 
		--  based on the measured cardiac cycle lengths of the sensed 
		--  rhythm. Rate shall be evaluated on an interval-by-interval basis.	
	{PCCL: 
		theTime	--about when are you asking
		pccl	--in s, the difference in time between the last two events
		: --the time between the previous two ventricular events was pccl
		exists t:s in t<theTime and 	--last ventricular event @t
				1=(numberof tn:s in t..theTime that are 
					(ve.vp or ve.vs)@tn)  
			that
		exists t2:s in t2<t and		--the event before that @t2
				 2=(numberof tn:s in t2..theTime that are 
				 	(ve.vp or ve.vs)@tn)  
			that
			(t-t2 = pccl --pccl is the difference between last non-refractory v events
			and not inVrefractory(t)
			and not inVrefractory(t2))
	}  --end of PCCL
		
--Dynamic AV Delay (DynamicAV)
		--5.3.3.	Dynamic AV Delay
		--  If dynamic, the AV delay shall be determined dynamically 
		--  for each new cardiac cycle based on the duration of previous 
		--  cardiac cycles.   The previous cardiac cycle length is multiplied 
		--  by a factor stored in device memory to create the dynamic AV delay.
		--  The  AV delay shall vary between 
		--  1.	The Fixed AV delay 
		--  2.	The Minumum Dynamic AV delay 
	{DynamicPAV:  --Dynamic paced AV Delay 
		av:  --the dynamic AV delay
		all t:s in ae.ap@t 	--following atrial pace
			are
			((exists t2:s in t2>t and ve.vs@t2 that --there is a later ventricular sense
					t2-t<av )	--within dynamic AV Delay
			or vPace@(t+av)) }	--or a pace at t+dynamic avDelay

		--5.3.4.	Sensed AV Delay Offset 
		--  The Sensed AV Delay Offset option shall shorten the AV delay 
		--  following a tracked atrial sense. 
		--  Depending on which option is functioning, the SAV offset shall 
		--  be applied to the following: 
		--  2.	The dynamic AV delay
	{DynamicSAV:  --Dynamic sensed AV delay 
		av:  --the dynamic AV delay
		all t:s in ae.as@t and not inArefractory(t) 	--following non-refractory atrial sense
			are
			((exists t2:s in t2>t and ve.vs@t2 that --there is a later ventricular sense
					t2-t<av+pp.sensedAvDelayOffset@t )	--within dynamic AV Delay with offset
			or vPace@(t+av+pp.sensedAvDelayOffset@t))	--or a pace at t+dynamic avDelay with offset
	}  --end of DynamicSAV
	
 	{DynamicAV:  --dynamic AV Delay as a whole
 		theTime	--dynamic AV delay cannot be stated universally
 		: 		--so it can only refer to the most recent events before theTime
 		(pp.useDynamicAvDelay and pp.mode in DynamicAvDelayModes) 
		=> 
		(exists cci:s 	--last cardiac cycle interval
			in PCCL(theTime,cci)	--cci is the previous cardiac cycle length
			that
			(exists dav:s  --dynamic AV delay varies from pp.avDelay when cci=lrl_period
					--to pp.minAvDelay when cci=url_period
				in dav=cci*
					(((pp.lrl_period*pp.minAvDelay)+(pp.url_period*pp.avDelay))
					/(pp.lrl_period*pp.url_period))
				that
				DynamicPAV(theTime,dav) and DynamicSAV(theTime,dav)
			)  --end of exists dav
		)  --end of exists cci
	}  --end of DynamicAV
	
--AV Delay (AV)
	{AVdelay:theTime:
	FixedAV(theTime) and DynamicAV(theTime)}	

------------------------Rate Smoothing------------------------------------------
--rate smoothing down
	{RateSmoothingDown:theTime:
		(pp.rateSmoothingOn and pp.mode in RateSmoothingModes) =>
		(exists cci:s in PCCL(theTime,cci)	--cci is last cardiac cycle interval
			that
			TheTimeBetweenNonRefractoryEventsDoesNotExceed(theTime,
				sToPpm(cci*(1.0+percentToFloat(pp.rateSmoothingDown))) )
		) 
	}  --end of RateSmoothingDown

--The Time Between Non-refractory Events and Subsequent Paces Is At Least
--used by rate smoothing up
	{TheTimeBetweenNonRefractoryEventsAndSubsequentPacesIsAtLeast:
		theTime	--the applicable time, usually now
		rl	--the applicable rate limit, usually URL, sometimes rate smoothing up
		:	
		exists t:s in t<theTime and 
				ve.vp@t and	--last ventricular pace @t
				1=(numberof tn:s in t..theTime that are 
					(ve.vp or ve.vs)@tn)  
			that
		exists t2:s in t2<t and		--the event before that @t2
				not inVrefractory(t2) and  --non-refractory
				2=(numberof tn:s in t2..theTime that are 
					(ve.vp or ve.vs)@tn)  
			that
			t-t2 >= ppmToS(rl) --time between events if bigger than rate limit period
	}  --end of TheTimeBetweenNonRefractoryEventsAndSubsequentPacesIsAtLeast

--The Time Between Non-refractory Events and Subsequent Paces Is Exactly
--used to generate rate smoothing up marker
	{TheTimeBetweenNonRefractoryEventsAndSubsequentPacesIsExactly:
		theTime	--the applicable time, usually now
		rl	--the applicable rate limit, rate smoothing up
		:	
		exists t:s in t<theTime and 
				ve.vp@t and	--last ventricular pace @t
				1=(numberof tn:s in t..theTime that are 
					(ve.vp or ve.vs)@tn)  
			that
		exists t2:s in t2<t and		--the event before that @t2
				not inVrefractory(t2) and  --non-refractory
				2=(numberof tn:s in t2..theTime that are 
					(ve.vp or ve.vs)@tn)  
			that
			t-t2 = ppmToS(rl) --time between events if bigger than rate limit period
	}  --end of TheTimeBetweenNonRefractoryEventsAndSubsequentPacesIsExactly

--rate smoothing up
	{RateSmoothingUp:theTime:
		(pp.rateSmoothingOn and pp.mode in RateSmoothingModes) =>
		(exists cci:s in PCCL(theTime,cci)	--cci is last cardiac cycle interval
			that
			TheTimeBetweenNonRefractoryEventsAndSubsequentPacesIsAtLeast(theTime,
				toInteger(cci*(1.0-percentToFloat(pp.rateSmoothingUp))) )
		) 
	}  --end of RateSmoothingUp


------------------------------Hysteresis Pacing---------------------------------------

--5.8 Hysteresis Pacing
--  When enabled, hysteresis pacing shall result in a longer period following a sensed
--  event before pacing. This encourages self-pacing during exercise by waiting a
--  little longer to pace after senses, hoping that another sense will inhibit the pace.
--  To use hysteresis pacing:
--  1. Hysteresis pacing must be enabled (not Off).
--  2. The pacing mode must be inhibiting or tracking.
--  3. The current pacing rate must be faster than the Hysteresis Rate Limit
--    (HRL), which may be slower than the Lower Rate Limit (LRL).
--  4. When in AAI mode, a single, non-refractory sensed atrial event shall ac-
--    tivate hysteresis pacing.
--  5. When in an inhibiting or tracking mode with ventricular pacing, a single,
--    non-refractory sensed ventricular event shall activate hysteresis pacing.
	{HysteresisPacing:theTime	--hysteresis pacing at theTime
		sr:  --sensor rate or lrl
		((pp.hysteresisPacingOn@theTime and pp.mode@theTime in VentricularHysteresisModes) =>
			exists t:s in t<theTime and 	--last ventricular event @t
					1=(numberof tn:s in t..theTime that are 
						(ve.vp or ve.vs)@tn)  
				that
			exists t2:s in t2<t and		--the event before that @t2
					 2=(numberof tn:s in t2..theTime that are 
					 	(ve.vp or ve.vs)@tn)  
				that  --after sense use hysteresis rate
				((ve.vs@t2 and t-t2 <= max(ppmToS(sr),pp.hysteresis_period))  
				  or	--after pace use LRL or sensor rate
				  (ve.vp@t2 
				  and t-t2 <= ppmToS(sr)
				  and not inVrefractory(t)
				  and not inVrefractory(t2)
				  )
				)
		)
		and	--atrium inhibit modes
		((pp.hysteresisPacingOn@theTime and pp.mode@theTime in AtrialHysteresisModes)
			=> --the time between the previous two atrial events did not exceed rl
			exists t:s in t<theTime and    --last atrial event @t
					1=(numberof tn:s in t..theTime that are 
						(ae.as or ae.ap)@tn)  
				that
			exists t2:s in t2<t and	   --the event before that
					2=(numberof tn:s in t2..theTime that are 
						(ae.as or ae.ap)@tn)  
				that  --after sense use hysteresis rate
				((ae.as@t2 and t-t2 <= max(ppmToS(sr),pp.hysteresis_period)) 
				  or	--after pace use LRL or sensor rate
				  (ae.ap@t2 
				  and t-t2 <= ppmToS(sr)
				  and not inArefractory(t)
				  and not inArefractory(t2)
				  )
				)
		)
		and
		(not pp.hysteresisPacingOn@theTime
			=>  --not hysteresis pacing
			TheTimeBetweenNonRefractoryEventsDoesNotExceed(theTime,sr)
		)
	}  --end of HysteresisPacing


------------------------------Rate Adaptive Pacing------------------------------------------

--5.7.1 Maximum Sensor Rate (MSR)
--  The Maximum Sensor Rate is the maximum pacing rate allowed as a result of
--  sensor control. The Maximum Sensor Rate shall be
--  1. Required for rate adaptive modes
--  2. Independently programmable from the URL
	{MaximumSensorRate:
		sr:	--current sensor rate
		all t:s are
			pp.lrl@t<=sr and sr<=pp.msr@t }

--5.7.2 Activity Threshold
--  The activity threshold is the value the accelerometer sensor output shall exceed
--  before the pacemaker's rate is a®ected by activity data.
	{ActivityThreshold:
		a	--accelerometer in milliG
		at	--activity thresholds, array over labels V-Low etc.
		sr:	--current sensor rate
		a<=at[pp.activityThreshold] => sr=pp.lrl }

--5.7.3  Factor
--  The accelerometer shall determine the pacing rate that occurs at various levels
--  of steady state patient activity.
--  Based on equivalent patient activity:
--  1. The highest response factor setting (16) shall allow the greatest incremen-
--  tal change in rate.
--  2. The lowest response factor setting (1) shall allow a smaller change in rate.
	{Factor:
		a	--accelerometer in milliG
		targetHeartRate	--heart rate reached if this acceleration continues
		at	--activity thresholds, array over labels V-Low etc.
		sr:	--current sensor rate
		targetHeartRate = min(pp.msr, max(pp.lrl,
			(a-at[pp.activityThreshold])*pp.responseFactor*secretScalingNumber))
	}  --end of Factor

--5.7.4 Reaction Time
--  The accelerometer shall determine the rate of increase of the pacing rate. The
--  reaction time is the time required for an activity to drive the rate from LRL to
--  MSR.
	{ReactionTime::
		exists n:integer in 1..200 that	--n is number of beats from LRL to MSR
			pp.reactionTime =
			(sum j:integer in 0..n of
				pp.lrl_period + ((toFloating(j)*(pp.msr_period-pp.lrl_period))
					 / toFloating(n)) ) 
	}  --end of ReactionTime



--5.7.5 Recovery Time
--  The accelerometer shall determine the rate of decrease of the pacing rate. The
--  recovery time shall be the time required for the rate to fall from MSR to LRL
--  when activity falls below the activity threshold.
	{RecoveryTime::
		exists m:integer in 1..1200 that	--m is number of beats from MSR to LRL
			minutesToS(pp.recoveryTime) =
			(sum k:integer in 0..m of
				pp.msr_period + ((toFloating(k)*(pp.lrl_period-pp.msr_period))
					 / toFloating(m)) ) 
	}  --end of RecoveryTime

--5.7 Rate-Adaptive Pacing
--  The device shall have the ability to adjust the cardiac cycle in response to
--  metabolic need as measured from body motion using an accelerometer.
	{RateAdaptivePacing:
		t		--the time
		mode	--pacing mode (may be VVIR for ATR fallback or pp.mode)
		lrl		--lower rate limit (may be fallback rate for ATR)
		a:	--accelerometer in milliG
		exists sr:ppm in lrl..pp.msr that	--sensor rate between LRL and MSR
		exists at:array ActivityThreshold.VLow..ActivityThreshold.VHigh 
			of milliG that	--activity thresholds
		exists thr:ppm in pp.lrl..pp.msr that	--target heart rate
			(MaximumSensorRate(sr) and
			 ActivityThreshold(a,at,sr) and
			 Factor(a,thr,at,sr) and
			 ReactionTime and RecoveryTime and
			 HysteresisPacing(t,sr)
			)
	}  --end of RateAdaptivePacing

-----------------------Atrial Tachycardia ------------------------

	--5.6 Atrial Tachycardia  (ATR)
	--  The Atrial Tachycardia  prevents long term pacing 
	--  of a patient at unacceptably high rates during atrial 
	--  tachycardia. When Atrial Tachycardia  is enabled, 
	--  the pulse generator shall declare an atrial tachycardia if
	--  the intrinsic atrial rate exceeds the URL for a sufficient 
	--  amount of time.
--Last Atrial Events definition
	{LastAevents:theTime lastAevents:
		all a:integer in 0..10 are
			a = (numberof m:s in m<=theTime that are  --after TheTime
				(ae.as or ae.ap)@m and	--there was A event at time m
				m>lastAevents[a].t) }	--yet before event "a"

--at least 8 of 10 beats are fast to start ATR
	{AtLeast8of10areAT:theTime:
		exists la:array 0..10 of AE
			in LastAevents(theTime,la)
			that
			8 <= (numberof i:integer in 1..10 that are
				la[i-1].t-la[i].t < pp.url_period)
	}	--end of AtLeast8of10areAT

--at least 6 of 10 beats are fast to continue ATR
	{AtLeast6of10areAT:theTime:
		exists la:array 0..10 of AE
			in LastAevents(theTime,la)
			that
			6 <= (numberof i:integer in 1..10 that are
				la[i-1].t-la[i].t < pp.url_period)
	}	--end of AtLeast6of10areAT

	--5.6.1 ATR Duration
	--  ATR Duration works as follows:
	--  1. When atrial tachycardia conditions are detected, 
	--  the ATR algorithm shall enter an ATR Duration state.
--atrial tachycardia detected => put out ATR-Dur Marker
	{PutOutATRDurMarker:theTime:
			--when 8 of 10 beats are fast previous to theTime
		AtLeast8of10areAT(theTime) and
			--and not otherwise in ATR
			--there was not some past time where 8of10 were fast
			--  and since then were 6of10 fast
		not (exists t:s in t<theTime and AtLeast8of10areAT(t)
			that
			all t2:s in t..theTime are
				AtLeast6of10areAT(t2)
			)
	}  --end of PutOutATRDurMarker
	
--Atrial event N cycles before
	{AeventNcyclesBefore:theTime aEvent n:
		n = (numberof t:s in t<=theTime	--# before theTime
				and (ae.as or ae.ap)@t
			that are t>aEvent.t)	}	--yet after a Event

	--5.6.1 ATR Duration
	--  2. When in ATR Duration, the PG shall delay a programmed number of
	--  cardiac cycles before entering Fallback.
	--  3. The Duration delay shall be terminated immediately 
	--  and Fallback shall be avoided if, during the Duration delay, 
	--  the ATR detection algorithm determines that atrial tachycardia is over.	
--put out ATR-FB marker if still fast after ATR Duration cycles
	{PutOutATRFBmarker:theTime:
		exists t:s in t<theTime and (ae.as or ae.ap)@t	--some previous a event
			that 
			(PutOutATRDurMarker(t)	--caused entry to ATR-Dur
			and
			pp.atrDuration@t =			--ATR Duration cycles ago
				(numberof t2:s in t2<=theTime and (ae.as or ae.ap)@t2
				that are t<t2)
			and  --all previous events were 6of10 fast
			(all t3:s in t3<=theTime and t3>t and
					(ae.as or ae.ap)@t3
				are AtLeast6of10areAT(t3))
			)
	}  --end of PutOutATRFBmarker

	--5.6.1 ATR Duration
	--  3. The Duration delay shall be terminated immediately 
	--  and Fallback shall be avoided if, during the Duration 
	--  delay, the ATR detection algorithm determines that atrial 
	--  tachycardia is over.
	--5.6.2 ATR Fallback
	--  3. During Fallback, if the ATR detection algorithm determines 
	--  that atrial tachycardia is over, the following shall occur:
	--    ² Fallback is terminated immediately
	--    ² The mode is switched back to normal
--put out ATR-End marker
	{PutOutATRendMarker:theTime:
		--if rate drops below 6of10 fast or fallback time expires
		(not AtLeast6of10areAT(theTime)	--no longer 6 of 10 fast
			and
			(exists t:s in t<theTime and (ae.as or ae.ap)@t
				that 
				(PutOutATRDurMarker(t)	--ATR started
				and 
				(all t2:s in t2<theTime and t2>t	--all cycles since
						and (ae.as or ae.ap)@t2
					are AtLeast6of10areAT(t2)))	--are fast
			)
		)
		or  --fallback time expired
		(exists t3:s --transitions on ventricular sense or pace
			in (ve.vp or ve.vs)@t3 and (t3+minutesToS(pp.atrFallback)=theTime)
			that
			(PutOutATRFBmarker(t3)
			and
				(all t4:s in t4<theTime and t3<t4	--all cycles since
						and (ve.vp or ve.vs)@t4
					are AtLeast6of10areAT(t4))	--are fast
			)
		)
	}  --end of PutOutATRendMarker

	--5.6.2 ATR Fallback
	--  If the atrial tachycardia condition exists after 
	--  the ATR Duration delay is over, the following shall occur:
	--  1. The PG enters a Fallback state and switches to a VVIR Fallback Mode.
	--  4. ATR-related mode switches shall always be synchronized to 
	--  a ventricular paced or sensed event.
--pace VVIR mode for ATR
	{PaceVVIRforATR:theTime:
		exists t:s --transitions on ventricular sense or pace
			in t<theTime and (ve.vp or ve.vs)@t and 
				t+minutesToS(pp.atrFallback)>=theTime
			that	--fallback started betfore fallback time expired
			(PutOutATRFBmarker(t)
			and
				(all t4:s in t4<theTime and t<t4	--all cycles since
						and (ve.vp or ve.vs)@t4
					are AtLeast6of10areAT(t4))	--are fast
			)		
	}  --end of PaceVVIforATR
	
	--5.6.2 ATR Fallback
	--  2. The pacing rate is dropped to the lower rate limit 
	--  The Fallback Time is the total time required to drop the rate to the LRL.
--rate to pace during ATR fallback
	{RateForATRpacing:theTime rate:
		exists t:s --transitions on ventricular sense or pace
			in t<theTime and (ve.vp or ve.vs)@t and 
				t+minutesToS(pp.atrFallback)>=theTime
			that	--fallback started betfore fallback time expired
			(PutOutATRFBmarker(t)
			and
			(exists t2:s in t2<t and (ve.vp or ve.vs)@t2
				that
				(10 = (numberof t3:s in t3<t and t2<t3
						that are (ve.vp or ve.vs)@t3)
				and 
				rate = sToPpm((t-t2)/10.0) + --start at average of 10 v events
					((pp.lrl@t-sToPpm((t-t2)/10.0))*
						((theTime-t)/minutesToS(pp.atrFallback)))
				)	--down to LRL after ATRfallback minutes
			))	
	}  --end of RateForATRpacing

--Atrial Tachycardia 
	{ATR:theTime:
		PutOutATRDurMarker(theTime)	--duration started marker
		and PutOutATRFBmarker(theTime)  --fallback started marker
		and PutOutATRendMarker(theTime)  --ATR end marker
		and (PaceVVIRforATR(theTime)=>	--pace VVIR at fallback rate
			exists fallbackRate:ppm that
			(RateForATRpacing(theTime,fallbackRate) and
			RateAdaptivePacing(theTime,BradyMode.VVIR,fallbackRate,accelerometer))
			)
	}  --end of ATR

----------------------------Atrial Markers-------------------------------------------

	{Amarker::
		--AP, a pace
		(ae.ap => 
			(atrialMarker.kind=AtrialMarkerKinds.mkrAP 
				and atrialMarker.t=ae.t) )
		and
		--TN, noise
		(ae.ns => 
			(atrialMarker.kind=AtrialMarkerKinds.mkrATN 
				and atrialMarker.t=ae.t) )
		and
		--AS, sense not in refractory, and not AT (no non-refractory a events in last url_period)
		((ae.as and not inArefractory(ae.t) and
				0=(numberof t2:s in ae.t-pp.url_period..ae.t that are 
					(ae.as or ae.ap)@t2 and not inArefractory(t2)) )
			=> 
			(atrialMarker.kind=AtrialMarkerKinds.mkrAS 
				and atrialMarker.t=ae.t) )
		and
		--AT, sense not in refractory, and has a non-refractory a event in last url_period
		((ae.as and not inArefractory(ae.t) and
				0<(numberof t2:s in ae.t-pp.url_period..ae.t that are 
					(ae.as or ae.ap)@t2 and not inArefractory(t2)) )
			=> 
			(atrialMarker.kind=AtrialMarkerKinds.mkrAT 
				and atrialMarker.t=ae.t) )
		and
		--(AS), sense in refractory
		((ae.as and not inArefractory(ae.t))
			=> 
			(atrialMarker.kind=AtrialMarkerKinds.mkrASref 
				and atrialMarker.t=ae.t) )
	}  --end of Amarker

--------------------------Ventricular Markers-----------------------------------

	{Vmarker::
		--TN, noise
		(ve.ns =>
			(ventricularMarker.kind=VentricularMarkerKinds.mkrVTN 
				and ventricularMarker.t=ve.t) )
		and	 --VS, ventricular sense
		((ve.vs and not inVRP(ve.t) and not PVC(ve))		
			=>
			(ventricularMarker.kind=VentricularMarkerKinds.mkrVS 
				and ventricularMarker.t=ve.t) )
		and	 --(VS), ventricular sense in refractory
		((ve.vs and inVRP(ve.t) and not PVC(ve))		
			=>
			(ventricularMarker.kind=VentricularMarkerKinds.mkrPVCref 
				and ventricularMarker.t=ve.t) )
		and	 --PVC, Premature Ventricular Contraction
		((ve.vs and not inVRP(ve.t) and PVC(ve))		
			=>
			(ventricularMarker.kind=VentricularMarkerKinds.mkrPVC 
				and ventricularMarker.t=ve.t) )
		and	 --(PVC), Premature Ventricular Contraction in refractory
		((ve.vs and inVRP(ve.t) and PVC(ve))		
			=>
			(ventricularMarker.kind=VentricularMarkerKinds.mkrPVCref 
				and ventricularMarker.t=ve.t) )
		and  --VP-Hy pace at Hysteresis Rate
		((ve.vp and  --event was v pace
			pp.hysteresisPacingOn and	--hysteresis pacing enabled
			(exists t2:s in t2<ve.t that  --previous event was a non-refractory sense
				ve.vs@t2 and not inVRP(t2) and
				2=(numberof t3:s in t2..ve.t that are (ve.vp or ve.vs)@t3) 
				and  --no atrial senses triggered the pace
				0=(numberof t4:s in t2..ve.t that are (ae.as or ae.ap)@t4)
				and  --time since last sense was hysteresis period
				(ve.t-t2=pp.hysteresis_period)
			) )	
			=>
			(ventricularMarker.kind=VentricularMarkerKinds.mkrHy 
				and ventricularMarker.t=ve.t) )
		and  --VP-Sr  pace at sensor rate
		((ve.vp and  --event was v pace
			pp.hysteresisPacingOn and	--hysteresis pacing enabled
			(exists t2:s in t2<ve.t that  --previous V event was a non-refractory sense
				ve.vs@t2 and not inVRP(t2) and
				2=(numberof t3:s in t2..ve.t that are (ve.vp or ve.vs)@t3) 
				and  --no atrial senses triggered the pace
				0=(numberof t4:s in t2..ve.t that are (ae.as or ae.ap)@t4)
				and  --time since last sense was shorter than LRL interval
				(ve.t-t2<pp.lrl_period)
				--and not rate smoothing down
			) )	
			=>
			(ventricularMarker.kind=VentricularMarkerKinds.mkrHy 
				and ventricularMarker.t=ve.t) )
		and  --VP^  rate smoothing up
		((ve.vp and  --event was v pace
			pp.rateSmoothingOn and 
			pp.mode in RateSmoothingModes and	--rate smoothing enabled
			(exists t2:s in t2<ae.t that  --previous A event was a non-refractory sense
				ae.as@t2 and not inVRP(t2) and
				1=(numberof t3:s in t2..ve.t that are (ae.as or ae.ap)@t3) 
				and  --time between last v event and v pace is the rate smoothing % more than last cci
				(exists cci:s in PCCL(ve.t,cci)	--cci is last cardiac cycle interval
					that
					TheTimeBetweenNonRefractoryEventsAndSubsequentPacesIsExactly(theTime,
						toInteger(cci*(1.0-percentToFloat(pp.rateSmoothingUp))) )
				) 
			) )	
			=>
			(ventricularMarker.kind=VentricularMarkerKinds.mkrUp
				and ventricularMarker.t=ve.t) )
		
	
	}  --end of Vmarker

--------------------------INVARIANT----------------------------------------------------

invariant
{all tt:s are
	LRL(tt) --lower rate limit
	and URL(tt)  --upper rate limit
	and (  --either
		AVdelay(tt)  --atrial-ventricular delay
		or --the v pace is delayed due to
		RateSmoothingUp(tt)  --rate smoothing up
		)
	and RateSmoothingDown(tt) 	--rate smoothing down
	and ATR(tt)	--atrial tachycardia response
	and RateAdaptivePacing(tt,pp.mode@tt,pp.lrl@tt,accelerometer)	--rate adaptive	
}  --end of invariant

end module   --of Pacemaker	
	