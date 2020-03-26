%--------------- (BPCS Class) -------------
classdef ControlSys < handle
   properties
     P_Direct_Attack                    % P[A_B]
     P_SIS_Attack                       % P[A_SB]
     P_Physical_Failure                 % P[B_p]
     P_Cyber_Failure                    % P[B_c]
     Cyber_Failure_Likelihood           % Lambda_c
     Physical_Failure_Likelihood        % Lambda_p
     P_AT_Corp                          % Attack tree 'a' values
     P_AT_Attacker                      % Attack tree 'c' values
   end
   methods
      function ProbAttacks(obj)
         obj.P_Direct_Attack = (obj.P_AT_Corp(2)*(obj.P_AT_Attacker(2) + obj.P_AT_Attacker(1)*obj.P_AT_Attacker(3))*(obj.P_AT_Corp(3)*obj.P_AT_Corp(4) + obj.P_AT_Corp(5)*obj.P_AT_Corp(6))*(obj.P_AT_Attacker(2) + obj.P_AT_Attacker(4))) + obj.P_AT_Attacker(5);
         obj.P_SIS_Attack = obj.P_AT_Corp(8)*obj.P_AT_Corp(9)*(obj.P_AT_Corp(7) + obj.P_AT_Attacker(6) + obj.P_AT_Attacker(7));
      end
   end
end