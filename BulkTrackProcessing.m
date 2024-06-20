%% Load the dataset for one basin at a time (uncomment the one you want to use)

% load ChukchiCoast.mat
% TrackDatabase = ChukchiCoast;
% clear ChukchiCoast;
% basin = 'C';

load BeauCoast.mat
TrackDatabase = BeauCoast;
clear BeauCoast;
basin = 'B';

%% initializing
badtracklist = [];
coastline = shaperead('Coastline2021.shp');

% read in bathymetry
[A, R] = readgeoraster('GEBCO_AlaskaCoast_bathymetrydata.tif'); % loading in the bathymetric data file
info = geotiffinfo('GEBCO_AlaskaCoast_bathymetrydata.tif');
load bathymetry_latlon_grid.mat


%% Process 
for n = 1:5%length(TrackDatabase) % loop through all tracks (length(TrackDatabase)) or a specific subset
         
        filename = TrackDatabase(n).name; % only use tracks that intersect shore
        disp(filename)
        try
        % get the date from the file name
        trackdate = datetime(str2num(filename(7:10)), str2num(filename(11:12)), str2num(filename(13:14)));

        tracklat = TrackDatabase(n).Data(:,2);
        tracklon = TrackDatabase(n).Data(:,1);

        distances_to_coast = distance_sparce(tracklat, tracklon);
        nearcoast = distances_to_coast >0 & distances_to_coast < 4;

        disp("Distance calculated")
        %% surface height data and corrections
        fdd_thick = fdd_thickness(trackdate, basin);

        atlheight = TrackDatabase(n).Data(:,4); % pulls surface height data for the track

        % finding the modal surface height

        modalheight = mode(round(atlheight(nearcoast),2));

        % ice thickness from FDD - REPLACE THIS DATE WITH THE DATE OF THE TRACK
        thermodynamic_thickness = fdd_thick /100; %Convert cm to m

        % This is the height in original coordinates of the bottom of the undeformed ice
        bottom_floe_originalcoords = modalheight - thermodynamic_thickness;

        % Now find water level/freeboard
        above_water_floe_thickness = thermodynamic_thickness*(1-(917/1026)); % assuming buoyancy
        waterlevel_originalcoords = modalheight - above_water_floe_thickness;

        % Aligning water level with 0 height 
        surfaceheight = atlheight - waterlevel_originalcoords;
        floe_bottom = bottom_floe_originalcoords - waterlevel_originalcoords;
        corrected_modalfreeboard = modalheight-waterlevel_originalcoords;

        
        %% keel depth calculations

        if basin=='C'
            r1 = 2.9184023;
            r2 = 3.822976;
            r3 = 3.3707;
            int1 = -0.4117447;
            int2 = 1.360723;
            int3 = 0.4745;

        elseif basin == 'B'
            r1 = 2.7372867;
            r2 = 4.252549;
            r3 = 3.4949;
            int1 = -0.3462207;
            int2 = 4.490959;
            int3 = 2.0724;

        end

        % bottom of confidence interval depth estimate
        keeldepth1 = -(r1 * surfaceheight+int1);
        keeldepth1(keeldepth1>0) = NaN;

        % Top 95% confidence interval
        keeldepth2 = -(r2 * surfaceheight+int2);
        keeldepth2(keeldepth2>0) = NaN;

        % Linear regression model
        keeldepth3 = -(r3 * surfaceheight+int3);
        keeldepth3(keeldepth3>0) = NaN;

        % take the max depth between the keel depths and the bottom of thermodynamically grown ice - cleans up plotting
        keeldepth1lower = min(keeldepth1, floe_bottom);
        keeldepth2lower = min(keeldepth2, floe_bottom);
        keeldepth3lower = min(keeldepth3, floe_bottom);
   
        disp("Keel depth calculated")
        %% now sample the bathymetry along the lines

        bathymetry = griddata(longrid,latgrid, double(A), tracklon, tracklat);

        disp("Bathymetry calculated")
        %% plotting
        
        figure(100)
        subplot(2, 4, [1 2 3  5 6 7])
        plot(distances_to_coast,surfaceheight, 'Color', 'b')
        hold on
        plot(distances_to_coast, keeldepth1lower, 'Color', [230, 184, 252]/256)
        plot(distances_to_coast,keeldepth2lower, 'Color', [172, 2, 250]/256)
        plot(distances_to_coast,keeldepth3lower, 'Color', [89, 44, 110]/256)
        plot(distances_to_coast,bathymetry, 'Color',[166, 111, 2]/256)
        hold off
        grid on

        isobar30m = distances_to_coast(find(bathymetry>-31 & bathymetry< -30, 1));
        if ~isempty(isobar30m)
             upperlim = isobar30m;
        else
            upperlim = max(distances_to_coast);
        end

        if upperlim>100
            upperlim = 100;
        end

        xlim([-1 upperlim])
        xlabel('Distance to shore [km]')
        ylabel('Elevation [m]')

        title([filename; string(trackdate)], 'Interpreter', 'none')

        subplot(2,4,4)
        plot(1, 1, 'Color', 'b')
        hold on
        plot(1,1,'Color', [230, 184, 252]/256)
        plot(1,1, 'Color', [172, 2, 250]/256)
        plot(1,1, 'Color', [89, 44, 110]/256)
        plot(1,1, 'Color',[166, 111, 2]/256)
        hold off
        title(num2str(n))
        legend('Corrected surface height', 'Keel Lowest Estimate', 'Keel Highest Estimate', 'Keel Best Estimate', 'Bathymetry', 'location', 'north')


        subplot(2, 4, 8)
        plot(coastline(1).X, coastline(1).Y, '-k');
        hold on
        plot(tracklon, tracklat, '.r')
        hold off
        grid on

        set(gcf, 'position', [ 320 337 1430 527])
        savefig([basin '_' filename(7:41)])

        disp('Completed:')
        disp(n)
        disp(length(tracklat))
        disp(max(distances_to_coast))
        disp(filename)
        catch
      % if there is an error in processing a particular track, note that
      % track as a problem and continue on to the next. 
        disp('error in track')
        disp(n)
        badtracklist = [badtracklist n];

        end

end
