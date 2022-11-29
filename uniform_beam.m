figure('visible','on')

% The pic prime is the ideal OAM beam that we have
pic_prime = imread("OAM+1_all0_normalized.bmp");

region_count = zeros(1,36);
region_average_prime = zeros(36,1,3);

center = [size(pic_prime, 2)/2 + 0.001, size(pic_prime, 1)/2];

gray_pixel = double(pagetranspose(pic_prime(1, 1, :)));

for index_i=1:1:size(pic_prime,1)
    for index_j=1:1:size(pic_prime,2)

        if gray_pixel == double(pagetranspose(pic_prime(index_i, index_j, :)))
            continue;
        end

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

        region_count(curr_index) = region_count(curr_index) + 1;

    end
end

difference = zeros(36,1,3);

corner_pix = double(pagetranspose(pic_prime(200, 20, :)));

for index_i = 1:1:36

    for remaining_pixels = 1:1:(max(region_count) - region_count(index_i))
        region_average_prime(index_i, :, :) = region_average_prime(index_i, :, :) + corner_pix;
    end

    region_average_prime(index_i, :, :) = region_average_prime(index_i, :, :)./max(region_count); 
end



% Brighter then we increase the voltage (more red)
% If its dimmer then we descrease the voltage (more blue)

total_average = sum(region_average_prime)/36;

greatest_diff = 0;
greatest_actual_diff = 0;
section = 0;
real_diff = 0;

list_differences = [];
list_sections = [];

for index_i = 1:1:36
    diff = 0;
    diff2 = 0;
    for index_j = 1:1:3
        diff = diff + abs(region_average_prime(index_i, :, index_j) - total_average(index_j));
        diff2 = diff2 + region_average_prime(index_i, :, index_j) - total_average(index_j);
    end

    if diff > greatest_diff
        greatest_diff = diff;
        section = index_i;
        real_diff = diff2;
    end

    % What we need to do is create an algorithm that provides us with a
    % list of the highest differences. For fun, we are going to do the
    % insertion in log(n) time. 
    index = floor(size(list_sections, 2)/2);
    verdict = false;
    count = 1;
    while (verdict == false)
        if (size(list_sections, 2) == 0)
            index = 1;
        end
        left = -1;
        right = 9999999;
        if (index - 1 ~= 0)
            left = abs(list_differences(index - 1));
        end

        if (index + 1 >  size(list_sections, 2))
            right = abs(list_differences(index + 1));
        end

        curr = abs(list_differences(index));

        if curr < left
            count = count + 1;
            index = index; %find the next index;
        end
    end
    list_differences = [list_differences(1:index) diff2 list_differences(index + 1:end)];
    list_sections = [list_sections(1:index) index_i list_sections(index + 1:end)];
    % End of random sorting algorithm


end

36 - section + 1
real_diff

% Negative then we increase the voltage, and if positive then we decrease

imshow(pic_prime)

% The best way to create this is to not leverage the difference. WE want to
% find the average of all the regions from BOTH the pictures. Then what we
% could do is find the difference between each of the colors per each
% region. Based off that, then we can determine the largest difference, and
% then we can take the total of both and see if its greater or smaller. If
% greater then we know its brighter, if its lower then its dimmer






























