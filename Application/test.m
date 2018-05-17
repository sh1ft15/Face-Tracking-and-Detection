clc; 
vid = videoinput('winvideo',1); 
preview(vid); 
start(vid); 
set(vid, 'ReturnedColorSpace', 'RGB'); 
for frame =1:2 
    % your function goes here 
    thisFrame = getsnapshot(vid); 
    if frame == 1 
        a = thisFrame; 
    else
        b = thisFrame; 
    end
    pause(1); 
end
faceDetector = vision.CascadeObjectDetector(); 
bbox = step(faceDetector, a); 
IFaces = insertObjectAnnotation(a, 'rectangle', bbox, 'face'); 
imshow(IFaces);