%-------------------------------------------------------------------------
% Medical Imaging and Big Data
% Practical session #1
% christian.salvatore@ibfm.cnr.it
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
% 1. Inizialization
%-------------------------------------------------------------------------
clear; clc; close all;
addpath(genpath('data'));
addpath(genpath('thirdparty-libraries'));

% Create a log file
diary('log.txt');
diary on


%-------------------------------------------------------------------------
% 2. Working with DICOM images
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
% 2.1 Loading and visualizing a single DICOM image
%-------------------------------------------------------------------------
cd 'data/single-patient/PET/dicom';

% Reading the information about the patient and the PET acquisition
info = dicominfo('PET-160');

% Printing the name of the patient
info.PatientName

% Visualizing and saving information about image/acquisition
% Information to be considered:
% 1. Voxel dimension (x, y, z) -> useful for computing a lesion volume
% 2. Scale factor between a value visualized and the effective number 
% of counts -> useful for computing the uptake in a specific ROI

% Voxel dimension is saved in the fields PixelSpacing (x,y) and
% SliceThickness (z)
dimx = info.PixelSpacing(1);
dimy = info.PixelSpacing(2);
dimz = info.SliceThickness;

% Calculate the dimension of a single voxel [mm^3]
dim__voxel = dimx*dimy*dimz;

% The scale factor is saved in the field called "RescaleSlope"
slope = info.RescaleSlope;

% Load a single slice of the 3-dimensional acquisition
img = dicomread('PET-160');
img = double(img);

% Multiply by the scaling factor
img = img*slope;

% Visualize the image
figure();
imshow(img);

% "Fix" the visualization based on the output/color scale
minimum = min(min(img)); disp(num2str(minimum));
maximum = max(max(img)); disp(num2str(maximum));

% Visualize the colorbar
colorbar

% Normalize the output image between 0 and 1
img = img - minimum;
disp(num2str(max(max(img))));
img = img/maximum;
img = img*1;

% Plot the new image
figure();
imshow(img);
colorbar;

% Try to change the colormap
imshow(img,'Colormap',hot); colorbar;
pause(2)
imshow(img,'Colormap',winter); colorbar;
pause(2)
imshow(img,'Colormap',spring); colorbar;
pause(2)
imshow(img,'Colormap',summer); colorbar;
pause(2)
imshow(img,'Colormap',gray); colorbar;

% Title
set(gcf, 'Name', 'PET', 'NumberTitle', 'Off');

%-------------------------------------------------------------------------
% 2.2 Loading the entire 3-dimensional volume as a DICOM image
%-------------------------------------------------------------------------
files = dir('*.dcm');
for n = 1:size(files,1)
    pathtemp = files(n).name;
    info__temp = dicominfo(pathtemp);
    dcm__temp = dicomread(pathtemp);
    dcm__temp = double(dcm__temp.*info__temp.RescaleSlope);
    stackimg(n,:,:) = dcm__temp;
    disp(['The dimension of stackimg after ' num2str(n)...
        ' iterations is ' num2str(size(stackimg))]);
end
nvoxel = size(stackimg,2) * size(stackimg,3);
disp(['Each one of the ' num2str(size(stackimg,1))...
    ' loaded images is made of ' num2str(nvoxel) ' voxels']);

% Normalize the image intensity between 0 and 1
minimum = min(min(min(stackimg))); disp(num2str(minimum));
maximum = max(max(max(stackimg))); disp(num2str(maximum));
stackimg = stackimg - minimum;
disp(num2str(max(max(max(stackimg)))));
stackimg = stackimg/maximum;
stackimg = stackimg*1;

% The new calculated min/max values are:
minimum = min(min(min(stackimg))); disp(num2str(minimum));
maximum = max(max(max(stackimg))); disp(num2str(maximum));

% Visualize a single slice of the entire volume
figure();
imshow(squeeze(stackimg(160,:,:)),'Colormap',hot);
figure();
imshow(rot90(squeeze(stackimg(:,145,:)),2),'Colormap',hot);
figure();
imshow(rot90(squeeze(stackimg(:,:,120)),2),'Colormap',hot);


%-------------------------------------------------------------------------
% 2.3 Interaction: input ROI > Defining a Region Of Interest
%-------------------------------------------------------------------------
close all;
figure();
imshow(squeeze(stackimg(160,:,:)),'Colormap',hot);
h = imfreehand;

% Position of the ROI
% x- and y-coordinates, respectively, of the n points along the boundary
% of the freehand region
pos = getPosition(h); 

% Creating and visualizing an image that contains only the selected ROI
mask = createMask(h);
img__roi = img.*mask;
figure();
imshow(img__roi,[],'Colormap',hot);

% Creating and visualizing an image that does not contain the selected ROI
img__noroi = img.*(1-mask);
figure();
imshow(img__noroi,[],'Colormap',hot);

% Alternatives: imrect | imellipse | imline | impoint | impoly
% In imrect, the position is equal to [xmin ymin width height]
% h = imrect;
% pos = getPosition(h);


%-------------------------------------------------------------------------
% 2.4 Working with ROIs
%-------------------------------------------------------------------------
% Create a filter that takes the maximum-intensity value within the
% selected ROI and that filters all intensities below the 60% of the
% maximum
% Apply this filter to the entire image
% Apply the same filter to the entire volume

% Calculate the threshold
max__roi = max(max(img__roi));
threshold = 0.6 * max__roi;

% Apply the threshold to the ROI
img__roithreshold = img__roi;
img__roithreshold(img__roithreshold < threshold) = 0;
figure();
imshow(img__roithreshold,[],'Colormap',hot);

% Apply the threshold to the entire image
img__threshold = img;
img__threshold(img__threshold < threshold) = 0;
figure();
imshow(img__threshold,[],'Colormap',hot);

% Modify the threshold
threshold = 0.1 * max__roi;
img__threshold = img;
img__threshold(img__threshold < threshold) = 0;
figure();
imshow(img__threshold,[],'Colormap',hot);

% Calculate the volume of the selected ROI through the aplication of an
% intensity filter
% Calculate the number of voxels
nvoxel = nnz(img__threshold > 0);

% Alternative: nvoxel = sum(img__threshold(:) > 0);

% Calculate the volume, knowing the dimension of a single voxel in mm^3
volume = nvoxel * dim__voxel;
disp(['Il volume della lesione è pari a ' num2str(round(volume/1000))...
    ' cc.']);

% Apply the threshold to the entire volume
threshold = 0.6 * max__roi;
stackimg__threshold = stackimg;
stackimg__threshold(stackimg__threshold < threshold) = 0;
figure();
imshow(squeeze(stackimg__threshold(100,:,:)),[],'Colormap',hot);


%-------------------------------------------------------------------------
% 3. Closing the script
%-------------------------------------------------------------------------

% Interrupt the input to the log file
close all
clear
clc
diary off