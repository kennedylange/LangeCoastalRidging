% This code is meant to work through the coordinates of each ICESat-2
% tracks and determine where the intersection with shoreline is (as
% inported in shapefile format)

% Step 1: Load the shapefile and the data
load ChukchiCoast.mat 
data = ChukchiCoast;
%load BeauCoast.mat  
%data = BeauCoast;

shapefile = shaperead('Coastline2021.shp');
lineGeometry = shapefile.Geometry;
coastX = shapefile.X;
coastY = shapefile.Y;

%% Step 3: Loop through and test for intersection points with the coastline shapefile
Intersection = cell(numel(data), 1); %or ChukchiCoast

for i = 1:numel(data)
    % Extract the coordinates for the current line
    lineLat = data(i).Data(:, 2);
    lineLon = data(i).Data(:, 1);
    
    % Find intersections between the current line and the shapefile line
    [xIntersect, yIntersect] = polyxpoly(coastX, coastY, lineLon, lineLat);
    
    if ~isempty(xIntersect)
        % Save the coordinates of the first intersection point
        Intersection{i} = 'yes'; 
    else
        % If no intersection point found, fill with 'NA'
        Intersection{i} = 'NA';
    end
end

%% Save into the original struct with all other data

[ChukchiCoast.Intersection] = deal(Intersection{:});
%[BeauCoast.Intersection] = deal(Intersection{:});



