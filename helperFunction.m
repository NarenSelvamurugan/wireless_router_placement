function STAs = helperFunction(rxArraySize, val, distribution,fc)


lambda = physconst("lightspeed")/fc;

rxArray = arrayConfig("Size", rxArraySize, "ElementSpacing", lambda);

% Create array of corordinates that will be used for tx locations.
% By default these are the 0.1m away from each corner of the office.


% Define valid space for STAs
xSTA = [0.1 4.9];
ySTA = [0.1 7.9];
zSTA = [0.8 1.8];

dX = diff(xSTA);
dY = diff(ySTA);
dZ = diff(zSTA);
dims = [dX dY dZ];


if distribution=="uniform"
    % Create uniform grid within bounded range of valid STA locations

    % Offset each dimension so grid is centered
    rxSep = val;
    numSeg = floor(dims/rxSep);
    dimsOffset = (dims-(numSeg*rxSep))./2;  
    xGridSTA = (min(xSTA)+dimsOffset(1)):rxSep:(max(xSTA)-dimsOffset(1));
    yGridSTA = (min(ySTA)+dimsOffset(2)):rxSep:(max(ySTA)-dimsOffset(2));
    zGridSTA = (min(zSTA)+dimsOffset(3)):rxSep:(max(zSTA)-dimsOffset(3));

    % Set the position of the STA antenna centroid by replicating the
    % Position vectors across 3D space.
    antPosSTA = [repmat(kron(xGridSTA, ones(1, length(yGridSTA))), 1, length(zGridSTA)); ...
              repmat(yGridSTA, 1, length(xGridSTA)*length(zGridSTA)); ...
              kron(zGridSTA, ones(1, length(yGridSTA)*length(xGridSTA)))];
else 
    % Randomly assign n STA positions bounded by the range of valid STA locations
    numSTA = val;
    antPosSTA = [((max(xSTA)-min(xSTA)).*rand(numSTA, 1)+min(xSTA))';
                ((max(ySTA)-min(ySTA)).*rand(numSTA, 1)+min(ySTA))';
                ((max(zSTA)-min(zSTA)).*rand(numSTA, 1)+min(zSTA))'];
end


% Name each STA according to its location
labels = strings(1,size(antPosSTA,2));
for i = 1:size(antPosSTA,2)
   labels(i) =  AssignLabel(antPosSTA(:,i));
end

STAs = rxsite("cartesian", ...
    "Antenna", rxArray, ...
    "AntennaPosition", antPosSTA, ...
    "AntennaAngle", [0;90], ...
    "Name", labels);
end

function label = AssignLabel(x)
% Label a position based on its location in the office environment.
    if x(2) <= 2.75
       label = "conference_room";
    elseif x(2) >= 6.5 && x(1) > 0.5 && x(1) <= 2.5
            label = "desk1";
    elseif x(2) >= 6.5 && x(1) > 2.5
            label = "desk2";
    elseif x(2) < 6.5 && x(2) >= 4.5 && x(1) >= 3.5
            label = "desk3";
    elseif x(2) < 4.5 && x(2) > 2.75 && x(1) >= 3.5
            label = "desk4";
    elseif x(2) > 2.75 && x(1) <= 0.5
            label = "storage";
    else
            label = "office";
    end
end

 