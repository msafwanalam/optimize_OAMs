%pic_prime = imread("OAM+1_all0_normalized.bmp");
pic_prime = imread("first_picture.bmp");
imshow(pic_prime)

diameter = 430;

gray_image = rgb2gray(pic_prime);

[centers,radii] = imfindcircles(pic_prime,[(diameter/2 - 30), diameter/2 + 30],'ObjectPolarity','bright', ...
    'Sensitivity',0.995)

%h = viscircles(centers,radii);
%hold on;

%imshow(pic_prime)
%h = viscircles(centers,radii);
%hold on;
%plot(centers(1), centers(2)  , 'ro', 'MarkerSize', 20);

%true_center = [size(pic_prime, 2)/2, size(pic_prime, 1)/2];
%plot(true_center(1), true_center(2)  , 'gx', 'MarkerSize', 20);


%% This is where add up all the components of the regions

region_count = zeros(1,36);
region_average_prime = zeros(36,1,3);
gray_pixel = double(pagetranspose(pic_prime(1, 1, :)));
black_pixel = gray_pixel;
black_pixel(:) = 0

for index_i=1:1:size(pic_prime,1)
    for index_j=1:1:size(pic_prime,2)

        point = [index_j, index_i];
        dist = sqrt((point(1) - centers(1))^2 + (point(2) - centers(2))^2);

        if dist >= radii    
            continue;
        end

        if gray_pixel == double(pagetranspose(pic_prime(index_i, index_j, :)))
            continue;
        end
        if black_pixel == double(pagetranspose(pic_prime(index_i, index_j, :))) 
            continue;
        end
        

        P0 = centers;
        P1 = point;                     %Point that we will move
        P2 = [size(pic_prime, 2), size(pic_prime, 1)/2]; 
        n1 = (P2 - P0) / norm(P2 - P0);  % Normalized vectors
        n2 = (P1 - P0) / norm(P1 - P0);

        angle3 = rad2deg(atan2(norm(det([n2; n1])), dot(n1, n2)));

        if (index_i < centers(2))
            angle3 = 360 - angle3;
        end

        curr_index = floor(angle3/10) + 1;

        region_average_prime(curr_index, :, :) = region_average_prime(curr_index, :, :) ...
            + double(pagetranspose(pic_prime(index_i, index_j, :)));

        region_count(curr_index) = region_count(curr_index) + 1;

    end
end

difference = zeros(36,1,3);

for index_i = 1:1:36
    region_average_prime(index_i, :, :) = region_average_prime(index_i, :, :)./region_count(index_i); 
end


total_average = sum(region_average_prime)/36;

greatest_diff = 0;
greatest_actual_diff = 0;
section = 0;
real_diff = 0;

list_differences = [];
list_sections = [];
list_real_diff = [];

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

    if (size(list_differences) == 0)
        list_sections(1) = index_i;
        list_differences(1) = diff;
        list_real_diff(1) = diff2;
    else 
        index = 1;
        while(list_differences(index) > diff & size(list_differences,2) > index)
            index = index + 1;
        end

        if(index == 1)
            list_differences = [diff list_differences];
            list_sections = [index_i list_sections];
            list_real_diff = [diff2 list_real_diff];
        else
            list_differences = [list_differences(1:index) diff list_differences(index + 1:end)];
            list_sections = [list_sections(1:index) index_i list_sections(index + 1:end)];
            list_real_diff = [list_real_diff(1:index) diff2 list_real_diff(index + 1:end)];
        end 
    end

    % What we need to do is create an algorithm that provides us with a
    % list of the highest differences. For fun, we are going to do the
    % insertion in log(n) time. 
%     index = floor(size(list_sections, 2)/2);
%     verdict = false;
%     count = 1;
%     while (verdict == false)
%         if (size(list_sections, 2) == 0)
%             index = 1;
%         end
%         left = -1;
%         right = 9999999;
%         if (index - 1 ~= 0)
%             left = abs(list_differences(index - 1));
%         end
% 
%         if (index + 1 >  size(list_sections, 2))
%             right = abs(list_differences(index + 1));
%         end
% 
%         curr = abs(list_differences(index));
% 
%         if curr < left
%             count = count + 1;
%             index = index; %find the next index;
%         end
%     end
%     list_differences = [list_differences(1:index) diff2 list_differences(index + 1:end)];
%     list_sections = [list_sections(1:index) index_i list_sections(index + 1:end)];
    % End of random sorting algorithm


end

36 - section + 1
real_diff


