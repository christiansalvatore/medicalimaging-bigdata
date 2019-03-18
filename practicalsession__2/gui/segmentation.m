function varargout = segmentation(varargin)
% SEGMENTATION MATLAB code for segmentation.fig
%      SEGMENTATION, by itself, creates a new SEGMENTATION or raises the existing
%      singleton*.
%
%      H = SEGMENTATION returns the handle to a new SEGMENTATION or the handle to
%      the existing singleton*.
%
%      SEGMENTATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGMENTATION.M with the given input arguments.
%
%      SEGMENTATION('Property','Value',...) creates a new SEGMENTATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before segmentation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to segmentation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help segmentation

% Last Modified by GUIDE v2.5 13-Mar-2019 16:57:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @segmentation_OpeningFcn, ...
                   'gui_OutputFcn',  @segmentation_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before segmentation is made visible.
function segmentation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to segmentation (see VARARGIN)

% Choose default command line output for segmentation
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes segmentation wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = segmentation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile('*.dcm');

file = strcat(path,'/',file);

info = dicominfo(file);
slope = info.RescaleSlope;
intercept = info.RescaleIntercept;

global img
img = dicomread(file);
img = double(img);

img = img.*slope + intercept;
imshow(img); caxis('auto'); colormap(gray); colorbar


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img

h = imfreehand;

% Position of the ROI
% x- and y-coordinates, respectively, of the n points along the boundary
% of the freehand region
pos = getPosition(h); 

% Creating a matrix that contains only the selected ROI
mask = createMask(h);
img__roi = img.*mask;

% Calculate the threshold
max__roi = max(max(img__roi));
threshold = 0.6 * max__roi;

% Apply the threshold to the ROI
img__roithreshold = img__roi;
img__roithreshold(img__roithreshold < threshold) = 0;
% imshow(img__roithreshold,[],'Colormap',hot); colorbar;

% We have now two images to display: the background image and the
% thresholded ROI.
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
foreground__img = img__roithreshold./max(max(img__roithreshold));
new__img = background__img;
for i = 1:size(img,1)
    for j = 1:size(img,2)
        if foreground__img(i,j) ~= 0
            new__img(i,j) = 1.0001 + foreground__img(i,j);
        end
    end
end

% Plot the resulting image using the new colormap
imshow(new__img); colormap(new__cmap); caxis('auto'); colorbar

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(gca,'visible','off')


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img
imshow(img); caxis('auto'); colormap(gray); colorbar
