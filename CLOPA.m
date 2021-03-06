%--------------- (LOPA Class) -------------
classdef CLOPA < handle
   properties
     P_IPL_Failure = []                 % P[L_i]
     P_IPL_BPCS_Failure = []            % P[L_B]
     Init_Event_Likelihood              % Lambda_i
     TMEL                               % Target Mitigated Event Likelihood
     Alpha_1
     Alpha_2
     Beta
     Gamma_1
     Gamma_2
     Gamma_3
     RRF_CLOPA
     RRF_CLOPA_Min
     RRF_LOPA
   end
   methods
      function CalcParam(obj,BPCS)
         %obj.Alpha_1 = BPCS.P_Physical_Failure*(obj.Init_Event_Likelihood*prod(obj.P_IPL_Failure,2)) + (BPCS.Physical_Failure_Likelihood + BPCS.Cyber_Failure_Likelihood)*prod(obj.P_IPL_BPCS_Failure);
         %obj.Alpha_2 = (1-BPCS.P_Physical_Failure)*(obj.Init_Event_Likelihood*prod(obj.P_IPL_Failure,2));
         obj.Alpha_1 = BPCS.P_Physical_Failure*(obj.Init_Event_Likelihood*prod(obj.P_IPL_Failure,2) + BPCS.Cyber_Failure_Likelihood*prod(obj.P_IPL_BPCS_Failure)) + BPCS.Physical_Failure_Likelihood*prod(obj.P_IPL_BPCS_Failure);
         obj.Alpha_2 = (1-BPCS.P_Physical_Failure)*(obj.Init_Event_Likelihood*prod(obj.P_IPL_Failure,2) + BPCS.Cyber_Failure_Likelihood*prod(obj.P_IPL_BPCS_Failure));
         obj.Beta = obj.TMEL;
         obj.Gamma_1 = obj.Alpha_1 + obj.Alpha_2*(BPCS.P_Direct_Attack + BPCS.P_SIS_Attack - BPCS.P_Direct_Attack*BPCS.P_SIS_Attack);
         obj.Gamma_2 = (obj.Alpha_1 + obj.Alpha_2)*BPCS.P_Direct_Attack;
         obj.Gamma_3 = obj.Alpha_1 + obj.Alpha_2*BPCS.P_Direct_Attack;
      end
      function obj = CalcRRF(obj,SIS)
          obj.RRF_LOPA = obj.Alpha_1/obj.Beta;
          obj.RRF_CLOPA = (obj.Gamma_3 - (obj.Gamma_3*SIS.P_Direct_Attack + obj.Gamma_2*SIS.P_BPCS_Attack - obj.Gamma_2*SIS.P_Direct_Attack.*SIS.P_BPCS_Attack))./(obj.Beta - (obj.Gamma_1*SIS.P_Direct_Attack + obj.Gamma_2*SIS.P_BPCS_Attack - obj.Gamma_2*SIS.P_Direct_Attack.*SIS.P_BPCS_Attack));
          obj.RRF_CLOPA_Min = obj.Gamma_3/obj.Beta; 
      end
      function CalcSISProb(obj,SIS,RRF_Target)
          SIS.P_BPCS_Attack = (((1/RRF_Target)*obj.Gamma_3 - obj.Beta)/(obj.Gamma_2*((1/RRF_Target)-1)))*((1-(((1/RRF_Target)*obj.Gamma_3-obj.Gamma_1)/((1/RRF_Target)*obj.Gamma_3-obj.Beta))*SIS.P_Direct_Attack)/(1-SIS.P_Direct_Attack));
      end   
   end
end

