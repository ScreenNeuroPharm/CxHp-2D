%% SpikeTrain
start_folder = uigetdir(pwd, 'Select PeakDetectionMAT folder [single phase]');
cd(start_folder);
d = dir;


if length(d)-2 == 120
    mea = MEA120_lookuptable;
    delay = zeros(120);
    similarity = zeros(120);
end
for k = 3:length(d)-1
    load(d(k).name);
    elx = split(d(k).name,'.');
    elx = elx{1}(end-2:end);
    elx_num = double(mea(strcmp(mea(:,1),elx),2));
    if length(find(peak_train))/(length(peak_train)/10000) > 0.1
        x_peak = peak_train;
        x_peak = find(peak_train)./10000;
        x_peak = x_peak(2:end);

        for j = k:length(d)
            load(d(j).name);
            ely = split(d(j).name,'.');
            ely = ely{1}(end-2:end);
            ely_num = double(mea(strcmp(mea(:,1),ely),2));
            
            if length(find(peak_train))/(length(peak_train)/10000) > 0.1
                y_peak = peak_train;
                y_peak = find(peak_train)./10000;
                y_peak = y_peak(2:end);

                [s,de] = Event_Sync(x_peak, y_peak);
                delay (elx_num,ely_num) = de;
                delay(ely_num,elx_num) = -de;
                similarity (elx_num,ely_num) = s;
                similarity (ely_num,elx_num) = s;
            end
        end
    end
end
cd ..
cd .. 
sinchronization = similarity;
idfold = strfind(start_folder,'\');
id2 = strfind(start_folder,'_');
namefolder = [start_folder(1:idfold(end-1)),start_folder(idfold(end-1)+1:id2(4)),'SinchronizationSpike'];
mkdir(namefolder);
cd (namefolder);
save('SincrhonizationSpike','sinchronization');
save('Delay','delay');


%% BurstSynchronization
% [file_name, start_folder] = uigetfile(pwd,'Select burst_detection file [single phase]');
% load(fullfile(start_folder,file_name));
% if length(burst_detection_cell)==120
%      delay = zeros(120);
%      similarity = zeros(120);
% end
% 
% for k = 1:length(burst_detection_cell)-1
%     if ~isempty(burst_detection_cell{k})
%         elx_num = k;
%         x_burst = burst_detection_cell{k}(2:end-1,1)./10000;
%         for j = k:length(burst_detection_cell)
%            if ~isempty(burst_detection_cell{j}) 
%                ely_num = j;
%                y_burst = burst_detection_cell{j}(2:end-1,1)./10000;
%                
%                [s,de] = Event_Sync(x_burst, y_burst);
%                 delay (elx_num,ely_num) = de;
%                 delay(ely_num,elx_num) = -de;
%                 similarity (elx_num,ely_num) = s;
%                 similarity (ely_num,elx_num) = s;
%              end
%         end
%     end
% end
% cd ..                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
% cd .. 
% cd ..
% sinchronizationBurst = similarity;
% idfold = strfind(start_folder,'\');
% id2 = strfind(start_folder,'_');
% namefolder = [start_folder(1:idfold(end-2)),start_folder(idfold(end-1)+1:id2(6)),'SinchronizationSpike'];
% mkdir(namefolder);
% cd (namefolder);
% save('SincrhonizationBurst','sinchronizationBurst');
% save('DelayBurst','delay');


%% NetworkBurst Synchronization
% [start_folder] = uigetdir(pwd,'Select networkBurst folder');
% cd(start_folder);
% d = dir;
% for k = 3:length(d)-1
%     load(d(k).name);
%     if k == 3
%         cyan = netBursts(2:end,1)./10000;
%     elseif k == 4
%         green = netBursts(2:end,1)./10000;
%     else
%         red = netBursts(2:end,1)./10000;
%     end
% end
% 
% [S_CyanGreen d_CyanGreen] =  Event_Sync(cyan, green);
%   
% [S_CyanRed d_CyanRed] =  Event_Sync(cyan, red);
% 
% [S_GreenRed d_GreenRed] =  Event_Sync(green, red);
% 
% 
% SynchronizationNB = table(S_CyanGreen, S_CyanRed, S_GreenRed);
% DelayNB = table(d_CyanGreen, d_CyanRed, d_GreenRed);
% 
% cd ..                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
% cd .. 
% 
% idfold = strfind(start_folder,'\');
% id2 = strfind(start_folder,'_');
% namefolder = [start_folder(1:idfold(end-1)),start_folder(idfold(end-1)+1:id2(4)),'SinchronizationSpike'];
% mkdir(namefolder);
% cd (namefolder);
% save('SincrhonizationNB','SynchronizationNB');
% save('DelayNB','DelayNB');
