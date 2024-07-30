//BLESS.sysml 

library package BLESS_Types {
  doc /* SysMLv2 package for BLESS_Types in AADL */
  import AADL::AadlEvent;
  import AADL::AadlData;
  import AADL::AadlEventData;
  import ScalarValues::*;

  item def Boolean :> AADL::AadlData {
    attribute redefines value : ScalarValues::Boolean;
  }
  
  item def Integer :> AADL::AadlData {
    attribute redefines value : ScalarValues::Integer;
  }
  
  item def Real :> AADL::AadlData {
    attribute redefines value : ScalarValues::Real;
  }
  
  item def Time :> AADL::AadlData {
    attribute redefines value : ScalarValues::NumericalValue;
  }
  
  item def String :> AADL::AadlData {
    attribute redefines value : ScalarValues::String;
  }    
}

library package BLESS {
  import BLESS_Types::Time;
  import ScalarValues::*;
  import Metaobjects::SemanticMetadata;
  
  calc def AtOp {
    in pred : ScalarValues::Boolean;
    in evalTime : BLESS_Types::Time;
    return : ScalarValues::Boolean; 
  }
  
  abstract calc atOp : AtOp;
  
  metadata def <At> temporalOperator :> SemanticMetadata {
    :>> baseType = atOp meta SysML::CalculationUsage;
  }
  
}

