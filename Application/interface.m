function varargout = interface(varargin)
% INTERFACE MATLAB code for interface.fig
%      INTERFACE, by itself, creates a new INTERFACE or raises the existing
%      singleton*.
%
%      H = INTERFACE returns the handle to a new INTERFACE or the handle to
%      the existing singleton*.
%
%      INTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTERFACE.M with the given input arguments.
%
%      INTERFACE('Property','Value',...) creates a new INTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before interface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to interface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help interface

% Last Modified by GUIDE v2.5 25-May-2017 10:41:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @interface_OpeningFcn, ...
                   'gui_OutputFcn',  @interface_OutputFcn, ...
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


% --- ON OPEN
function interface_OpeningFcn(hObject, eventdata, handles, varargin)
set(handles.pushbutton3, 'Enable', 'off');
s = dir('records.txt');

if ~(s.bytes == 0)
    fid = fopen('records.txt','r');
    list = textscan(fid,'%s','delimiter','\n');
    fclose(fid);
    set(handles.listbox1,'string', list{:}); 
    
    index = get(handles.listbox1, 'value');
    string = get(handles.listbox1, 'string');
    
    s = sprintf('images/%s.jpg', string{index});
    
    if exist(s, 'file') == 2  
        img = imread(s);
        imshow(img, 'Parent', handles.axes2);
    end
    
else
    set(handles.listbox1, 'string', []);
    set(handles.listbox1, 'Enable', 'off');
end



% Choose default command line output for interface
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);



% UIWAIT makes interface wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = interface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- START
function pushbutton1_Callback(hObject, eventdata, handles)
obj = imaq.VideoDevice('winvideo',1, 'YUY2_640x480');
set(handles.pushbutton1, 'Enable', 'off'); % This disabled
set(handles.pushbutton3, 'Enable', 'on'); % STOP enabled
set(handles.checkbox1, 'Enable', 'off'); % AUTO SNAP disabled

faceDetector = vision.CascadeObjectDetector;
set(obj, 'ReturnedColorSpace', 'rgb');

set(handles.pushbutton3,'userdata',0);

auto_record = get(handles.checkbox1, 'Value');
if(auto_record == 1)
    fps = 0;
end
          
while(~get(handles.pushbutton3,'userdata'))
    
    frame = step(obj);
    bbox = step(faceDetector, frame);
    f = insertObjectAnnotation(frame, 'rectangle', bbox, 'face');
    if ishandle(handles.axes1)
        imshow(f, 'Parent', handles.axes1)
    else
        break
    end
    t = datetime('now');
    set(handles.edit1, 'String', datestr(t));

    handles.t = t;
    handles.frame = frame;
    handles.bbox = bbox;
    handles.obj = obj;
    guidata(hObject, handles);
    if (auto_record == 1)
        if (fps == 10) % how many seconds till the snapshot will triggered
        % AUTO SNAP 
            pushbutton2_Callback(handles.pushbutton2, eventdata, handles); %snap
        % --
        end
        fps = fps + 1;
    end
    pause(0.05);
end





% --- SNAP
function pushbutton2_Callback(hObject, eventdata, handles)
if ~get(handles.pushbutton3,'userdata')
    
    if ~(isempty(handles.bbox))
        for i = 1:size(handles.bbox,1)
            J = imcrop(handles.frame,handles.bbox(i,:));
        end
        set(handles.listbox1, 'Enable', 'on');
        current = cellstr(get(handles.listbox1,'String'));
        date_time = datestr(handles.t, 'mm-dd-yyyy HH-MM-SS');

        if isempty(current)
            set(handles.listbox1, 'String', date_time);
        else
            new_list = [{date_time}; current];
            set(handles.listbox1,'string', new_list);
        end

        filename = datestr(handles.t, 'mm-dd-yyyy HH-MM-SS');

        imwrite(J, sprintf('images/%s.jpg', filename));

        fileID = fopen('records.txt','at');

        fprintf(fileID,'%s',filename);
        fprintf(fileID,'\n');
        fclose(fileID);

        imshow(J, 'Parent', handles.axes2);
        guidata(hObject, handles);
    else
        msgbox('No Face Detected!');
    end

else
    msgbox('No Video Device Detected!');
end



function interface_CloseRequestFcn(hObject, eventdata, handles)
pushbutton3_Callback(handles.pushbutton3, eventdata, handles); %stop



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- ON SELECT
function listbox1_Callback(hObject, eventdata, handles)
index_selected = get(hObject,'Value');
list = get(hObject,'String');
item_selected = list{index_selected};
 
s = sprintf('images/%s.jpg', item_selected);

if exist(s, 'file') == 2
    img = imread(s);
    imshow(img, 'Parent', handles.axes2);
else
    msgbox('File Not Found!');
end



% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- STOP
function pushbutton3_Callback(hObject, eventdata, handles)
set(handles.pushbutton3, 'Enable', 'off'); % This disabled
set(handles.pushbutton1, 'Enable', 'on'); % START enabled
set(handles.checkbox1, 'Enable', 'on'); % AUTO SNAP enabled
set(handles.pushbutton3,'userdata',1);
delete(handles.obj);
cla(handles.axes1,'reset');

guidata(hObject, handles);


% --- REMOVE ALL
function pushbutton5_Callback(hObject, eventdata, handles)
fopen('records.txt','wt'); % clear records text
dinfo = dir(fullfile('images','*.*'));
for K = 1 : length(dinfo)
    thisfile = fullfile('images', dinfo(K).name);
    if ~isdir(thisfile)
      delete(thisfile);  
    end
end
set(handles.listbox1, 'String', '');
cla(handles.axes2,'reset');


% --- AUTO RECORD
function checkbox1_Callback(hObject, eventdata, handles)
