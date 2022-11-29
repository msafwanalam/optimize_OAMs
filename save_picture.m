create_circle_picture(0)
function create_circle_picture(circle_shift)

figure('visible','off')

im = imread('C:\Users\safwa\Documents\ENEE_Photonics\square.jpg');
%im = imread('C:\Users\safwa\Documents\ENEE_Photonics\beamage.bmp');
im = imread('C:\Users\safwa\Documents\ENEE_Photonics\labview tests\diff.bmp');

%imagine.AlphaData = max(im2,[],3);    

right = size(im,2);
top = size(im,1);

y_center =  size(im, 1)/2;
x_center =  size(im, 2)/2;

ten_deg = 2*pi/36;
right_offset = 20;
offset = 0;

text_str = cell(36,1);
conf_val = 1:1:36;
for ii=1:36
   text_str{ii} = [num2str(conf_val(ii),'%d')];
end
state = 1;
pos = [right-right_offset y_center-20];
for num = 1:1:35
    if state == 1 || state == 5
        if y_center-(tan(num*ten_deg + ten_deg/2)*x_center)-offset >= y_center*2 - 20
            pos = [pos; right-right_offset, y_center-(tan(num*ten_deg + ten_deg/2)*x_center)-offset-20];
        else
            pos = [pos; right-right_offset, y_center-(tan(num*ten_deg + ten_deg/2)*x_center)-offset];
        end
        if (y_center - (tan((num+1)*ten_deg + ten_deg/2)*x_center) - offset) < 0
            state = state + 1;
        end
    elseif state == 2
        pos = [pos; x_center + (y_center/tan(num*ten_deg + ten_deg/2))-offset, 0];
        if x_center+ (y_center/tan( (num+1)*ten_deg + ten_deg/2))-offset < 0
            state = state + 1;
        end
    elseif state == 3
        if (tan(num*ten_deg + ten_deg/2)*x_center)+offset >= y_center - 5
            pos = [pos; 0, y_center + (tan(num*ten_deg + ten_deg/2)*x_center)+offset - 20];
        else
            pos = [pos; 0, y_center + (tan(num*ten_deg + ten_deg/2)*x_center)+offset];
        end
        if (y_center - (tan((num+1)*ten_deg + ten_deg/2)*x_center) + offset) < 0
            state = state + 1;
        end
    elseif state == 4
        if x_center - (y_center/tan(num*ten_deg + ten_deg/2)) >= x_center*2 - 5
            pos = [pos; x_center - (y_center/tan(num*ten_deg + ten_deg/2)), top - 20];
        else
            pos = [pos; x_center - (y_center/tan(num*ten_deg + ten_deg/2))- 10, top - 20];
        end
        if x_center +(y_center/tan( (num+1)*ten_deg + ten_deg/2))-5 < 0
            state = state + 1;
        end
    end 
end



position = [right-10 y_center;
            right-10, y_center - (tan(ten_deg)*x_center);
            right-10, y_center - (tan(2*ten_deg)*x_center);
            right-10, y_center - (tan(3*ten_deg)*x_center);
            right-10, y_center - (tan(4*ten_deg)*x_center);
            right-10, y_center - (tan(5*ten_deg)*x_center)]; 
box_color = {"red","red","red", "red", "red", "red", "red", "red", ... 
    "red", "red", "red", "red", "red", "red", "red", ...
    "red","red","red", "red", "red", "red", "red", "red", ... 
    "red", "red", "red", "red", "red", "red", "red", ...
    "red","red","red", "red", "red", "red"};

text_str = circshift(text_str, circle_shift);

earth = insertText(im,pos,text_str,FontSize=16,BoxColor=box_color,...
    BoxOpacity=0.4,TextColor="white");

image(earth)
clouds = imread('C:\Users\safwa\Documents\ENEE_Photonics\frame_0_delay-0.01s-removebg-preview.png');
clouds = imresize(clouds,[size(earth,1) size(earth,2)]);
image(earth)
axis image
hold on

im = image(clouds);
im.AlphaData = max(clouds,[],3);    
hold off

saveas(gcf, 'changed_image.png')

end













