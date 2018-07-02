function [time_loc,R_loc,R_value] = ECG_detection(m_fs,m_IIs,m_t0s)

t = m_t0s;
x0 = m_IIs;

x0 = x0(~isnan(x0));
t = t(~isnan(x0));

x1 = x0;
N = length (x0); % Silength
% Cancellation DC drift and normalization
x1 = x1 - mean (x1 ); % cancel DC conponents
x1 = x1/ max( abs(x1 )); % normalize to one

% Low Pass Filtering
b=[1 0 0 0 0 0 -2 0 0 0 0 0 1]; a=[1 -2 1];
h_LP=filter(b,a,[1 zeros(1,12)]); % transfer function of LPF
x2 = conv (x1 ,h_LP);
x2 = x2 (6+[1: N]); %cancle delay
x2 = x2/ max( abs(x2 )); % normalize , for convenience .

% High Pass Filtering
b = [-1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 32 -32 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
a = [1 -1];
h_HP=filter(b,a,[1 zeros(1,32)]); % impulse response iof HPF
x3 = conv (x2 ,h_HP);
x3 = x3/ max( abs(x3 ));

% Derivative Filter
% Make impulse response
h = [-1 -2 0 2 1]/8;
% Apply filter
x4 = conv (x3 ,h);
x4 = x4 (2+[1:N]);
x4 = x4/ max( abs(x4 ));

% Squaring
x5 = x4 .^2;
x5 = x5/ max( abs(x5 ));

% Moving Window Integration
% Make impulse response
h = ones (1 ,31)/31;
delay = 15; % Delay in samples

% Apply filter
x6 = conv (x5 ,h);
x6 = x6 (15+[1: N]);
x6 = x6/ max( abs(x6 ));

% Find QRS Points Which it is different than Pan-Tompkins algorithm
max_h = max(x6);
thresh = nanmean (x6);
poss_reg =(x6>thresh*max_h)';
left = find(diff([0 poss_reg'])==1);
right = find(diff([poss_reg' 0])==-1);
left=left-(6+delay); % cancle delay because of LP and HP
right=right-(6+delay);% cancle delay because of LP and HP
left=abs(left);
right=abs(right);

for i=1:length(left)
    try
        [R_value(i) R_loc(i)] = max( x0(left(i):right(i)) );
        R_loc(i) = R_loc(i)-1+left(i); % add ofm_fset
        
        [Q_value(i) Q_loc(i)] = min( x0(left(i):R_loc(i)) );
        Q_loc(i) = Q_loc(i)-1+left(i); % add ofm_fset
        
        [S_value(i) S_loc(i)] = min( x0(left(i):right(i)) );
        S_loc(i) = S_loc(i)-1+left(i); % add ofm_fset
    catch
        R_value(i)= NaN;
        R_loc(i) = NaN;
        S_loc(i) = NaN;
        Q_loc(i) = NaN;
    end
end

% there is no selective wave
R_loc=R_loc(find(R_loc~=0));
Q_loc=Q_loc(find(Q_loc~=0));
S_loc=S_loc(find(S_loc~=0));


R_loc1 = R_loc(find(R_value~=0));
R_value1=R_value(find(R_value ~=0));

nan_val = isnan(R_value);
R_value(nan_val)=[];
R_loc(nan_val)=[];

time_loc = t(R_loc);
%% plot check
% figure(1)
% subplot(4,1,1)
% plot(t,x0)
% xlabel('second');ylabel('Volts');title('Input ECG Signal')
% subplot(4,1,2)
% plot(t,x1)
% xlabel('second');ylabel('Volts');title(' ECG Signal after cancellation DC drift and normalization')
% subplot(4,1,3)
% plot([0:length(x2)-1]/m_fs,x2)
% xlabel('second');ylabel('Volts');title(' ECG Signal after LPF')
% xlim([0 max(t)])
% subplot(4,1,4)
% plot([0:length(x3)-1]/m_fs,x3)
% xlabel('second');ylabel('Volts');title(' ECG Signal after HPF')
% xlim([0 max(t)])
%
% figure(2)
% subplot(4,1,1)
% plot([0:length(x4)-1]/m_fs,x4)
% xlabel('second');ylabel('Volts');title(' ECG Signal after Derivative')
% subplot(4,1,2)
% plot([0:length(x5)-1]/m_fs,x5)
% xlabel('second');ylabel('Volts');title(' ECG Signal Squaring')
% subplot(4,1,3)
% plot([0:length(x6)-1]/m_fs,x6)
% xlabel('second');ylabel('Volts');title(' ECG Signal after Averaging')
% subplot(4,1,4)
% plot (t,x0,t(R_loc) ,R_value , 'r^');

% figure(3)
% plot (t,x0,t(R_loc) ,R_value , 'r^',t(R_loc1),R_value1 , 'go');
%%
% values=x2(R_loc);
% % 1 beat/sec x 60 sec/min = 60 beats/min.
% %%R-R interval using diffrence operation method
% tiscl=t(2)-t(1);
% px=diff(R_loc);
% d_tms=find(diff(R_loc)>200);
% d_men=mean(px(d_tms));
% beat=d_men*tiscl;
% heart_rate=1/beat*60;
% fprintf('%2.1f seconds/beat\n',beat);
% rs=sprintf('Heart Rate= %2.1f beats per minute \n',heart_rate);

end