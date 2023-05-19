%% If you want all zeros use this
%curr_values = zeros(1,36);

%% If you want to import the values for OAM+1
%curr_values = readmatrix("OAM+1.csv");

%% If you want to import the values for OAM+1
%curr_values = readmatrix("OAM+2.csv");

%% If you want to import the values for OAM+1
%curr_values = readmatrix("OAM-1.csv");

%% If you want to import the values for OAM+1
curr_values = readmatrix("OAM-2.csv");

writematrix(curr_values,"beam_values.csv")