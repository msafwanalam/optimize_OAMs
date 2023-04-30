%% This is where we keep track of all the values we are inputting into the beam profiler

curr_values = readmatrix("beam_values.csv");
%curr_values = zeros(1,36);

%% This is where we begin the detection
pic_prime = imread("first_picture.bmp");
imshow(pic_prime)

diameter = 430;

gray_image = rgb2gray(pic_prime);

[centers,radii] = imfindcircles(pic_prime,[(diameter/2 - 30), diameter/2 + 30],'ObjectPolarity','bright', ...
    'Sensitivity',0.995)


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

% corner_pix = double(pagetranspose(pic_prime(200, 20, :)));
% 
% for index_i = 1:1:36
% 
%     for remaining_pixels = 1:1:(max(region_count) - region_count(index_i))
%         region_average_prime(index_i, :, :) = region_average_prime(index_i, :, :) + corner_pix;
%     end
% 
%     region_average_prime(index_i, :, :) = region_average_prime(index_i, :, :)./max(region_count); 
% end

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

    %for index_j = 1:1:3
    %    diff = diff + abs(region_average_prime(index_i, :, index_j) - total_average(index_j));
    %    diff2 = diff2 + region_average_prime(index_i, :, index_j) - total_average(index_j);
    %end

            
    diff = diff + abs(region_average_prime(index_i, :, 1) - total_average(1));
    diff2 = diff2 + region_average_prime(index_i, :, 1) - total_average(1);

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

end

36 - section + 1
real_diff

%% Now we will decide what to suggest to the beam profiler

for inferences=1:1:5
    prediction = list_sections(inferences);
    solved = false;

    for iteration=1:1:5
        if(curr_values(prediction) == 0.05) %If the predicted value is maxed at 0.05
            if(list_real_diff(inferences) < 0) % If we are decreasing the voltage we are okay
                curr_values(prediction) = curr_values(prediction) - 0.01;
                solved = true;
                break;
            else % Otherwise we need to look at the other values surrounding it
                if mod(iteration,2) == 1
                    prediction = prediction + iteration;
                else
                    prediction = prediction - iteration;
                end
            end
        elseif(curr_values(prediction) == -0.05) %If the predicted value is maxed at 0.05
            if(list_real_diff(inferences) > 0) % If we are decreasing the voltage we are okay
                curr_values(prediction) = curr_values(prediction) + 0.01;
                solved = true;
                break;
            else % Otherwise we need to look at the other values surrounding it
                if mod(iteration,2) == 1
                    prediction = prediction + iteration;
                else
                    prediction = prediction - iteration;
                end
            end
        else
            if(list_real_diff(inferences) < 0) % Then we do standard procedure
                curr_values(prediction) = curr_values(prediction) - 0.01;
                solved = true;
                break;
            else
                curr_values(prediction) = curr_values(prediction) + 0.01;
                solved = true;
                break;
            end
        end
    end

    if(solved == true)
        break
    end

end
writematrix(curr_values,"beam_values.csv")
curr_values


%% THE PLAN TO INTEGRATE EVERYTHING

% We will communicate the labview program and the matlab program by using
% a CSV file. Basically we will have the matlab program write the values
% that the AI has determined into a CSV, then we will have the labview
% program read those values and put them into the beam profiler. We can see
% when we want to make our detection or start one program by looking at
% when the csv was last modified. 

























