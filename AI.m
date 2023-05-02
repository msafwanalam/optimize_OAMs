% Filename for where the image of the beam is saved
file = dir("C:\Users\Ford\Documents\Gentec-EO\beamage.bmp");
old_file_date = file.date;
count = 0;
find_circle_count = 0;
% usually diameter is 410
diameter =482;
% use drawline to find diameter of the circle (or find_diameter matlab 
% script)
max_iteration = 100;

% Choose theta based on how much the angle will differ
% OAM +1 = 0
% OAM +2 = 10
% OAM -2 = 100
theta = 10;

while(true)
    file = dir("C:\Users\Ford\Documents\Gentec-EO\beamage.bmp");
    if ~strcmp(old_file_date, file.date)
        old_file_date = file.date;
        count = count + 1;
        count % Count will simply tell us how many iterations we have gone through
        pause(10)

        %% This is where we keep track of all the values we are inputting into the beam profiler

        curr_values = readmatrix("beam_values.csv");

        %% This is where we begin the detection
        pic_prime = imread("C:\Users\Ford\Documents\Gentec-EO\beamage.bmp");
        figure(1)
        imshow(pic_prime)


        gray_image = rgb2gray(pic_prime);
        

        [centers,radii] = imfindcircles(gray_image,[(diameter/2 - 10), diameter/2 + 10],'ObjectPolarity','bright', ...
            'Sensitivity',0.995)

        if(size(radii, 1) > 1)
            'Too many circles, trying again'
            writematrix(curr_values,"beam_values.csv")
            continue;
        end

        if(size(radii, 1) < 1)
            find_circle_count = find_circle_count + 1;
            if(find_circle_count > 5)
                'Could not find circle, trying again'
                writematrix(curr_values,"beam_values.csv")
                continue;
            else
                'Could not detect circle, please change diameter'
            end
        end

        find_circle_count = 0;

        for index_i=1:1:size(pic_prime,1)
            for index_j=1:1:size(pic_prime,2)

                point = [index_j, index_i];
                dist = sqrt((point(1) - centers(1))^2 + (point(2) - centers(2))^2);

                %% INCREASE OR DECREASE INNER CIRCLE HERE
                if dist <= 4/10*radii || dist >= radii
                    pic_prime(index_i, index_j, :) = [0;0;0];
                    continue;
                end

                pic_prime(index_i, index_j, :) = [0;0;pic_prime(index_i, index_j, 3)];

            end
        end
        figure(2)
        imshow(pic_prime)

        h = viscircles(centers,radii);
        hold on;

        %% This is where add up all the components of the regions

        region_count = zeros(1,36);
        region_average_prime = zeros(36,1,3);
        gray_pixel = double(pagetranspose(pic_prime(1, 1, :)));
        black_pixel = gray_pixel;
        black_pixel(:) = 0;

        for index_i=1:1:size(pic_prime,1)
            for index_j=1:1:size(pic_prime,2)

                point = [index_j, index_i];
                dist = sqrt((point(1) - centers(1))^2 + (point(2) - centers(2))^2);

                if dist <= 2/5*radii || dist >= radii
                    continue;
                end

                if gray_pixel == double(pagetranspose(pic_prime(index_i, index_j, :)))
                    continue;
                end
                if black_pixel == double(pagetranspose(pic_prime(index_i, index_j, :)))
                    continue;
                end


                P0 = centers;
                P1 = point;
                P2 = [size(pic_prime, 2), size(pic_prime, 1)/2];
                n1 = (P2 - P0) / norm(P2 - P0);
                n2 = (P1 - P0) / norm(P1 - P0);

                angle3 = rad2deg(atan2(norm(det([n2; n1])), dot(n1, n2)));

                if (index_i < centers(2))
                    angle3 = 360 - angle3;
                end

                % This is where we use theta to properly place our value in
                % the correct angle
                angle3 = mod(angle3 - theta, 360);

                curr_index = floor(angle3/10) + 1;

                region_average_prime(curr_index, :, :) = region_average_prime(curr_index, :, :) ...
                    + double(pagetranspose(pic_prime(index_i, index_j, :)));

                region_count(curr_index) = region_count(curr_index) + 1;

            end
        end

        corner_pix = double(pagetranspose(pic_prime(200, 20, :)));

        %% In this code we are averaging out each of the sections that are created
        %         for index_i = 1:1:36
        %
        %             for remaining_pixels = 1:1:(max(region_count) - region_count(index_i))
        %                 region_average_prime(index_i, :, :) = region_average_prime(index_i, :, :) + corner_pix;
        %             end
        %
        %             region_average_prime(index_i, :, :) = region_average_prime(index_i, :, :)./max(region_count);
        %         end

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

        %% Next we are finding the differences from each of the sections

        for index_i = 1:1:36
            diff = 0;
            diff2 = 0;

            diff = diff + abs(region_average_prime(index_i, :, 3) - total_average(3));
            diff2 = diff2 + region_average_prime(index_i, :, 3) - total_average(3);

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

        list_sections(1:5)

        %% Now we will decide what to suggest to the beam profiler

        for inferences=1:1:20

            prediction = list_sections(inferences);
            solved = false;

            %             if(list_real_diff(inferences) < 0)
            %                 continue;
            %             end

            for iteration=1:1:5
                if(curr_values(prediction) == 0.05) %If the predicted value is maxed at 0.05
                    if(list_real_diff(inferences) < 0) % If we are decreasing the voltage we are okay
                        curr_values(prediction) = curr_values(prediction) - 0.01;
                        solved = true;
                        break;
                    else % Otherwise we need to look at the other values surrounding it
                        if mod(iteration,2) == 1
                            prediction = prediction + iteration;
                            prediction = mod(prediction-1, 36) + 1;
                        else
                            prediction = prediction - iteration;
                            prediction = mod(prediction-1, 36) + 1;
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
                            prediction = mod(prediction-1, 36) + 1;
                        else
                            prediction = prediction - iteration;
                            prediction = mod(prediction-1, 36) + 1;
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
        if(count == max_iteration)
            'We have reached max iterations'
            break;
        end
    end
end