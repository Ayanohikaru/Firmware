mSecStart = datenum(m_starttime);
nSecStart = datenum(n_starttime);
if mSecStart == nSecStart
    time_ex = 0;
elseif mSecStart>nSecStart % file ECG tr? h?n
    time_ex = datestr(mSecStart-nSecStart,'HH:MM:SS');
    index_minute = str2num(time_ex(4:5));
    index_second = str2num(time_ex(7:8));
    index_time = round((index_minute*60+index_second)*n_fs);
    if index_minute ~= 0
        n_SpO2 = n_SpO2(index_time:end);
        n_RESP = n_RESP(index_time:end);
        n_PULSE = n_PULSE(index_time:end);
    end
else %file numberic tr? h?n
    time_ex =datestr(nSecStart-mSecStart,'HH:MM:SS')
    index_minute = str2num(time_ex(4:5));
    index_second = str2num(time_ex(7:8));
    index_time = (index_minute*60+index_second)*125;
    if index_time ~= 0
        m_ECG = m_ECG(index_time:end);
        m_PPG = m_PPG (index_time:end);
        m_RESP = m_RESP (index_time:end);
    end
end
%% recheck the number of sample
%s? sample * s? gi�y/sample (Hz) = th?i gian (s)
number_time = round(size(n_SpO2,2)*(1/n_fs)/60)-1; 
number_samp = number_time*7500;
if size(m_ECG,2)>= number_samp
   m_ECG = m_ECG(1:number_samp);
   if isempty(m_PPG) == 0
       m_PPG = m_PPG(1:number_samp);
   end
   if isempty(m_RESP) == 0
       m_RESP = m_RESP(1:number_samp);
   end
else %ECG ng?n h?n
   ECG_length = (round(size(m_ECG,2)/7500)-1)*7500;
   m_ECG = m_ECG(1:ECG_length);
   if isempty(m_PPG) == 0
       m_PPG = m_PPG(1:ECG_length);
   end
   if isempty(m_RESP) == 0
       m_RESP = m_RESP(1:ECG_length);
   end
end