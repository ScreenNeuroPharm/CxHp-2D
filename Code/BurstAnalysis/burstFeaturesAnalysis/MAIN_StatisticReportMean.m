% MAIN_StatisticsReportMean.m
% by Michela Chiappalone (12 Aprile 2006)
% Probably it needs to be updated on the basis of the other scripts on
% burst detection, already changed
% modified by Luca Leonardo Bologna
%   - in order to handle the 64 channels of MED64 Panasonic System
% changed - not able to manage the 64 channel of MED Panasonic system

[start_folder]= selectfolder('Select the BurstDetectionFiles folder');
if strcmp(num2str(start_folder),'0')
    errordlg('Selection Failed - End of Session', 'Error');
    return
end

% -----------> INPUT FROM THE USER & VARIABLES
[exp_num]=find_expnum(start_folder, '_BurstDetectionFiles'); % Experiment number
first=3;
burstingch=0;
burstingchs=[];

% -----------> FOLDER MANAGEMENT
cd (start_folder);
cd ..
% burst_folder=pwd;
cd ..
exp_folder=pwd;
[end_folder]=createresultfolder(exp_folder, exp_num, 'BurstAnalysis');
[end_folder1]=createresultfolder(end_folder, exp_num, 'MeanStatReportBURST');
[end_folder2]=createresultfolder(end_folder, exp_num, 'MeanStatReportSPIKEinBURST');
[end_folder3]= createresultfolder(end_folder, exp_num, 'StatisticsReportMAT');
[end_folder4]= createresultfolder(end_folder, exp_num, 'StatisticsReportTXT');
clear burstfoldername expfolder

% --------------> COMPUTATION PHASE: Create Statistics Report
cd (start_folder)
content= dir;
NumFiles= length(content);
for i=first:NumFiles
    filename = content(i).name;
    load (filename); % burst_detection_cell [cell_array] is loaded
    
    % changed by Michela Chiappalone
%     if length(burst_detection_cell)==87 %added for compatibility with previous versions
%         burst_detection_cell(end+1)=[];
%     end
    
    fullburst_array=cell(1,15);
    burstingch=0;
    SRMburst=[];
    SRMspike=[];

    for k=1:length(burst_detection_cell)
        burst_detection=burst_detection_cell{k,1};

        if ~isempty(burst_detection_cell{k,1})
            acq_time=burst_detection(end,1); % Acquisition time [sec]

            % Burst Features
            burstingch=burstingch+1;
            totalbursts= burst_detection(end,3);            % total # of bursts
            spikesxburst=  burst_detection(1:end-1,3);      % # of spikes in burst
            burstduration= burst_detection(1:end-1,4)*1000; % Burst Duration[msec]
            ibi= burst_detection(1:end-2,5); 
            bp= burst_detection(1:end-2,6);                 % BP burst period: start-to-start [sec]
            ave_mfob= burst_detection(end,6);               % Mean frequency outside the burst [Hz]% IBI start-to-start [sec]
            mbr= burst_detection(end,5);                    % mbr [#bursts/min]

            % Spike Features
            totalspikes= burst_detection(end,2);            % total # of spikes
            mfr= totalspikes/acq_time;                      % mfr [#spikes/sec]
            totalburstspikes= burst_detection(end,4);       % total # of intra-burst spikes
            percrandomspikes= ((totalspikes-totalburstspikes)/totalspikes)*100; % Percentage of random spikes
            mfb=(spikesxburst./burstduration)*1000;         % mfb = mean freq intraburst [#spikes/sec]
            pfb= max(mfb);                                  % peak frequency intra burst

            
             % Fill in the fullburst_array cellarray
            fullburst_array{1,1}= [fullburst_array{1,1}; acq_time];              % in general, single element
            fullburst_array{1,2}= [fullburst_array{1,2}; k*ones(totalbursts,1)]; % array
            fullburst_array{1,3}= [fullburst_array{1,3}; totalbursts];           % single element
            fullburst_array{1,4}= [fullburst_array{1,4}; spikesxburst];          % array
            fullburst_array{1,5}= [fullburst_array{1,5}; burstduration];         % array
            fullburst_array{1,6}= [fullburst_array{1,6}; ibi];                   % array
            fullburst_array{1,7}= [fullburst_array{1,7}; bp];                    % array
            fullburst_array{1,8}= [fullburst_array{1,8}; ave_mfob];              % single element
            fullburst_array{1,9}= [fullburst_array{1,9}; mbr];                   % single element

            fullburst_array{1,10}= [fullburst_array{1,10}; mfr];                 % single element
            fullburst_array{1,11}= [fullburst_array{1,11}; totalspikes];         % single element
            fullburst_array{1,12}= [fullburst_array{1,12}; totalburstspikes];    % single element
            fullburst_array{1,13}= [fullburst_array{1,13}; percrandomspikes];    % single element
            fullburst_array{1,14}= [fullburst_array{1,14}; mfb];                 % array
            fullburst_array{1,15}= [fullburst_array{1,15}; pfb];                 % single element
            
            
            % Fill in the StatReportMean arrays
                lastrow= [k, acq_time, mbr, totalbursts, ...
                mean(spikesxburst), std(spikesxburst),...
                mean(burstduration), std(burstduration),...
                mean(ibi), std(ibi)];
                SRMburst=[SRMburst; lastrow];
                clear lastrow

                lastrow=  [k, acq_time, totalspikes, totalburstspikes, percrandomspikes, ...
                pfb, mean(mfb), stderror(mean(mfb), mfb)];
                SRMspike= [SRMspike; lastrow];
                clear lastrow
        end
    end
    burstingchs=[burstingchs; burstingch];

    % Mean Stat Report MAT and TXT - Burst
    cd (end_folder1)
    nome=strcat('MStReportB', filename(16:end));
    save(nome, 'SRMburst')
    clear nome
    nome=strcat('MStReportB', filename(16:end-4), '.txt');
    save(nome, 'SRMburst', '-ASCII')
    clear nome

    % Mean Stat Report MAT and TXT - Spikes
    cd (end_folder2)
    nome=strcat('MStReportSpinB', filename(16:end));
    save(nome, 'SRMspike')
    clear nome
    nome=strcat('MStReportSpinB', filename(16:end-4), '.txt');
    save(nome, 'SRMspike', '-ASCII')
    clear nome

     cd (end_folder3)
    % Stat Report MAT
    nome=strcat('StatReport', filename(16:end));
    save(nome, 'fullburst_array', 'burstingch', 'acq_time')
    clear nome

    cd (end_folder4)
    % Stat Report TXT Bursting channel List
    nome=strcat('BurstChList', filename(16:end-4), '.txt');
    temp= fullburst_array{1,2};
    save(nome, 'temp', '-ASCII')
    clear nome temp

    % Stat Report TXT Burst Number
    nome=strcat('BurstNumber', filename(16:end-4), '.txt');
    temp= fullburst_array{1,3};
    save(nome, 'temp', '-ASCII')
    clear nome temp

    % Stat Report TXT spikesxburst
    nome=strcat('SpikexBurst', filename(16:end-4), '.txt');
    temp= fullburst_array{1,4};
    save(nome, 'temp', '-ASCII')
    clear nome temp

    % Stat Report TXT Burst Duration
    nome=strcat('BurstDuration', filename(16:end-4), '.txt');
    temp= fullburst_array{1,5};
    save(nome, 'temp', '-ASCII')
    clear nome temp

    % Stat Report TXT IBI
    nome=strcat('IBI', filename(16:end-4), '.txt');
    temp= fullburst_array{1,6};
    save(nome, 'temp', '-ASCII')
    clear nome temp

    % Stat Report TXT BP
    nome=strcat('BP', filename(16:end-4), '.txt');
    temp= fullburst_array{1,7};
    save(nome, 'temp', '-ASCII')
    clear nome temp

    % Stat Report TXT AVE_MFOB
    nome=strcat('AvMFOB', filename(16:end-4), '.txt');
    temp= fullburst_array{1,8};
    save(nome, 'temp', '-ASCII')
    clear nome temp

    % Stat Report TXT MBR
    nome=strcat('MBR', filename(16:end-4), '.txt');
    temp= fullburst_array{1,9};
    save(nome, 'temp', '-ASCII')
    clear nome temp

    % Stat Report TXT Percentage
    nome=strcat('Percrndspikes', filename(16:end-4), '.txt');
    temp= fullburst_array{1,13};
    save(nome, 'temp', '-ASCII')
    clear nome temp

    % Stat Report TXT MeanFreq in Burst
    nome=strcat('MfreqinBurst', filename(16:end-4), '.txt');
    temp= fullburst_array{1,14};
    save(nome, 'temp', '-ASCII')
    clear nome temp

    % Stat Report TXT Percentage
    nome=strcat('PfreqinBurst', filename(16:end-4), '.txt');
    temp= fullburst_array{1,15};
    save(nome, 'temp', '-ASCII')
    clear nome temp
    
    cd (start_folder)
end

%burstingchs=(burstingchs/60)*100;

cd (end_folder1)
nome=strcat(exp_num, '_BurstingChannels.txt');
save(nome, 'burstingchs', '-ASCII')

EndOfProcessing (start_folder, 'Successfully accomplished');
clear all
