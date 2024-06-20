function [thick] = fdd_thickness(date, basin)
% use C or B for Chukchi side or Beaufort side

if basin== 'C'
    load heightChuk.mat
    heightdata = heightsChuk;
    clear heightsChuk;
else
    load heightBeau.mat
    heightdata = heights;
    clear heights;
end

% find the row for the date
dates = heightdata.date;

rowindex = find(date == dates);
thicknesses = table2array(heightdata(rowindex, 2:end));

thick = mean(thicknesses, 'omitnan');


end
