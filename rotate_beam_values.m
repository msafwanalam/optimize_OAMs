curr_values = readmatrix("beam_values.csv");
new_vals = curr_values';
writematrix(new_vals,"updated_values.csv")