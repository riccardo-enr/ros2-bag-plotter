clear;
close all;
clc;

[file, path] = uigetfile('../data/*.csv', 'Select a CSV file');
if isequal(file, 0)
    disp('User canceled the file selection.');
    return;
end
fullFileName = fullfile(path, file);

data = readtable(fullFileName);

%% Plot UAV 3D position
% Extract odometry position data
x_ned = data.x_fmu_out_vehicle_odometry_position_0_; % North
y_ned = data.x_fmu_out_vehicle_odometry_position_1_; % East
z_ned = data.x_fmu_out_vehicle_odometry_position_2_; % Down

% Interpolate missing data (fill NaNs)
time = (1:length(x_ned))'; % Create a simple time vector based on index

x_ned = fillmissing(x_ned, 'linear', 'SamplePoints', time);
y_ned = fillmissing(y_ned, 'linear', 'SamplePoints', time);
z_ned = fillmissing(z_ned, 'linear', 'SamplePoints', time);

% Convert from NED to ENU
x_enu = y_ned;     % East
y_enu = x_ned;     % North
z_enu = -z_ned;    % Up

% Plot the 3D odometry data as a line
figure;
plot3(x_enu, y_enu, z_enu, 'b-', 'LineWidth', 1.5); % Odometry in blue line

% Configure the plot
grid on;
xlabel('X Position (East)');
ylabel('Y Position (North)');
zlabel('Z Position (Up)');
title('3D Plot of UAV');
legend('Odometry');

