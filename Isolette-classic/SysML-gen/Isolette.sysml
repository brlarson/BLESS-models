package KSU_Isolette {
	part def isolette :> AADL::System {
		out port heat_out : AADL::DataPort {
			out item :>> type : Nursery::Heat;
		}

		inout port control_monitor_alarm : AADL::DataPort {
			inout item :>> type : Nursery::Interface_Interaction;
		}

		in port air_temperature : AADL::DataPort {
			in item :>> type : Iso_Types::'current_temperature.i';
		}
	}

	part def 'isolette.single_sensor' :> isolette {
		part temperature_sensor : Devices::'temperature_sensor.impl';
		part heat_source : Devices::'heat_source.impl';
		part thermostat : 'thermostat_single_sensor.impl';
		part operator_interface : 'operator_interface.impl';
		connection a2ts : AADL::PortConnection connect air_temperature to temperature_sensor.air;
		connection ct : AADL::PortConnection connect temperature_sensor.current_temperature to thermostat.current_temperature;
		connection hc : AADL::PortConnection connect thermostat.heat_control to heat_source.heat_control;
		connection hs : AADL::PortConnection connect heat_source.heat_out to heat_out;
		connection oi : AADL::PortConnection connect control_monitor_alarm to operator_interface.control_monitor_alarm;
		connection ldt : AADL::PortConnection connect operator_interface.lower_desired_temperature to thermostat.lower_desired_temperature;
		connection udt : AADL::PortConnection connect operator_interface.upper_desired_temperature to thermostat.upper_desired_temperature;
		connection lat : AADL::PortConnection connect operator_interface.lower_alarm_temperature to thermostat.lower_alarm_temperature;
		connection uat : AADL::PortConnection connect operator_interface.upper_alarm_temperature to thermostat.upper_alarm_temperature;
		connection rs : AADL::PortConnection connect thermostat.regulator_status to operator_interface.regulator_status;
		connection ms : AADL::PortConnection connect thermostat.monitor_status to operator_interface.monitor_status;
		connection dt : AADL::PortConnection connect thermostat.display_temperature to operator_interface.display_temperature;
		connection al : AADL::PortConnection connect thermostat.alarm_control to operator_interface.alarm;
	}

	part def 'isolette.dual_sensor' :> isolette {
		part control_sensor : Devices::'temperature_sensor.impl';
		part monitor_sensor : Devices::'temperature_sensor.impl';
		part heat_source : Devices::'heat_source.impl';
		part thermostat : 'thermostat_dual_sensor.impl';
		part operator_interface : 'operator_interface.impl';
		connection a2cs : AADL::PortConnection connect air_temperature to control_sensor.air;
		connection a2ms : AADL::PortConnection connect air_temperature to monitor_sensor.air;
		connection hs : AADL::PortConnection connect heat_source.heat_out to heat_out;
		connection oi : AADL::PortConnection connect control_monitor_alarm to operator_interface.control_monitor_alarm;
		connection cont : AADL::PortConnection connect control_sensor.current_temperature to thermostat.control_temp;
		connection ct : AADL::PortConnection connect monitor_sensor.current_temperature to thermostat.monitor_temp;
		connection hc : AADL::PortConnection connect thermostat.heat_control to heat_source.heat_control;
		connection ldt : AADL::PortConnection connect operator_interface.lower_desired_temperature to thermostat.lower_desired_temperature;
		connection udt : AADL::PortConnection connect operator_interface.upper_desired_temperature to thermostat.upper_desired_temperature;
		connection lat : AADL::PortConnection connect operator_interface.lower_alarm_temperature to thermostat.lower_alarm_temperature;
		connection uat : AADL::PortConnection connect operator_interface.upper_alarm_temperature to thermostat.upper_alarm_temperature;
		connection rs : AADL::PortConnection connect thermostat.regulator_status to operator_interface.regulator_status;
		connection ms : AADL::PortConnection connect thermostat.monitor_status to operator_interface.monitor_status;
		connection dt : AADL::PortConnection connect thermostat.display_temperature to operator_interface.display_temperature;
		connection al : AADL::PortConnection connect thermostat.alarm_control to operator_interface.alarm;
	}

	part def thermostat_single_sensor :> AADL::System {
		in port current_temperature : AADL::DataPort {
			in item :>> type : Iso_Types::'current_temperature.i';
		}

		out port heat_control : AADL::DataPort {
			out item :>> type : Iso_Types::on_off;
		}

		in port lower_desired_temperature : AADL::DataPort {
			in item :>> type : Iso_Types::'lower_desired_temperature.i';
		}

		in port upper_desired_temperature : AADL::DataPort {
			in item :>> type : Iso_Types::'upper_desired_temperature.i';
		}

		in port lower_alarm_temperature : AADL::DataPort {
			in item :>> type : Iso_Types::'lower_alarm_temperature.i';
		}

		in port upper_alarm_temperature : AADL::DataPort {
			in item :>> type : Iso_Types::'upper_alarm_temperature.i';
		}

		out port regulator_status : AADL::DataPort {
			out item :>> type : Iso_Types::status;
		}

		out port monitor_status : AADL::DataPort {
			out item :>> type : Iso_Types::status;
		}

		out port display_temperature : AADL::DataPort {
			out item :>> type : Iso_Types::measured_temperature_range;
		}

		out port alarm_control : AADL::DataPort {
			out item :>> type : Iso_Types::on_off;
		}
	}

	part def 'thermostat_single_sensor.impl' :> thermostat_single_sensor {
		part detect_regulator_fail : Devices::'detect_regulator_failure.impl';
		part detect_monitor_fail : Devices::'detect_monitor_failure.impl';
		part regulate_temperature : Regulate::'regulate_temperature.impl';
		part monitor_temperature : Monitor::'monitor_temperature.impl';
		connection tctm : AADL::PortConnection connect current_temperature to monitor_temperature.current_temperature;
		connection tctr : AADL::PortConnection connect current_temperature to regulate_temperature.current_temperature;
		connection thc : AADL::PortConnection connect regulate_temperature.heat_control to heat_control;
		connection tudt : AADL::PortConnection connect upper_desired_temperature to regulate_temperature.upper_desired_temperature;
		connection tldt : AADL::PortConnection connect lower_desired_temperature to regulate_temperature.lower_desired_temperature;
		connection tuat : AADL::PortConnection connect upper_alarm_temperature to monitor_temperature.upper_alarm_temperature;
		connection tlat : AADL::PortConnection connect lower_alarm_temperature to monitor_temperature.lower_alarm_temperature;
		connection trs : AADL::PortConnection connect regulate_temperature.regulator_status to regulator_status;
		connection tdt : AADL::PortConnection connect regulate_temperature.displayed_temp to display_temperature;
		connection tms : AADL::PortConnection connect monitor_temperature.monitor_status to monitor_status;
		connection ta : AADL::PortConnection connect monitor_temperature.alarm_control to alarm_control;
		connection tf : AADL::PortConnection connect detect_regulator_fail.internal_failure to monitor_temperature.regulator_failure;
	}

	part def thermostat_dual_sensor :> AADL::System {
		in port control_temp : AADL::DataPort {
			in item :>> type : Iso_Types::'current_temperature.i';
		}

		in port monitor_temp : AADL::DataPort {
			in item :>> type : Iso_Types::'current_temperature.i';
		}

		out port heat_control : AADL::DataPort {
			out item :>> type : Iso_Types::on_off;
		}

		in port lower_desired_temperature : AADL::DataPort {
			in item :>> type : Iso_Types::'lower_desired_temperature.i';
		}

		in port upper_desired_temperature : AADL::DataPort {
			in item :>> type : Iso_Types::'upper_desired_temperature.i';
		}

		in port lower_alarm_temperature : AADL::DataPort {
			in item :>> type : Iso_Types::'lower_alarm_temperature.i';
		}

		in port upper_alarm_temperature : AADL::DataPort {
			in item :>> type : Iso_Types::'upper_alarm_temperature.i';
		}

		out port regulator_status : AADL::DataPort {
			out item :>> type : Iso_Types::status;
		}

		out port monitor_status : AADL::DataPort {
			out item :>> type : Iso_Types::status;
		}

		out port display_temperature : AADL::DataPort {
			out item :>> type : Iso_Types::measured_temperature_range;
		}

		out port alarm_control : AADL::DataPort {
			out item :>> type : Iso_Types::on_off;
		}
	}

	part def 'thermostat_dual_sensor.impl' :> thermostat_dual_sensor {
		part detect_regulator_fail : Devices::'detect_regulator_failure.impl';
		part detect_monitor_fail : Devices::'detect_monitor_failure.impl';
		part regulate_temperature : Regulate::'regulate_temperature.impl';
		part monitor_temperature : Monitor::'monitor_temperature.impl';
		connection tctm : AADL::PortConnection connect monitor_temp to monitor_temperature.current_temperature;
		connection tctr : AADL::PortConnection connect control_temp to regulate_temperature.current_temperature;
		connection thc : AADL::PortConnection connect regulate_temperature.heat_control to heat_control;
		connection tudt : AADL::PortConnection connect upper_desired_temperature to regulate_temperature.upper_desired_temperature;
		connection tldt : AADL::PortConnection connect lower_desired_temperature to regulate_temperature.lower_desired_temperature;
		connection tuat : AADL::PortConnection connect upper_alarm_temperature to monitor_temperature.upper_alarm_temperature;
		connection tlat : AADL::PortConnection connect lower_alarm_temperature to monitor_temperature.lower_alarm_temperature;
		connection trs : AADL::PortConnection connect regulate_temperature.regulator_status to regulator_status;
		connection tdt : AADL::PortConnection connect regulate_temperature.displayed_temp to display_temperature;
		connection tms : AADL::PortConnection connect monitor_temperature.monitor_status to monitor_status;
		connection ta : AADL::PortConnection connect monitor_temperature.alarm_control to alarm_control;
		connection tf : AADL::PortConnection connect detect_regulator_fail.internal_failure to monitor_temperature.regulator_failure;
	}

	part def operator_interface :> AADL::System {
		inout port control_monitor_alarm : AADL::DataPort {
			inout item :>> type : Nursery::Interface_Interaction;
		}

		out port lower_desired_temperature : AADL::DataPort {
			out item :>> type : Iso_Types::'lower_desired_temperature.i';
		}

		out port upper_desired_temperature : AADL::DataPort {
			out item :>> type : Iso_Types::'upper_desired_temperature.i';
		}

		out port lower_alarm_temperature : AADL::DataPort {
			out item :>> type : Iso_Types::'lower_alarm_temperature.i';
		}

		out port upper_alarm_temperature : AADL::DataPort {
			out item :>> type : Iso_Types::'upper_alarm_temperature.i';
		}

		in port regulator_status : AADL::DataPort {
			in item :>> type : Iso_Types::status;
		}

		in port monitor_status : AADL::DataPort {
			in item :>> type : Iso_Types::status;
		}

		in port display_temperature : AADL::DataPort {
			in item :>> type : Iso_Types::measured_temperature_range;
		}

		in port alarm : AADL::DataPort {
			in item :>> type : Iso_Types::on_off;
		}
	}

	part def 'operator_interface.impl' :> operator_interface;
}