function [xy, conf] = coordinate(color)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
if length(color) == 87 
        answer = questdlg('Choose the used layout', ...
        'Layout', '60MEA','4QMEA','4QMEA');
        % Handle response
        switch answer
            case '60MEA'
                conf = '60MEA';
                % To complete
            case '4QMEA'
                conf = '4QMEA';
                c = [1 3 5 10 15 17 19];
                r = [1:2:9 12:2:16 19:2:27];
                xy = [];
                for i = 1:length(c)
                    for k = 1:length(r)
                        xy = [xy; c(i) r(k)];
                    end
                end

                count = 1;
                tmp = [];
                for i = 1:length(xy)
                    if xy(i,1)~=10 & (xy(i,2)== 12 | xy(i,2)== 14 | xy(i,2)== 16) 
                    elseif (xy(i,1)== 1  | xy(i,1) == c(end)) & (xy(i,2)==1 | xy(i,2)== r(end))
                    elseif (xy(i,1)== 5  | xy(i,1) == 15) & (xy(i,2)==9 | xy(i,2)== 19)
                    elseif xy(i,1)== 10  & (xy(i,2) == 1 | (xy(i,2)==3 | xy(i,2)== 9 | xy(i,2)== 19 | xy(i,2)== 25 | xy(i,2)== 27))
                    else
                        tmp(count,:) = xy(i,:);
                        count = count+1;
                    end
                end
                xy = tmp;
                index2 = [36 17 16 25 24 13 12 33 37 28 27 26 35 34 23 22 21 32 38 ...
                    45 46 48 41 43 44 31 47 57 85 14 84 42 52 68 55 56 58 51 53 54 ...
                    61 67 78 77 76 65 64 73 72 71 62 66 87 86 75 74 83 82 63]';
            end
    elseif length(color)== 120
        conf = '120MEA';
        l = sqrt(length(color));
        l = ceil(l)+1;
        col1 = ones(l,1);
        col2 = [1:l]';
        xy = [];
        for i = 1:l
            xy = [xy;col1*i,col2];
        end

        %layout multichannel
        xy(142:144,:) = [];
        xy(131:135,:) = [];
        xy(120:122,:) = [];
        xy(109,:) = [];
        xy(36,:) = [];
        xy(25,:) = [];
        xy(23:24,:) = [];
        xy(13:14,:) = [];
        xy(10:12,:) = [];
        xy(1:3,:) = [];

        index2 = [21;25;29;33;37;41;17;20;24;28;34;38;42;45;15;16;19;23;27;35;39;43;46;47;11;...
                12;13;14;22;26;36;40;44;49;50;51;7;8;9;10;18;30;32;48;52;53;54;55;3;4;5;6;2;1;31;...
                60;56;57;58;59;119;118;117;116;120;91;61;62;66;65;64;63;115;114;113;112;108;92;90;...
                78;70;69;68;67;111;110;109;104;100;96;86;82;74;73;72;71;107;106;103;99;95;87;83;79; ...
                76;75;105;102;98;94;88;84;80;77;101;97;93;89;85;81];
    end
    xy = [xy,index2];
end

