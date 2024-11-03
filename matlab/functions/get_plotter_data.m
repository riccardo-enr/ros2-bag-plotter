function fullFileName = get_plotter_data(varargin)
% Check if a CSV file is provided as a command-line argument
if nargin > 0
    fullFileName = varargin{1};
    if ~isfile(fullFileName)
        error('The specified file does not exist.');
    end
else
    % Prompt the user to select a CSV file
    [file, path] = uigetfile('../data/*.csv', 'Select a CSV file');
    if isequal(file, 0)
        disp('User canceled the file selection.');
        return;
    end
    fullFileName = fullfile(path, file);
end