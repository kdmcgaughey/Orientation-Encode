%% Setup Path
addpath('./CircStat/');
addpath('./ExpData/');

%% Load Data
fileName = '10_11_2020_18_04_LQ_0.csv';
% fileName = '11_11_2020_09_08_LQ_0.csv';
dataMtx  = readmatrix(fileName);

% Analysis
% moving average bin size
binSize = 18;

numBlock = 3;
blockLength = 200;

plotAll(dataMtx, numBlock, blockLength, binSize);

%% Helper Function
function plotAll(dataMtx, numBlock, blockLength, binSize)
    figure();
    for idx = 1 : numBlock
        subplot(1, 3, idx);
        result = analysisBlock(dataMtx, 'blockIndex', idx, 'blockLength', blockLength, 'binSize', binSize);
        scatterPlot(result);
    end
end