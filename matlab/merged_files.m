clear;
close all;
clc;

addpath("functions/")

fullFileName = get_plotter_data("../data/csv_converted/sitl_1.csv");
% Extract the name of the file without the path and extension
[~, fileName, ~] = fileparts(fullFileName);

% Create the folder path for the output (ensure the folder exists)
outputFolder = 'images';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder); % Create the folder if it doesn't exist
end

% Create a PNG file name based on the extracted file name and save it in the images folder
outputFileName = fullfile(outputFolder, strcat(fileName, '_nmpc_histogram.png'));

data = readtable(fullFileName);

plot_nmpc_histogram(data)
exportgraphics(gcf, outputFileName, 'Resolution', 600);