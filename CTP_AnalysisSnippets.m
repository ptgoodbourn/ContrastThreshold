addpath(genpath('/Users/experimentalmode/Documents/MATLAB/Toolboxes/PsychMods/'));
cd('/Users/experimentalmode/Documents/MATLAB/ContrastThreshold/Data_CTP');
fileName = 'DSFSF_Data_CTP.mat';

stimulus.spatialFrequencies_cpd = [0.5 2.0 5.0 16.0];   % Spatial frequencies (c/dva)
stimulus.temporalFrequencies_Hz = [2.0 8.0 20.0];       % Temporal frequencies (Hz)

nSpatialFrequencies = numel(stimulus.spatialFrequencies_cpd);
nTemporalFrequencies = numel(stimulus.temporalFrequencies_Hz);

load(fileName);

figure('Color','White');
staircaseAxis = [-1 30 -3 0];
sensAxis_Abs = [0 4 0.5 4.5 0 NaN];
sensView_Abs = [-45 50];
sensAxis_Rel = [0 4 0.5 4.5 0 5];
sensView_Rel = [-45 50];

gridRows = 5;
gridCols = 6;
staircaseGridPos = [1:3 7:9 13:15 19:21];
bBandStaircaseGridPos = 26;
sensGridPos_Abs = [4:6 10:12];
sensGridPos_Rel = [22:24 28:30];
barWidth = 0.5;

allSensitivities = NaN(nSpatialFrequencies, nTemporalFrequencies);
allLogThresholds = NaN(nSpatialFrequencies, nTemporalFrequencies);
allCIs = NaN(nSpatialFrequencies, nTemporalFrequencies, 2);

% Broadband staircase
subplot(gridRows, gridCols, bBandStaircaseGridPos);
hold on;

for thisStaircase = 1:2
    plot(pdata(thisStaircase).intensity(1:pdata(thisStaircase).trialCount));
end

thisQ1 = pdata(1);
nQ1 = thisQ1.trialCount;
thisQ2 = pdata(2);
nQ2 = thisQ2.trialCount;
thisQ1.trialCount = nQ1 + nQ2;
thisQ1.intensity((nQ1+1):(nQ1+nQ2)) = thisQ2.intensity(1:nQ2);
thisQ1.response((nQ1+1):(nQ1+nQ2)) = thisQ2.response(1:nQ2);
thisQ = QuestRecompute(thisQ1);
[beta,logt,sd,ci] = QuestBetaAnalysis_ReturnThresholdQuantile(thisQ);

if logt <= 0
    s = 1/(10.^logt);
    ci = 1./(10.^ci);
else
    logt = NaN;
    s = NaN;
    ci = NaN(1,2);
end

broadBandSensitivity = s;
broadBandLogThreshold = logt;
broadBandCIs = ci;

plot([0 nQ1],logt*ones(1,2),'r:');
axis square;
axis(staircaseAxis);
title('Broadband');

% Narrowband staircases
thisStaircaseFigure = 1;

for thisSpatialFrequency = 1:4
    
    for thisTemporalFrequency = 1:3
        
        subplot(gridRows, gridCols, staircaseGridPos(thisStaircaseFigure));
        thisStaircaseFigure = thisStaircaseFigure + 1;
        hold on;
        
        for thisStaircase = 1:2
            plot(data(thisSpatialFrequency,thisTemporalFrequency,thisStaircase).intensity(1:data(thisSpatialFrequency,thisTemporalFrequency,thisStaircase).trialCount));
        end
        
        thisQ1 = data(thisSpatialFrequency,thisTemporalFrequency,1);
        nQ1 = thisQ1.trialCount;
        thisQ2 = data(thisSpatialFrequency,thisTemporalFrequency,2);
        nQ2 = thisQ2.trialCount;
        thisQ1.trialCount = nQ1 + nQ2;
        thisQ1.intensity((nQ1+1):(nQ1+nQ2)) = thisQ2.intensity(1:nQ2);
        thisQ1.response((nQ1+1):(nQ1+nQ2)) = thisQ2.response(1:nQ2);
        thisQ = QuestRecompute(thisQ1);
        [beta,logt,sd,ci] = QuestBetaAnalysis_ReturnThresholdQuantile(thisQ);

        if logt <= 0
            s = 1/(10.^logt);
            ci = 1./(10.^ci);
        else
            logt = NaN;
            s = NaN;
            ci = NaN(1,2);
        end
        
        allSensitivities(thisSpatialFrequency,thisTemporalFrequency) = s;
        allLogThresholds(thisSpatialFrequency,thisTemporalFrequency) = logt;
        allCIs(thisSpatialFrequency,thisTemporalFrequency,:) = ci;
        
        plot([0 nQ1],logt*ones(1,2),'r:');
        axis square;
        axis(staircaseAxis);
        thisTitle = [num2str(stimulus.spatialFrequencies_cpd(thisSpatialFrequency),'%.1f')...
            ' cpd, ' num2str(stimulus.temporalFrequencies_Hz(thisTemporalFrequency),'%.1f') ' Hz'];
        title(thisTitle);
        
    end
end

% Summary bar plot
subplot(gridRows,gridCols,sensGridPos_Abs);
sensPlot = bar3(allSensitivities, barWidth);
maxSens = max(allSensitivities(:));
maxAxis = 100*ceil(maxSens/100);
sensAxis_Abs(6) = maxAxis;
axis(sensAxis_Abs);
aX = gca;
aX.View = sensView_Abs;
zlabel('Sensitivity');
ylabel('Fs (cpd)');
xlabel('Ft (Hz)');
xticklabels({'2','8','20'});
yticklabels({'.5','2','5','16'});
cBar = colorbar;
cBar.Location = 'east';
cBar.Position(3) = 0.5*cBar.Position(3);
cBar.Position(1) = cBar.Position(1) + cBar.Position(3);
cBar.Limits = sensAxis_Abs(5:6);
cBar.YAxisLocation = 'right';

for thisBar = 1:length(sensPlot)
    sensPlot(thisBar).CData = sensPlot(thisBar).ZData;
    sensPlot(thisBar).FaceColor = 'interp';
end

axis square;
title('Absolute Sensitivity');

% Summary bar plot (relative to broadband)
subplot(gridRows,gridCols,sensGridPos_Rel);
allDifference = allLogThresholds-broadBandLogThreshold;
sensPlot = bar3(allDifference, barWidth);
maxDifference = max(abs(allDifference(:)));
maxAxis = 0.5*ceil(maxDifference/0.5);
sensAxis_Rel(5:6) = maxAxis*[-1 1];
axis(sensAxis_Rel);
aX = gca;
aX.View = sensView_Rel;
zlabel('\DeltaThreshold');
ylabel('Fs (cpd)');
xlabel('Ft (Hz)');
xticklabels({'2','8','20'});
yticklabels({'.5','2','5','16'});
cBar = colorbar;
cBar.Location = 'east';
cBar.Position(3) = 0.5*cBar.Position(3);
cBar.Position(1) = cBar.Position(1) + cBar.Position(3);
cBar.YDir = 'reverse';
cBar.Limits = sensAxis_Rel(5:6);
cBar.YAxisLocation = 'right';

for thisBar = 1:length(sensPlot)
    sensPlot(thisBar).CData = sensPlot(thisBar).ZData;
    sensPlot(thisBar).FaceColor = 'interp';
end

set(gca,'ZDir','reverse');
axis square;
title('Relative Threshold');