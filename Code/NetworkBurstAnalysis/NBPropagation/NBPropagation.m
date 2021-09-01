%% Network Burst Propagation
clear all
clc

% Load file to compute the NB propagation
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
        check = strsplit(col);
        merge = find(~cellfun(@isempty,totcolor));
        used_color = {check{merge}};
        used_color(find(contains(used_color,'gray')))=[];
        
        %Choose the reference compartment to compute LNBindex
        [indx,tf] = listdlg('PromptString',{'Choose the reference compartment',...
        'Only one color can be selected at a time.',''},...
        'SelectionMode','single','ListString',used_color);
    
        ref_color = used_color{indx};
        ref_elec = eval(ref_color);
        
        % Define the electrode coordinate
        [xy,conf] = coordinate(color);
        
        % Compute the MBL 
        thesh = 0.06*length(netBurstsPattern);     % MBL: channels leading at least 6% of the total number of detected NBs 
        for i = 1:length(netBurstsPattern)
            el(i) = netBurstsPattern{i}(1,1);
        end
        el(el==15) = [];
        edges = unique(sort(el));
        counts = histc(sort(el(:)), edges);
        MBL_figure = figure
        bar(edges,counts)
        hold on
        plot(1:length(color),ones(length(color),1)*thesh,'.-r');
        xlabel('Electrodes');
        ylabel('# Occurrence');
        title ('MBL');
        box off
        MBL = edges(counts > thesh);
        LNBI = length(intersect(MBL,ref_elec))/length(MBL);
               
        
        % Save parameters
        id = strfind(pathname,'\');
        endfolder = [pathname(1:id(end-2)), pathname(id(end-3)+1:id(end-2)-1), '_NBPropagationAnalysis'];
        mkdir(endfolder);
        filename = [pathname(id(end-3)+1:id(end-2)-1), '_MBL'];
        save(fullfile(endfolder,filename),'MBL');
        figname = [pathname(id(end-3)+1:id(end-2)-1), '_MBLfigure'];
        savefig(MBL_figure, fullfile(endfolder,figname));
        close(MBL_figure);
        filename = strcat(pathname(id(end-3)+1:id(end-2)-1), '_LNBI_CompReference_', string(ref_color)); %Leader Network Burst Index
        save(fullfile(endfolder,filename),'LNBI');
        
        % Compute the propagation map with MBL as reference and the
        % velocity
        
        fs = 10000;
        dd = distanceMEA(xy(:,1), xy(:,2), xy(:,3), conf);
        delay = [];
        Parameters = [];
        R2 = [];
        
        for j = 1:length(MBL)
            delay_mean_i = [];
            for i = 1:length(netBurstsPattern)
                if netBurstsPattern{i}(1,1) == MBL(j)
                    delay_i = [(netBurstsPattern{i}(2:end,2)-netBurstsPattern{i}(1,2))./fs netBurstsPattern{i}(2:end,1)];
                    delay = [delay; delay_i];
                end
            end
            
            delay = sortrows(delay,2);
            el_involved = unique(delay(:,2));
            for i = 1:length(el_involved)
                delay_mean_i = [delay_mean_i; mean(delay(delay(:,2) == el_involved(i),1))*1000 el_involved(i)];
            end 
            delay_mean_i(delay_mean_i(:,2)==15,:) = [];
            delay_mean_i(delay_mean_i(:,2)==MBL(j),:) = [];
            delay_tot{j} = delay_mean_i; % in ms
            latency = delay_mean_i(:,1);
            distance = dd(MBL(j),delay_mean_i(:,2));
            followers = delay_mean_i(:,2);
            distance = distance';
            latency_distance{j}= table(latency,distance,followers);

            velocity = figure;
            scatter(latency,distance,'filled','o');
            [P,S] = polyfit(latency,distance,1);
            yfit = P(1)*latency+P(2);
            Parameters = [Parameters; P];
            R = 1 - (S.normr/norm(distance - mean(distance)))^2;
            R2 = [R2; R];
            hold on;
            plot(latency,yfit,'k');
            xlabel('Latency [msec]');
            ylabel('Distance [mm]')
            filename = strcat(pathname(id(end-3)+1:id(end-2)-1), '_VelocityFitting_Ref', string(MBL(j)));
            save(fullfile(endfolder,filename),'P');
            figname = strcat(pathname(id(end-3)+1:id(end-2)-1), '_VelocityFittingFigure_Ref', string(MBL(j)));
            savefig(velocity, fullfile(endfolder,figname));
            close(velocity);
            
            % Create the spatial latency matrix
            PropagationMap = figure
            scatter(xy(:,1),xy(:,2),15,'filled','k');
            hold on
            for i = 1:length(delay_mean_i)
                x = xy(xy(:,3)==delay_mean_i(i,2),1);
                y = xy(xy(:,3)==delay_mean_i(i,2),2);
                size = delay_mean_i(i,1)*2;  
                scatter(x,y,size,delay_mean_i(i,1),'filled');
            end
            colormap hot
            c=colorbar;
            c.Label.String = 'Latency (msec)';
            c.Limits = [min(delay_mean_i(:,1)) max(delay_mean_i(:,1))]
            caxis([0 max(delay_mean_i(:,1))])
            axis off
            xticks([10 20 30 40 50 60 70 80 90])
            x_ref = xy(xy(:,3)==MBL(j),1);
            y_ref = xy(xy(:,3)==MBL(j),2);
            scatter(x_ref,y_ref,400,'filled','k');
            figname = strcat(pathname(id(end-3)+1:id(end-2)-1),'_PropagationMaps_Ref', string(MBL(j)));
            savefig(PropagationMap, fullfile(endfolder,figname));
            close(PropagationMap);
        end
        % Total velocity of the matrix 
        tot = [];
        for j = 1:length(latency_distance)
            tot = [tot; latency_distance{j}];
        end
        
        Parameters = Parameters.*1000;  %% mm/s
        P = table(Parameters,R2);
        filename = strcat(pathname(id(end-3)+1:id(end-2)-1), '_VelocityFitting_Total');
        save(fullfile(endfolder,filename),'P');
           
        % save Latency for each MBL
        filename = [pathname(id(end-3)+1:id(end-2)-1), '_Latency[msec]'];
        save(fullfile(endfolder,filename),'delay_tot');
        filename = [pathname(id(end-3)+1:id(end-2)-1), '_DistanceLatency'];
        save(fullfile(endfolder,filename),'latency_distance');
   end
end




 



