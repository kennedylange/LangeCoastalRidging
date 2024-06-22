%% finding the lat lon location for each of the ridges
% start by loading in the RevisedChukData.csv file through the matlab
% import button

% Load Data =  Here

load BeauCoast.mat
load ChukchiCoast.mat
Coast = BeauCoast;
%Coast = ChukchiCoast;

ridgelat = zeros(1, 943); 
ridgelon = zeros(1,943);

BGnumber = fillmissing(Data.number, 'previous');

for N = 1:length(Data.number)

    if ~isnan(Data.DistanceFromShore(N))

        trackno = BGnumber(N);
        tracklat = Coast(trackno).Data(:,2);
        tracklon = Coast(trackno).Data(:,1);
        trackdist = distance_sparce(tracklat, tracklon);
        
        [~, location] = min((trackdist - Data.DistanceFromShore(N)).^2);
        
        ridgelat(N) = tracklat(location(1));
        ridgelon(N) = tracklon(location(1));

    end

end

%% Saving this data
% BeauRidges = [ridgelonbeau', ridgelatbeau'];
% BeauRidges  = array2table(BeauRidges);
% writetable(BeauRidges, "BeauRidgeCoords.csv");
% 
% ChukRidges = [ridgelonchuk', ridgelatchuk'];
% ChukRidges  = array2table(ChukRidges);
% writetable(ChukRidges, "ChukRidgeCoords.csv");