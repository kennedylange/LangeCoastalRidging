function [distancetoshore] = distance_sparce(tracklat, tracklon)

coastline = shaperead('Coastline2021.shp');

lonedges = [min(tracklon)-.1 max(tracklon)+.1];

tempcoast_lat = coastline(1).Y(coastline(1).X> lonedges(1) &...
    coastline(1).X< lonedges(2));

tempcoast_lat_dense = interp1(tempcoast_lat, (1:length(tempcoast_lat)*100)/100, 'linear');

tempcoast_lon = coastline(1).X(coastline(1).X> lonedges(1) &...
    coastline(1).X< lonedges(2));

tempcoast_lon_dense = interp1(tempcoast_lon, (1:length(tempcoast_lon)*100)/100, 'linear');

distancetoshore = nan(1, numel(tracklat));

for n = 1:100:length(tracklat)
    dist2shore = nan(1, numel(tempcoast_lat_dense));
    
    for m = 1:length(tempcoast_lat_dense)
            dist2shore(m) =distance(tracklat(n), tracklon(n), ...
                tempcoast_lat_dense(m), tempcoast_lon_dense(m), wgs84Ellipsoid("kilometer"));
    end

    distancetoshore(n) = min(dist2shore);

end

[err, index] = min(distancetoshore);

for n = index-100:index+100
    dist2shore = nan(1, numel(tempcoast_lat_dense));
    
    for m = 1:length(tempcoast_lat_dense)
         dist2shore(m) =distance(tracklat(n), tracklon(n), ...
                tempcoast_lat_dense(m), tempcoast_lon_dense(m), wgs84Ellipsoid("kilometer"));    
    end

    distancetoshore(n) = min(dist2shore);

end

%% fill in the zeros in the sparce calculation

distancetoshore = fillmissing(distancetoshore, 'linear');

%% correct the south-of-shore to be negative

if tracklat(2) - tracklat(1) > 0

    [~, crossing] = min(distancetoshore);
    offset = distancetoshore(crossing);
    distancetoshore(1:crossing) = -distancetoshore(1:crossing)-offset;
else
    [~, crossing] = min(distancetoshore);
    offset = distancetoshore(crossing);
    distancetoshore(crossing:end) = -distancetoshore(crossing:end)-offset;
end



end
