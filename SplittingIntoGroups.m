% This code is meant to take the large shapefile that spans the entire
% Alaskan Arctic and split it into two groups that represents tracks in the
% Chukchi and Beaufort seas. This is because we find different sail:keel
% ratios so this is therefore necessary before further processing. 

%% CHUKCHI SEA SIDE
% Step 1: Load coordinates from each .txt file
files = '*.txt';
list = dir(files);

% Preallocate cell array to store coordinates for each line
all_coordinates = cell(numel(list), 1);

% Loop through each .txt file and read coordinates
for i = 1:numel(list)
    filename = list(i).name;
    coordinates = dlmread(filename); % Assuming space-delimited .txt files
    all_coordinates{i} = coordinates;
end

% Step 2: Define study area boundaries (e.g., as a polygon)
% These Coordinates are for the Chukchi Sea Side

dms=[71 14 33 ;
    67 59 39 ;
    68 40 26 ;
    72 10 22];
    latUtqiagvik=dms2degrees(dms); 
    
dms=[-155 43 28;
    -165 49 43 ;
    -169 21 22 ;
    -159 14 14];
    lonUtqiagvik=dms2degrees(dms);

polygon = polyshape(lonUtqiagvik, latUtqiagvik);

% Step 3: Determine which lines pass through the study area
lines_in_study_area = false(numel(list), 1);

for i = 1:numel(list)
    coordinates = all_coordinates{i};
    lines_in_study_area(i) = any(inpolygon(coordinates(:,1), coordinates(:,2), lonUtqiagvik, latUtqiagvik));
end

% Step 4: Extract coordinates of lines that pass through the study area
coordinates_in_study_area = all_coordinates(lines_in_study_area);

% Step 6: Add the coodinates back onto the list so that track data is
% associated with those that are in the study region
ChukchiCoast = list(lines_in_study_area);

for i = 1:numel(ChukchiCoast)
    ChukchiCoast(i).Data = coordinates_in_study_area{i};  % Assign some value to the new field
end

save('ChukchiCoast.mat', 'ChukchiCoast', '-v7.3');

%% BEAUFORT SEA SIDE

% Step 1: Load coordinates from each .txt file
files = '*.txt'
list = dir(files);

% Preallocate cell array to store coordinates for each line
all_coordinates = cell(numel(list), 1);

% Loop through each .txt file and read coordinates
for i = 1:numel(list)
    filename = list(i).name;
    coordinates = dlmread(filename); % Assuming space-delimited .txt files
    all_coordinates{i} = coordinates;
end

% Step 2: Define study area boundaries (e.g., as a polygon)
% These Coordinates are for the Chukchi Sea Side

dms=[68 47 17 ;
    70 57 17 ;
    72 12 24 ;
    69 59 54];
    latUtqiagvik=dms2degrees(dms); 
    
dms=[-138 42 56;
    -157 10 05 ;
    -155 18 57 ;
    -137 14 09];
    lonUtqiagvik=dms2degrees(dms);

polygon = polyshape(lonUtqiagvik, latUtqiagvik);

% Step 3: Determine which lines pass through the study area
lines_in_study_area = false(numel(list), 1);

for i = 1:numel(list)
    coordinates = all_coordinates{i};
    lines_in_study_area(i) = any(inpolygon(coordinates(:,1), coordinates(:,2), lonUtqiagvik, latUtqiagvik));
end

% Step 4: Extract coordinates of lines that pass through the study area
coordinates_in_study_area = all_coordinates(lines_in_study_area);


% Step 6: Add the coodinates back onto the list so that track data is
% associated with those that are in the study region
BeauCoast = list(lines_in_study_area);

for i = 1:numel(BeauCoast)
    BeauCoast(i).Data = coordinates_in_study_area{i};  % Assign some value to the new field
end

save('BeauCoast.mat', 'BeauCoast', '-v7.3');