% THIS CODE IS TO CREATE THE ANNOTATION OF ASTHMATIC PERIOD FROM MIMICII
% PATIENT RECORS
% FROM MIMICII DATABSE - PHYSIONET ATM

% WRITTEN BY ENLIN NGO - BME DEPARMENT - INTERNATIONAL UNIVERSITY HO CHI MINH CITY (VNU-HCMIU)

%% READ RECORD
asth_duration_thresh = 60 ;  % (sec) asthma attack duration threshold = 2 min. 
% Document said few mins to hours or days

%% find points that meet asthma features 
%CLASSIFICATION
%MILD/ MODERATE: 92 <= SpO2 <= 95, 20 < RESP =< 25, PULSE < 110
%ACUTE SEVERE:   92 <= SpO2 <= 95, RESP > 25, PULSE >=110
%LIFE THREATENING: SpO2 < 92

%MILD/ MODERATE
%% Mild/moderate : pulse [100-120], O2 [90-95]
asth_locGE = find((n_SpO2 >=95 & n_RESP < 21));
asth_locMM = find((n_SpO2 >=90 & n_SpO2 <=95 & n_RESP > 20 & n_RESP < 30 & n_PULSE <120 & n_PULSE >100));
% severe : pulse [100-120], O2 [90-95]
asth_locAS = find((n_SpO2 <90 & n_RESP > 30 & n_PULSE >= 120));

fprintf('Asthma duration threshold: %d\n', asth_duration_thresh); 
asth_ann = zeros(1,length(n_t0)); %has to be 1 and 0 for the following lines
asth_ann(asth_locGE) = 1;
normal_ann = ~asth_ann;

%Detect asthma period
ann1 = diff([0 ~asth_ann==0 0]);
pE = find(ann1==-1) - 1; %end of ones sequence
pS = find(ann1==1);       %start of ones sequence
asth_duration = pE-pS+1;    % refer to point, not seconds

%Filter asthma period that less than thresh. Document said few mins to hours or days
res = find((asth_duration)*n_interval >= asth_duration_thresh);
n_asth_duration = asth_duration(res);
n_attackPoint = [pS(res);pE(res)] ;                         % refer to point
m_asth_duration = n_asth_duration * n_interval/m_interval;
m_attackPoint = n_attackPoint* n_interval/m_interval;       % refer to point of WHOLE M RECORD

asth_ann(asth_ann==0) = NaN;      %change back to NaN
asth_severity = zeros(3,length(n_attackPoint));
for n = 1:size(n_attackPoint,2)
    if length(find(asth_locMM == n_attackPoint(1,n)))==1 
    asth_severity(1,n) = 1;
    elseif length(find(asth_locAS == n_attackPoint(1,n)))==1
    asth_severity(2,n) = 1;
    elseif length(find(asth_locLT == n_attackPoint(1,n)))==1
    asth_severity(3,n) = 1;
    end
end
 

