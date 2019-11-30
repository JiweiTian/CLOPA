function LOPA_CSTR(code,args)
% Performs various functions based on the passed code anr args
% code values:
% ----- 1 for RRF calculation for a pair of SIS probabilities
%------ 2 for P[A_BS] calculation using P[A_S], RRF
%------ 3 for plotting boundary and contour curves
%------ 4 for plotting RRF 3D curve
% args = [ P[A_S] P[A_BS]  RRF ]
% To be added: 1) pass CLOPA parameters as an argument, 2) auto calculation
% of boundary end points

%----------Create CPS objects-----------
BPCS = ControlSys;
SIS = SafetySys;
CSTR_CLOPA = CLOPA;

%----------------Initialize BPCS object--------
BPCS.Physical_Failure_Likelihood = 0.1;
BPCS.Cyber_Failure_Likelihood = 0.01;
BPCS.P_Physical_Failure = 0.1;
BPCS.P_AT_Corp = [0.1 0.1 0.5 0.5 1 0.5 0.125 0.5 0.5];
BPCS.P_AT_Attacker = [0.1 0.5 0.1 0.1 0.01 0.5 0.5];
BPCS.ProbAttacks;

%--------------Initialize CLOPA object--------
CSTR_CLOPA.Init_Event_Likelihood = [0.1 0.1 0.1];
CSTR_CLOPA.TMEL = 1E-6;
CSTR_CLOPA.P_IPL_Failure = [0.01 1 0.1; 0.01 0.1 0.1; 0.01 0.1 0.1];
CSTR_CLOPA.P_IPL_BPCS_Failure = [0.01 1 0.1];
CSTR_CLOPA.CalcParam(BPCS);

switch code
    case 1              %---------------CLOPA Claculation - RRF-----------
        SIS.P_Direct_Attack = args(1);
        SIS.P_BPCS_Attack = args(2);
        CSTR_CLOPA.CalcRRF(SIS);
        disp(CSTR_CLOPA.RRF_CLOPA);
    case 2              %---------------CLOPA Claculation - Prob of SIS BPCS Pivot Attack-----------
        SIS.P_Direct_Attack = args(1);
        CSTR_CLOPA.CalcSISProb(SIS,args(3));
        disp(SIS.P_BPCS_Attack);
    case {3,4,5}              
        [P_A_S,P_A_BS] = meshgrid(0:0.00001:0.005,0:0.0001:0.13);
        outindx = P_A_BS > 0.8*((CSTR_CLOPA.Beta/CSTR_CLOPA.Gamma_2)*(1-(CSTR_CLOPA.Gamma_1/CSTR_CLOPA.Beta)*P_A_S)./(1-P_A_S));
        P_A_BS(outindx) = NaN; P_A_S(outindx) = NaN;
        SIS.P_Direct_Attack = P_A_S; SIS.P_BPCS_Attack = P_A_BS;
        CSTR_CLOPA.CalcRRF(SIS);
        switch code
            case 3              %-----------Draw Boundary and Contour curves------------
                figure; [C,h] = contour(P_A_S,P_A_BS,CSTR_CLOPA.RRF_CLOPA,'ShowText','on'); xlabel('P[A_S]'); ylabel('P[A_{BS}]'); set(gca,'FontSize',28); clabel(C,h,'FontSize',28); grid on; hold on;
                P_A_S = [0:0.0001:CSTR_CLOPA.Beta/CSTR_CLOPA.Gamma_1]; P_A_BS = (CSTR_CLOPA.Beta/CSTR_CLOPA.Gamma_2)*(1-(CSTR_CLOPA.Gamma_1/CSTR_CLOPA.Beta)*P_A_S)./(1-P_A_S); plot(P_A_S,P_A_BS);
            case 4              %-----------3D RRF plot----------------------)
                figure; h = mesh(SIS.P_Direct_Attack,SIS.P_BPCS_Attack,CSTR_CLOPA.RRF_CLOPA);  xlabel('P[A_S]'); ylabel('P[A_{BS}]'); zlabel('RRF'); set(gca,'FontSize',28);
            case 5              %----------Contour plot for P[A_S], CLOPA vs LOPA -------
                figure; [C,h] = contour(P_A_BS,CSTR_CLOPA.RRF_CLOPA,P_A_S,'ShowText','on'); xlabel('P[A_{BS}]'); ylabel('RRF'); set(gca,'FontSize',28); clabel(C,h,'FontSize',28); grid on;
                hold on; plot(P_A_BS,CSTR_CLOPA.RRF_LOPA*ones(1,length(P_A_BS)));
        end
    otherwise
        disp("Enter valid code.");
end
