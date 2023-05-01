clear
pic_prime = imread("C:\Users\Ford\Documents\Gentec-EO\beamage.bmp");
imshow(pic_prime)
line = drawline;
pos = line.Position;
diameter = sqrt((pos(1,1) - pos(2,1))^2 + (pos(1,2)- pos(1,2))^2)