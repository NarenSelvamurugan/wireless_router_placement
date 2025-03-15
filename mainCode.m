function NumofPoints = objectiveFunction(xy)

xpos = [];
ypos = [];
for i = 1:2:length(xy)
    xpos = [xpos xy(i)];
    ypos = [ypos xy(i+1)];
end

txArraySize = [1 1];
rxArraySize = [1 1];
fc = 2.4e9;
staSeparation = 0.5;

% Create environment
STAs = helperFunction(rxArraySize, staSeparation, "uniform", fc);
lambda = physconst("lightspeed")/fc;
txArray = arrayConfig("Size", txArraySize, "ElementSpacing", 2*lambda);

for i = 1:length(xpos)
    APs(i) = txsite("cartesian", ...
        "Antenna", txArray, ...
        "AntennaPosition", [xpos(i); ypos(i); 2.1], ...
        "TransmitterFrequency", fc, ...
        TransmitterPower=1);
end

show(APs);


pm = propagationModel("raytracing", ...
    "CoordinateSystem", "cartesian", ...
    "SurfaceMaterial", "wood", ...
    "MaxNumReflections", 1);

% Calculate Signal Strength
sigS = sigstrength(STAs, APs, pm);
if ~(length(xy) == 2)
    sigS=max(sigS);
end

NumofPoints=-sum(sigS>-30);

disp(['xPos: ', num2str(xpos), ', yPos: ', num2str(ypos), ', Number of Served Points: ', num2str(-NumofPoints), '/480']);
hide(APs);

end

% Main script
mapFileName = "office.stl";
viewer = siteviewer("SceneModel", mapFileName, "Transparency", 0.25);
S = RandStream("mt19937ar", "Seed", 5489); % Set the RNG for reproducibility
RandStream.setGlobalStream(S);


% Main script
% Define the bounds for x and y
inp = input("Enter maximum number of APs you can place in the office:");
l = [0.1,0.1];
u = [4.9,7.9];

ansFinalSignalStrength = zeros(1,inp);
ansFinalPosition = cell(1,inp);

for i = 1:inp
    lb = repmat(l,1,i);
    ub = repmat(u,1,i);
    len = length(lb);
    % Set options for the genetic algorithm
    options = optimoptions('ga', ...
        'Display', 'iter', ...
        'MaxGenerations', 2, ...
        'PopulationSize', 15, ...
        'FunctionTolerance', 0.1, ...
        'UseParallel', false);

    % Run the genetic algorithm
    [positon, fval] = ga(@objectiveFunction, len, [], [], [], [], lb, ub, [], options);

    % Display the results
    fprintf('Optimal position: %.4f\n', positon);
    fprintf('Highest number of Served Points: %.4f\n', -fval); % Negate if maximizin
    ansFinalSignalStrength(i) = -fval;
    ansFinalPosition{i} = positon;
end

visualizeResults(ansFinalSignalStrength,ansFinalPosition);

%% Visualization.

function visualizeResults(ansFinalSignalStrength,ansFinalPosition)
    close all force;
    txArraySize = [1 1]; % Linear transmit array
    fc = 2.4e9;
    lambda = physconst("lightspeed")/fc;
    txArray = arrayConfig("Size", txArraySize, "ElementSpacing", 2*lambda);
    
    mapFileName = "office.stl";
    viewer = siteviewer("SceneModel", mapFileName, "Transparency", 0.25);
    [~,ind] = max(ansFinalSignalStrength);
    positionValues = ansFinalPosition{ind};
    xposition = positionValues(1:2:end);
    yposition = positionValues(2:2:end);
    for i = 1:length(yposition)
        APFinal(i) = txsite("cartesian", ...
            "Antenna", txArray, ...
            "AntennaPosition", [xposition(i); yposition(i); 2.1], ...
            "TransmitterFrequency", fc, ...
            TransmitterPower=1);
    end
    show(APFinal);
    
    STAs = helperFunction([1 1], 0.5, "uniform", fc);
    pm = propagationModel("raytracing", ...
        "CoordinateSystem", "cartesian", ...
        "SurfaceMaterial", "wood", ...
        "MaxNumReflections", 1);
    
    sigFinal = sigstrength(STAs,APFinal,pm);
    ant = [STAs.AntennaPosition];
    
    x = ant(1,:);
    y = ant(2,:);
    x= reshape(x,[16,10,3]);
    y= reshape(y,[16,10,3]);
    [X,Y] = meshgrid(x(1,:,1),y(:,1,1));
    sMax = sigFinal;
    if ind~=1
        sMax= max(sigFinal);
    end
    sMax=reshape(sMax,[16,10,3]);
    surf(X,Y,sMax(:,:,1),'FaceColor','interp');
    title('Coverage at Z = 0.8m');
    xlabel('width of room');
    ylabel('length of room');
    zlabel('RSSI (dBm)');
    colorbar;
    figure;surf(X,Y,sMax(:,:,2),'FaceColor','interp');
    title('Coverage at Z = 1.3m');
    xlabel('width of room');
    ylabel('length of room');
    zlabel('RSSI (dBm)');
    colorbar;
    figure;surf(X,Y,sMax(:,:,3),'FaceColor','interp');
    title('Coverage at Z = 1.8m');
    xlabel('width of room');
    ylabel('length of room');
    zlabel('RSSI (dBm)');
    colorbar;
end

