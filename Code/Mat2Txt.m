% This script converts the peak train stored in Matlab format to ascii
% files (.txt). The same directories tree are mantained. Time stamps and peak 
% amplitudes are stored. The first line, first column contains the length of the
% recordings expressed in samples
% 
%                 Paolo Massobrio - last update 7th May 2020
% 
clear all
start_folder = uigetdir(pwd, 'Select the MAIN Peak Detection folder');
out_folder = [start_folder,'_TXT'];
mkdir(out_folder);
cd(start_folder);
d = dir; % main directory del peak train
for k = 3:length(d)
    filename = d(k).name;
    load(filename);
    dur_sample = length(peak_train);
    time_stamp = find(peak_train);
    cd(out_folder);
    peak_train_new = [time_stamp, full(peak_train(time_stamp))];%time stamp; amplitude
    peak_train = [dur_sample,0;peak_train_new];
    filename_out = [filename(1:end-3),'txt'];
    save(filename_out,'peak_train','-ascii');
    cd(start_folder);
end
cd ..\..
clear all
disp('End Of Processing!');