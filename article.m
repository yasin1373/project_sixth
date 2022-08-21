T = readtable('C:\Users\acer\Desktop\all_squat\squat1.csv');
s = readtable('C:\Users\acer\Desktop\CamsKneeData\edited.squat.csv');
s = table2array(s);
b = T(:,2);
% Converting table to array for manipulation
b = table2array(b);
fs = 100;            % Sampling frequency 
Ts = 1 / fs;          % Period
t  = 0 : Ts : 12.0995;
n = length(t);
plot(t,b);  
xlabel('Number of samples');
ylabel('Amplitude');
% Removing zero drift of EMG signal
data = detrend(b);
figure; plot(t,data);title('zero_drift_removal');
% Rectification of EMG signal
data_abs = abs(data);
figure; plot(t,data_abs);title('Rectification');
% Butter worth filter
order = 2 ;
low = 4/(fs/2) ;
high = 25/(fs/2) ;
[b,a] = butter(order,[low,high],'bandpass');
data_butter = filtfilt(b,a,data_abs);
figure; plot(t,data_butter);title('butter worth filtered');
% Root mean square error
w = 20;
for i=1:n-w
    data_rms(i) = rms(data_butter(i:i+w));
end
figure; plot(t(1:n-w),data_rms);title('root mean squared error');
% Normalization
for i=1:n-w
    data_norm(i) = data_rms(i)./max(data_rms);
end
figure; plot(t(1:n-w),data_norm);title('normalized');
% extracting required hip,knee,ankle coordinates and employing Lowpass filter

hx=0.001*s(:,40); hx=hx(~isnan(hx));[b,a] = butter(1,1/200);hx = filtfilt(b,a,hx); %hipx, m 
hy=0.001*s(:,42); hy=hy(~isnan(hy));hy = filtfilt(b,a,hy); %hipy, m
kx=0.001*s(:,64); kx=kx(~isnan(kx));kx = filtfilt(b,a,kx); %kneex, m 
ky=0.001*s(:,66); ky=ky(~isnan(ky));ky = filtfilt(b,a,ky); %kneey, m
ax=0.001*s(:,133); ax=ax(~isnan(ax));ax = filtfilt(b,a,ax); %anklex, m 
ay=0.001*s(:,135); ay=ay(~isnan(ay));ay = filtfilt(b,a,ay); %ankley, m

hk=[kx-hx,ky-hy];
ka=[ax-kx,ay-ky];
% calculating knee angle
for i=1:n
    teta_k(i)=acosd(dot(hk(i,:),ka(i,:))/(norm(hk(i,:)*norm(ka(i,:)))));
end 
figure; plot(t,teta_k);title('knee angle');
% finding local minima to spot trials
TF = islocalmin(teta_k);    
loct=t(TF);
locd=teta_k(TF);
