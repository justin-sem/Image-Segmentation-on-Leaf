clc;
clear;
close all;
fontSize = 15;

%**************************************************************************
for i = 1:3    
    
    if i == 1     
    imageObj = imread("plant001.png");
    end
    
    if i ==2     
    imageObj = imread("plant002.png");
    end
    
    if i ==3     
    imageObj = imread("plant003.png");
    end


% Display the original color image
    if i == 1
    subplot(3,2,1);
    imshow(imageObj);
    title('Input Image 1','FontSize',fontSize);
    end

    if i == 2
    subplot(3,2,3);
    imshow(imageObj);
    title('Input Image 2','FontSize',fontSize);
    end

    if i == 3
    subplot(3,2,5);
    imshow(imageObj);
    title('Input Image 3','FontSize',fontSize);
    end

% Enlarge figure(window) to full screen.
set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]);

% Extract the individual red, green, and blue color channels.
red = (double(imageObj(:,:,1)))/255;
green =(double(imageObj(:,:,2)))/255;
blue =(double(imageObj(:,:,3)))/255;

% greenness is calculated
greenDiff = green - (red+blue)/ 2.0;

% graythresh function here perform Otsu thresholding
plantThresh = graythresh(greenDiff);

greenyBG = greenDiff;
greenyBG(greenyBG < plantThresh) = 0 ;
bgSegmented = greenyBG; 

% Biased and Gained
bgSegmented = (bgSegmented *2.0) + 0.2;


% ref: mathworks.com/help/images/marker-controlled-watershed-segmentation.html 
% ref: mathworks.com/help/images/ref/watershed.html 
% watershed segementation
gradientMagnitude = imgradient(bgSegmented);
se = strel('square',7); 

% Opening-Closing by Recontruction to clean up the image.
iErode = imerode(bgSegmented,se);
iOpeningRecon = imreconstruct(iErode,bgSegmented);
iOpeningReconDilate = imdilate(iOpeningRecon,se);
iOpenCloseRecon = imreconstruct(imcomplement(iOpeningReconDilate),imcomplement(iOpeningRecon));
iOpenCloseRecon = imcomplement(iOpenCloseRecon);

foregroundMark = imregionalmax(iOpenCloseRecon);
I2 = labeloverlay(bgSegmented,foregroundMark);

se2 = strel(ones(10,10));
foregroundMark2 = imclose(foregroundMark,se2);
foregroundMark3 = imerode(foregroundMark2,se2);
foregroundMark4 = bwareaopen(foregroundMark3,20);
I3 = labeloverlay(bgSegmented,foregroundMark4);

BW = imbinarize(bgSegmented); 
D = bwdist(BW);
DL = watershed(D);
backgroundMark = DL == 0;

gradientMagnitude2 = imimposemin(gradientMagnitude, backgroundMark |foregroundMark4);
L = watershed(gradientMagnitude2);

% Set pixels that are outside the ROI to 0.
L(~BW) = 0;

RGB = label2rgb(L,'jet','k','shuffle');

    if i == 1
    subplot(3,2,2)
    imshow(RGB)
    title('Output Image 1','FontSize',fontSize);
    end
    
    if i == 2
    subplot(3,2,4)
    imshow(RGB)
    title('Output Image 2','FontSize',fontSize);
     end
    
    if i == 3
    subplot(3,2,6)
    imshow(RGB)
    title('Output Image 3','FontSize',fontSize);
    end 
    
end











