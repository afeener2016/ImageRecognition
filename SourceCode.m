clear rpi;
rpi = raspi("192.168.1.185","pi","raspberry"); %connect to raspi

InputSceneName = 'scene3.jpg'; %input scene to scan
getFile(rpi,['/home/pi/Downloads/Final/',InputSceneName]); %grab file from raspi

pointFeatureMatching(InputSceneName); %runs point feature matching on input file

rpi.system('omxplayer  -o local /home/pi/Downloads/Final/bellSFX.mp3'); %plays bell sound when detected
 


function pointFeatureMatching(detectingArea)

boxImage = imread('sample.jpg'); %base features of object looking for
boxImage = rgb2gray(boxImage);
boxImage=imrotate(boxImage,270);
figure;
imshow(boxImage);
title('Image of Card Box');

sceneImage = imread(detectingArea); %Picture of clutter
sceneImage = rgb2gray(sceneImage);
sceneImage=imrotate(sceneImage,270);
figure;
imshow(sceneImage);
title('Image of Desk Scene');

boxPoints = detectSURFFeatures(boxImage);
scenePoints = detectSURFFeatures(sceneImage);

[boxFeatures, boxPoints] = extractFeatures(boxImage, boxPoints);
[sceneFeatures, scenePoints] = extractFeatures(sceneImage, scenePoints);

boxPairs = matchFeatures(boxFeatures, sceneFeatures);

matchedBoxPoints = boxPoints(boxPairs(:, 1), :);
matchedScenePoints = scenePoints(boxPairs(:, 2), :);

[tform, ~, ~] = ...
    estimateGeometricTransform(matchedBoxPoints, matchedScenePoints, 'affine');

boxPolygon = [1, 1;...                           % top-left
        size(boxImage, 2), 1;...                 % top-right
        size(boxImage, 2), size(boxImage, 1);... % bottom-right
        1, size(boxImage, 1);...                 % bottom-left
        1, 1];                   % top-left again to close the polygon
    
    newBoxPolygon = transformPointsForward(tform, boxPolygon);
    
figure; %detected box
imshow(sceneImage);
hold on;
line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'y');
title('Detected Box');

end

