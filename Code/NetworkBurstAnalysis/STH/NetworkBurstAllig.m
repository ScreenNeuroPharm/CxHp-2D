%% MAIN function to generate the Spike Time Histogram, STH (Figure 9)
clear all
clc

[filename, pathname, filterindex] = uigetfile('*.mat', 'Select NetworkBurst file');
if isempty(strfind(filename,'NetworkBurstDetection'))
    errordlg('Selection Failed - End of Session', 'Error');
    return
end
cd(pathname);
load(filename);
onset = netBursts(:,1);
offset = netBursts(:,2);

start_folder = uigetdir(pwd,'Select the PeakDetectionMAT_Split_Joint folder');
cd(start_folder);
d = dir;
files = d;

peak = [];
for j = 3:length(files)
    load(files(j).name);
    pp = find(peak_train~=0)/10000;
    peak = [peak; pp];
end
peak = sort(peak);
edges = unique(peak);
counts = histc(peak(:), edges);
peak_new = [edges,counts];



%% Allignment
answ = 0; % Initialising variable
% Burst alignment for maximal correlation
while answ == 0 % Until correlation of aligned bursts is sufficiently high
    bursts(:,1) = netBursts(:,1)/10000;
    m = max(netBursts(:,4));
    bursts(:,2) = (netBursts(:,1)+m)/10000;

    t1 = 0.2;
    bin = 0.001;
    time_profile = -t1:bin:(m/10000)-bin;


    for k = 1:size(bursts,1)
        t1_bursts=bursts(k,1)-t1;
        t2_bursts=bursts(k,1)+m/10000;
        spk = peak_new(peak_new(:,1)>=t1_bursts & peak_new(:,1)< t2_bursts,1);
        bursts_profile(k,:) = (histc(spk,t1_bursts:bin:t2_bursts)/(length(d)-2)/bin)';
        t_bursts(k,:)=t1_bursts:bin:t2_bursts;
    end

    bursts_profile(:,end) = [];

    
    
    norm_burst_profile = bursts_profile/max(bursts_profile(:)); % Normalise
    ref_burst_ind = randi(size(bursts_profile,1),1); % Random index
    ref_burstprof_norm = norm_burst_profile(ref_burst_ind,:); % Take a random burst as reference
    R_before = nan(size(norm_burst_profile,1),1); 
    R_after = R_before; 
    shift = R_before; % Initialising variables
    shifted_burstprof = nan(size(bursts_profile)); 
    shifted_burstprof_norm = shifted_burstprof; % Initialising variables
    for i = 1:size(norm_burst_profile,1) % Alignment for each burst
        burstprof_norm = norm_burst_profile(i,:); % Normalised burst
        burstprof = bursts_profile(i,:); % Burst
        tmp = corrcoef(ref_burstprof_norm,burstprof_norm); % Calculating correlation
        R_before(i) = tmp(2,1); % Degree of correlation before alignment
        shift(i) = finddelay(ref_burstprof_norm,burstprof_norm); % Estimate time shift to maximise correlation
        % Shift and zero-pad second burst profile
        if shift(i) > 0
            shifted_burstprof_norm(i,:) = [burstprof_norm(shift(i)+1:end) zeros(1,abs(shift(i)))];
            shifted_burstprof(i,:) = [burstprof(shift(i)+1:end) zeros(1,abs(shift(i)))];
        else
            shifted_burstprof_norm(i,:) = [zeros(1,abs(shift(i))) burstprof_norm(1:end-(abs(shift(i))))];
            shifted_burstprof(i,:) = [zeros(1,abs(shift(i))) burstprof(1:end-(abs(shift(i))))];
        end
        tmp = corrcoef(ref_burstprof_norm,shifted_burstprof_norm(i,:)); % Calculating correlation
        R_after(i) = tmp(2,1); % Degree of correlation after alignment
    end
    
    if mean(R_after) < 0.3
        bursts_profile = [];
    else
        answ = 1; 
    end % Initial check on performance of correlation: should be at least 0.3
end

burst_profileCUM = mean(shifted_burstprof); 

BurstProfile = figure;
plot(time_profile*1000,mean(shifted_burstprof));
xlim([-100 1000])
xlabel('Time [ms]')
ylabel('[Hz]')
title('Istantaneous Firing Rate (intra-NB)')
box off

idcolor = split(filename,'_');
idcolor = idcolor{end};
id = strfind(pathname,'\');
endfolder = [pathname(1:id(end-2)), pathname(id(end-3)+1:id(end-2)-1), '_NBProfile'];
mkdir(endfolder);
BPname = [pathname(id(end-3)+1:id(end-2)-1), '_BurstProfileNorm_', idcolor(1:end-4)];
savefig(BurstProfile, fullfile(endfolder,BPname));


% Fitting burst rise phase
sr = 1/(time_profile(2)-time_profile(1)); % Sampling rate of average aligned burst profile (1/dt)
threshold = (max(burst_profileCUM)-min(burst_profileCUM))*0.85; % Setting threshold at 85% of max burst profile amplitude
[peak,loc] = findpeaks(burst_profileCUM,'minpeakdistance',5,'minpeakheight',threshold); % Finding the peak of the mean burst profile
peak = peak(1); loc = loc(1); % First peak is largest
to_fit1a = 75; % Time in ms of baseline to include for fitting
to_fit1b = 5; % Minimum amplitude required to be included for fitting (percentage of peak amplitude)
to_fit2 = 60; % (percentage of peak amplitude)
% threshold = 25*median(data(i).burst_profile{j,t}(1:100));
to_fit1b = find(burst_profileCUM-burst_profileCUM(1) > (peak-burst_profileCUM(1))*to_fit1b/1e2); % Finding part of burst profile above 5% of peak amplitude
to_fit1a = to_fit1b(1)-to_fit1a/sr*1e3; 
if to_fit1a < 1
    to_fit1a = 1; 
end % Taking 75 ms before first point reaching 5% of peak amplitude
to_fit2 = find(burst_profileCUM > peak*to_fit2/1e2); % Finding part of burst profile above 60% of peak amplitude
trace = burst_profileCUM(to_fit1a:to_fit2(1)-1); % Taking part of burst profile to fit
func = fittype('a0 * (exp( (b0-1) * x)) + a1 * (exp( (b1-1) * x)) + d'); % Function to fit
opt = fitoptions('Method','NonlinearLeastSquares','Startpoint',[0.2 0.2 1.090 1.05 2],'Lower',[1e-12 0.001 1.0001 1.0001 -10],'Upper',[10 10 2 2 50]); % Fit options
T = (0:length(trace)-1); % Time belonging to burst profile part
[F,G] = fit(T',trace',func,opt); % Fitting
if F.b0 > F.b1
    slope = F.b1;
else
    slope = F.b0; % Extracting the slope parameter
end
fitR = G.adjrsquare; % Fit goodness
fittedregion = [to_fit1a to_fit2(1)]; % Indexes of burst profile used for fitting

fitting = figure('color','w','position',[1 31 1920 973]); hold on;
time = 0:length(burst_profileCUM)-1; 
plot(time,burst_profileCUM,'k');
plot(time(fittedregion(1):fittedregion(2)),burst_profileCUM(fittedregion(1):fittedregion(2)));
plot(time(fittedregion(1):fittedregion(2)),F(1:diff(fittedregion)+1),'r','LineWidth',2); 
xlim([0 1200])

xlabel('Time [ms]')
ylabel('[Hz]')
title('Istantaneous Firing Rate (intra-NB)')
box off



% Fitting burst decay phase
[value, idmax] = max(burst_profileCUM);
to_fit1a =idmax(1);
to_fit2 = 10;
to_fit2 = find(burst_profileCUM < peak*to_fit2/1e2); 
to_fit2 = to_fit2(to_fit2>idmax);
trace = burst_profileCUM(to_fit1a:to_fit2(1)-1);
T = (0:length(trace)-1); % Time belonging to burst profile part
[D,G] = fit(T',trace','exp1'); % Fitting
Decay_slope = D.b;
Decay_fitR = G.adjrsquare; % Fit goodness
fittedregion = [to_fit1a to_fit2(1)]; % Indexes of burst profile used for fitting

fittingDecay = figure('color','w','position',[1 31 1920 973]); hold on;
time = 0:length(burst_profileCUM)-1; 
plot(time,burst_profileCUM,'k');
plot(time(fittedregion(1):fittedregion(2)),burst_profileCUM(fittedregion(1):fittedregion(2)),'color',[0.4 1 1]);
plot(time(fittedregion(1):fittedregion(2)),D(1:diff(fittedregion)+1),'b','LineWidth',2); 
xlim([0 1200])
xlabel('Time [ms]')
ylabel('(Hz)')
title('Istantaneous Firing Rate (intra-NB)')
box off


%% PSD
% tmp = reshape(shifted_burstprof_norm(:,700:end),[1,size(shifted_burstprof_norm(:,700:end),1)*size(shifted_burstprof_norm(:,700:end),2)]);
% tmp = mean(shifted_burstprof_norm);
% [val, idmax] = max(tmp);
% idmin = find(tmp < 0.05*val);
% idmin = idmin(find(idmin>idmax));
% idmin = idmin(1);
% clear psd
% tmp = tmp(:,idmax:idmin);
% [freq, psdx] = estimate_psd(detrend(tmp),1e3);
% 
% 



%% Save parameters

BurstNormName = [pathname(id(end-3)+1:id(end-2)-1), '_BurstProfile_Norm_', idcolor(1:end-4)];
save(fullfile(endfolder,BurstNormName),'shifted_burstprof_norm');
BurstName = [pathname(id(end-3)+1:id(end-2)-1), '_BurstProfile_', idcolor(1:end-4)];
save(fullfile(endfolder,BurstName),'shifted_burstprof');
% PsdName = [pathname(id(end-3)+1:id(end-2)-1), '_PSD_', idcolor(1:end-4)];
% save(fullfile(endfolder,PsdName),'psdx','freq');
FittingParametersRise = table([slope fitR]);
ParameterName = [pathname(id(end-3)+1:id(end-2)-1), '_FittingParametersRise_', idcolor(1:end-4)];
save(fullfile(endfolder,ParameterName),'FittingParametersRise');
FittingParametersDecay = table([Decay_slope Decay_fitR]);
ParameterName = [pathname(id(end-3)+1:id(end-2)-1), '_FittingParametersDecay_', idcolor(1:end-4)];
save(fullfile(endfolder,ParameterName),'FittingParametersDecay');

fitname = [pathname(id(end-3)+1:id(end-2)-1), '_BurstProfile+FittingRise_', idcolor(1:end-4)];
savefig(fitting, fullfile(endfolder,fitname));
fitname = [pathname(id(end-3)+1:id(end-2)-1), '_BurstProfile+FittingDecay_', idcolor(1:end-4)];
savefig(fittingDecay, fullfile(endfolder,fitname));
close all






