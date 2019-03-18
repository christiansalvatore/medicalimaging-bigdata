%-------------------------------------------------------------------------
% Medical Imaging and Big Data
% Practical session #2c | #dicom #pet #roi #kmeans-segmentation 
% christian.salvatore@unimib.it
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

% Store slope and intercept
slope = info.RescaleSlope;
intercept = info.RescaleIntercept;

% Load a single slice of the 3-dimensional acquisition
img = dicomread('PET-160');
img = double(img);

% y = slope*x + intercept
img = slope*img + intercept;

% Visualize the image
figure();
imshow(img); caxis('auto'); colorbar

% Use k-means clustering to perform automatic segmentation
reshaped__img = reshape(img,[size(img,1)*size(img,2),1]);
idx = kmeans(reshaped__img,2,'replicate',5);
idx__reshaped = reshape(idx,[size(img,1),size(img,2)]);
figure; imshow(idx__reshaped); caxis('auto')

% We have now two images to display: the background image and the
% segmented ROI.
% In order to plot these two images as superimposed on the same figure,
% we should create a single image with values on two different color
% scales (in order to make them visually distinguishable).
% This image will then be plotted using two different colormaps stacked one
% over the other. Let us prepare a two-maps-in-one colormap by stacking a
% jet colormap and a hot colormap.
cmap__1 = colormap(gray);
cmap__2 = colormap(jet);
new__cmap = [cmap__1; cmap__2];

% Let us prepare the new image to be plotted. This new image will have the
% original-image values outside our thresholded ROI, and the new values
% inside the thresholded ROI.
% The new values will simply be the original values plus the maximum of the
% original image.
background__img = img./max(max(img));
background__level = mode(idx);
new__img = background__img;
for i = 1:size(img,1)
    for j = 1:size(img,2)
        if idx__reshaped(i,j) ~= background__level
            new__img(i,j) = 1.0001 + background__img(i,j);
        end
    end
end

% Plot the resulting image using the new colormap
imshow(new__img); colormap(new__cmap); caxis('auto'); colorbar


%-------------------------------------------------------------------------
% 3. Closing the script
%-------------------------------------------------------------------------

% Interrupt the input to the log file
close all
clear
clc
diary off
