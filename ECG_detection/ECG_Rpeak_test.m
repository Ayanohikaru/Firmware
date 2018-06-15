x0 = m_II;
t = m_t0;
fs = m_fs;

plotall = 1;
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
thresh = mean (x6);
poss_reg =(x6>thresh*max_h)';
left = find(diff([0 poss_reg'])==1);
right = find(diff([poss_reg' 0])==-1);
left=left-(6+delay); % cancle delay because of LP and HP
right=right-(6+delay);% cancle delay because of LP and HP
left=abs(left);
right=abs(right);

for i=1:length(left)
[R_value(i) R_loc(i)] = max( x0(left(i):right(i)) );
R_loc(i) = R_loc(i)-1+left(i); % add offset

[Q_value(i) Q_loc(i)] = min( x0(left(i):R_loc(i)) );
Q_loc(i) = Q_loc(i)-1+left(i); % add offset

[S_value(i) S_loc(i)] = min( x0(left(i):right(i)) );
S_loc(i) = S_loc(i)-1+left(i); % add offset
end

% there is no selective wave
Q_loc=Q_loc(find(Q_loc~=0));
R_loc=R_loc(find(R_loc~=0));
S_loc=S_loc(find(S_loc~=0));

% %Filter false detected R peak
% threshold_R = 0.3; %threshold for R_value = %
% for i = 2 : length(R_value)-1
%     if (abs(R_value(i)/R_value(i-1) - 1) > threshold_R) && (abs(R_value(i)/R_value(i+1) - 1) > threshold_R)
%     R_value(i) = NaN;
%     end
% end
%     
% %Exclude false detected R peak with R value = NaN
% R_loc = R_loc(~isnan(R_value));
% R_value =R_value(~isnan(R_value));

%Plot
if plotall == 1
    figure(2)
    subplot(4,1,1)
    plot(t,x0)
    xlabel('second');ylabel('Volts');title('Input ECG Signal')
    subplot(4,1,2)
    plot(t,x1)
    xlabel('second');ylabel('Volts');title(' ECG Signal after cancellation DC drift and normalization')
    subplot(4,1,3)
    plot([0:length(x2)-1]/fs,x2)
    xlabel('second');ylabel('Volts');title(' ECG Signal after LPF')
    xlim([0 max(t)])
    subplot(4,1,4)
    plot([0:length(x3)-1]/fs,x3)
    xlabel('second');ylabel('Volts');title(' ECG Signal after HPF')
    xlim([0 max(t)])
    figure(3)
    subplot(4,1,1)
    plot([0:length(x4)-1]/fs,x4)
    xlabel('second');ylabel('Volts');title(' ECG Signal after Derivative')
    subplot(4,1,2)
    plot([0:length(x5)-1]/fs,x5)
    xlabel('second');ylabel('Volts');title(' ECG Signal Squaring')
    subplot(4,1,3)
    plot([0:length(x6)-1]/fs,x6)
    xlabel('second');ylabel('Volts');title(' ECG Signal after Averaging')
    subplot(4,1,4)
    plot (t,x0,t(R_loc) ,R_value , 'r^');
end




