package vvi_mode {
	part def VVI :> AADL::Thread {
		in port lrl : AADL::DataPort {
			in item :>> type : vvi_mode::CardiacDuration;
		}

		in port vrp : AADL::DataPort {
			in item :>> type : vvi_mode::CardiacDuration;
		}

		in port s : AADL::EventPort;
		out port p : AADL::EventPort;
		out port n : AADL::EventPort;
		in port h : AADL::EventPort;
	}

	part def 'VVI.i' :> VVI;

	part def RateControl :> AADL::Thread {
		out port lrl : AADL::DataPort {
			out item :>> type : vvi_mode::CardiacDuration;
		}

		out port vrp : AADL::DataPort {
			out item :>> type : vvi_mode::CardiacDuration;
		}

		attribute :>> Period = 10000 [AADL_Project::Time_Units::ms];
	}

	part def PG :> AADL::System {
		in port lead : AADL::BusAccess {
			in ref :>> type : vvi_mode::IS1;
		}
	}

	part def 'PG.i' :> PG {
		part fe : vvi_mode::FrontEnd;
		part pp : 'PGprocess.i';
		connection header : AADL::AccessConnection connect fe.lead to lead;
		connection sense : AADL::PortConnection connect fe.sense to pp.sense;
		connection pace : AADL::PortConnection connect pp.pace to fe.pace;
	}

	part def PGprocess :> AADL::Process {
		in port sense : AADL::EventPort;
		out port pace : AADL::EventPort;
	}

	part def 'PGprocess.i' :> PGprocess {
		part t : 'VVI.i';
		part rc : vvi_mode::RateControl;
		connection s : AADL::PortConnection connect sense to t.s;
		connection p : AADL::PortConnection connect t.p to pace;
		connection l : AADL::PortConnection connect rc.lrl to t.lrl;
		connection v : AADL::PortConnection connect rc.vrp to t.vrp;
	}

	part def FrontEnd :> AADL::Device {
		out port sense : AADL::EventPort;
		in port pace : AADL::EventPort;

		in port lead : AADL::BusAccess {
			in ref :>> type : vvi_mode::IS1;
		}
	}

	part def IS1 :> AADL::Bus;

	part def Patient :> AADL::Abstract {
		in port lead : AADL::BusAccess {
			in ref :>> type : vvi_mode::IS1;
		}
	}

	part def Implant :> AADL::System;

	part def 'Implant.i' :> Implant {
		part patient : vvi_mode::Patient;
		part lead : vvi_mode::IS1;
		part pacemaker : 'PG.i';
		binding toPatient : AADL::AccessConnection bind lead = patient.lead.type;
		binding toPG : AADL::AccessConnection bind lead = pacemaker.lead.type;
	}

	part def CardiacDuration :> AADL::Data;
}