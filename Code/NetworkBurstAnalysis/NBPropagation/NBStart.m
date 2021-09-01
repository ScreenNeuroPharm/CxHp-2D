%% Burst Network Starting
clear all
clc

% Load file to compute BNL index and to identify the compartments
[filename, pathname] = uigetfile({'*.mat'},'Select NetworkBurstDetectionFile with all electrodes');
if isequal(filename,0)
    return
else
    col = ['gray ' 'green ' 'red ' 'cyan ' 'yellow ' 'violet ' 'blue '];
    str_comp = intersect(strsplit(col),lower(strsplit(filename,{'_','.'})));
    if ~isempty(str_comp)
        errordlg('Select the NetworkBurstDetectionFile with all electrodes - End of Session', 'Error');
        return
    else
        cd(pathname);
        load(fullfile(pathname,filename));        
        [colorfile, colorpath] = uigetfile({'*.mat'},'Select ColorElectrode file');
        if isequal(filename,0)
            return
        else
            if strcmp(colorfile,'ColorElectrode.mat')
                load(fullfile(colorpath,colorfile));
            else
                errordlg('Select the ColorElectrode file - End of Session', 'Error');
                return
            end
        end
        
        % Split compartment in the function of the assegned color
        blue = find(color(:,1) == 0 & color(:,2) == 0 & color(:,3)==1);
        yellow = find(color(:,1) == 1 & color(:,2) == 1 & color(:,3)==0);
        green = find(color(:,1) == 0 & color(:,2) == 1 & color(:,3)==0);
        cyan = find(color(:,1) == 0 & color(:,2) == 1 & color(:,3)==1);
        gray = find(color(:,1) == 0.8 & color(:,2) == 0.8 & color(:,3)==0.8);
        violet = find(color(:,1) == 1 & color(:,2) == 0 & color(:,3)==1);
        red = find(color(:,1) == 1 & color(:,2) == 0 & color(:,3)==0);
        totcolor = [{gray}, {green}, {red}, {cyan}, {yellow}, {violet}, {blue}];
        
        nElc = sum(length([blue; yellow; green; cyan; violet; red]));
        check = strsplit(col);
        merge = find(~cellfun(@isempty,totcolor));
        used_color = {check{merge}};
        used_color(find(contains(used_color,'gray')))=[]; 
        str = string(used_color);
        
%         tot = zeros(1,length(used_color));
        for i = 1:length(netBurstsPattern)
            el(i) = netBurstsPattern{i}(1,1);
%             for k = 1:length(used_color)
%                 if ismember(el,eval(used_color{k}))
%                     tot(k)= tot(k)+1;
%                 end
%             end
        end
        el = unique(el);
        el(el==15) = [];
        el(find(ismember(el,gray))) = [];
        el_tot = length(el);
        tot = table;
        
        for k = 1:length(used_color)
            tot.k = sum(ismember(el, eval(used_color{k})))./el_tot;
            tot.Properties.VariableNames(k) = used_color(k);
        end
            
%         tot = tot./sum(tot);
        
%         total = table;
%         for i = 1:length(el)
%             total.i = tot(i);
%             total.Properties.VariableNames(i) = used_color(i);
%         end
        
        id = strfind(colorpath,'\');
        endfolder = [colorpath(1:id(end-1)), colorpath(id(end-2)+1:id(end-1)-1), '_NBPropagationAnalysis'];
        mkdir(endfolder);
        filename = [colorpath(id(end-2)+1:id(end-1)-1), '_LeaderElec'];
        save(fullfile(endfolder,filename), 'tot');
    end
end

        