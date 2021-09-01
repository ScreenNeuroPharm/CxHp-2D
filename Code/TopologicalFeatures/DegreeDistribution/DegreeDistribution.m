%% Degree Distribution
clear all
clc

start_folder = uigetdir(pwd, 'Select folder with all the binary TCC matrix');
cd(start_folder);
d = dir;

for k = 3:length(d) % Cicle on experimental configuration
    %cd(d(k).name);
    dir_matrix = dir;
    in = [];
    out = [];
    tot = [];
    
    for j = 3:length(dir_matrix)% Cicle on different matrix
        load(dir_matrix(j).name);
        [i,o,t] = degrees_dir(CC_bin);
        in = [in i];
        out = [out o];
        tot = [tot, t];        
    end
%     tot = tot./sum(tot);
    tot = tot(tot>1);
    in = in(in>1);
    hist_tot = histogram(tot, ceil(max(tot)));
    y = hist_tot.Values;
    y = y./sum(y);
    x = 1:length(y);
    func = fittype('Power1'); % Function to fit
%     opt = fitoptions('Method','NonlinearLeastSquares','Startpoint',[-100 0 8],'Lower',[0 -Inf 0],'Upper',[Inf Inf Inf]); % Fit options
    [F,G] = fit(x',y',func); % Fitting
    fitR = G.adjrsquare; % Fit goodness
    f = F.a.*x.^(F.b);
    DD = figure;
    loglog(x,y,'*k');
    hold on
    loglog(x,f,'r','LineWidth',1); 
    xlim([0 max(tot)])
    box off
    ylabel('ln(p(Degree))');
    xlabel('ln(Degree)');
%     ylim([0.1 max(y)])
    namefig = 'DegreeDistribution';
    savefig(DD, namefig);
    namefile = 'DegreeDistribution_Parameters';
    save(namefile, 'F', 'fitR');
    namefile = 'DegreeDistribution_Vectors';
    save(namefile, 'x', 'y','f');
    cd ..
    close all
end

        