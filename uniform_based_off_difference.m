figure('visible','on')

% The pic prime is the ideal OAM beam that we have
pic_prime = imread("OAM+1_3_31_2022.bmp");
pic_compare = imread("OAM+1_all0.bmp");

pic_compare = imresize(pic_compare,[size(pic_prime,1) size(pic_prime,2)]);

region_count = zeros(1,36);
region_average_prime = zeros(36,1,3);
region_average_compare = zeros(36,1,3);

center = [size(pic_prime, 2)/2 + 0.001, size(pic_prime, 1)/2];

for index_i=1:1:size(pic_prime,1)
    for index_j=1:1:size(pic_prime,2)
        P0 = center;
        P1 = [index_j, index_i]; %Point that we will move
        P2 = [size(pic_prime, 2), size(pic_prime, 1)/2]; 
        n1 = (P2 - P0) / norm(P2 - P0);  % Normalized vectors
        n2 = (P1 - P0) / norm(P1 - P0);

        angle3 = rad2deg(atan2(norm(det([n2; n1])), dot(n1, n2)));
        if (index_i < center(2))
            angle3 = 360 - angle3;
        end

        curr_index = floor(angle3/10) + 1;

        region_average_prime(curr_index, :, :) = region_average_prime(curr_index, :, :) ...
            + double(pagetranspose(pic_prime(index_i, index_j, :)));
        region_average_compare(curr_index, :, :) = region_average_compare(curr_index, :, :) ...
            + double(pagetranspose(pic_compare(index_i, index_j, :)));

        region_count(curr_index) = region_count(curr_index) + 1;

    end
end

difference = zeros(36,1,3);

for index_i = 1:1:36
    region_average_prime(index_i, :, :) = region_average_prime(index_i, :, :)./region_count(index_i);
    region_average_compare(index_i, :, :) = region_average_compare(index_i, :, :)./region_count(index_i);
    difference(index_i, :, :) = region_average_prime(index_i, :, :) - region_average_compare(index_i, :, :);
end



% Brighter then we increase the voltage (more red)
% If its dimmer then we descrease the voltage (more blue)

total_average = sum(region_average_prime)/36;

greatest_diff = 0;
real_diff = 0;
section = 0;
for index_i = 1:1:36
    diff = 0;
    diff2 = 0;
    for index_j = 1:1:3
        diff = diff + abs(difference(index_i, :, index_j));
        diff2 = diff2 + difference(index_i, :, index_j);
    end
    if diff > greatest_diff
        greatest_diff = diff;
        section = index_i;
        real_diff = diff2;
    end
end
36 - section + 1
diff2

% The best way to create this is to not leverage the difference. WE want to
% find the average of all the regions from BOTH the pictures. Then what we
% could do is find the difference between each of the colors per each
% region. Based off that, then we can determine the largest difference, and
% then we can take the total of both and see if its greater or smaller. If
% greater then we know its brighter, if its lower then its dimmer






























