function [MEA120] = MEA120_lookuptable()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    clear all
    clc
    MEA120 = string(ones(120,2));
    letter = 'A':'M';
    letter(letter=='I')=[];
    count = 1;
    
    for i = 1:length(letter)
        if letter(i) == 'A' | letter(i) == 'M'
            for k = 4:9
                MEA120(count,1) = strcat(letter(i),'0',char(string(k)));
                count = count+1;
            end
        elseif letter(i) == 'B' | letter(i) == 'L'
            for k = 3:10
                if k == 10 
                    MEA120(count,1) = strcat(letter(i),char(string(k)));
                else
                    MEA120(count,1) = strcat(letter(i),'0',char(string(k)));
                end
                count = count+1;
            end
        elseif letter(i) == 'C' | letter(i) == 'K'
             for k = 2:11
                 if k > 9
                    MEA120(count,1) = strcat(letter(i),char(string(k)));
                 else
                    MEA120(count,1) = strcat(letter(i),'0',char(string(k)));
                 end
                 count = count+1;
             end
        else 
            for k = 1:12
                if k >9
                    MEA120(count,1) = strcat(letter(i),char(string(k)));
                else
                    MEA120(count,1) = strcat(letter(i),'0',char(string(k)));
                end
                count = count+1;
            end
        end
    end
    
    mcs = [41;37;33;29;25;21;45;42;38;34;28;24;20;17;47;46;43;39;35;27;23; ...
        19;16;15;51;50;49;44;40;36;26;22;14;13;12;11;55;54;53;52;48;32;30; ...
        18;10;9;8;7;59;58;57;56;60;31;1;2;6;5;4;3;63;64;65;66;62;61;91;120; ...
        116;117;118;119;67;68;69;70;78;90;92;108;112;113;114;115;71;72;73;...
        74;82;86;96;100;104;109;110;111;75;76;79;83;87;95;99;103;106;107; ...
        77;80;84;88;94;98;102;105;81;85;89;93;97;101];
    MEA120(:,2)=mcs;
    
            


