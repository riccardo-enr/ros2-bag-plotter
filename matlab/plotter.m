clear;
close all;
clc;

fullFileName = get_plotter_data("../data/csv_converted/sitl_1.csv");

% Read the CSV data
data = readtable(fullFileName);

%% Extract Actual UAV Position Data
% Ensure required columns are present
requiredCols = {'x_fmu_out_vehicle_odometry_position_0_', ...
                'x_fmu_out_vehicle_odometry_position_1_', ...
                'x_fmu_out_vehicle_odometry_position_2_'};
if all(ismember(requiredCols, data.Properties.VariableNames))
    x_ned = data.x_fmu_out_vehicle_odometry_position_0_; % North
    y_ned = data.x_fmu_out_vehicle_odometry_position_1_; % East
    z_ned = data.x_fmu_out_vehicle_odometry_position_2_; % Down
else
    error('Required odometry columns are not present in the selected file.');
end

% Interpolate missing actual position data
time = (1:length(x_ned))'; % Create a simple time vector based on index
x_ned = fillmissing(x_ned, 'linear', 'SamplePoints', time);
y_ned = fillmissing(y_ned, 'linear', 'SamplePoints', time);
z_ned = fillmissing(z_ned, 'linear', 'SamplePoints', time);

% Convert actual position from NED to ENU
x_enu = y_ned;     % East
y_enu = x_ned;     % North
z_enu = -z_ned;    % Up

%% Extract Reference Position Data
% Ensure reference columns are present
refCols = {'x_debug_ref_pose_pose_position_x', ...
           'x_debug_ref_pose_pose_position_y', ...
           'x_debug_ref_pose_pose_position_z'};
if all(ismember(refCols, data.Properties.VariableNames))
    x_ref_ned = data.x_debug_ref_pose_pose_position_x; % North
    y_ref_ned = data.x_debug_ref_pose_pose_position_y; % East
    z_ref_ned = data.x_debug_ref_pose_pose_position_z; % Down
else
    error('Required reference position columns are not present in the selected file.');
end

% Interpolate missing reference position data
x_ref_ned = fillmissing(x_ref_ned, 'linear', 'SamplePoints', time);
y_ref_ned = fillmissing(y_ref_ned, 'linear', 'SamplePoints', time);
z_ref_ned = fillmissing(z_ref_ned, 'linear', 'SamplePoints', time);

% Convert reference position from NED to ENU
x_ref_enu = y_ref_ned;     % East
y_ref_enu = x_ref_ned;     % North
z_ref_enu = -z_ref_ned;    % Up

%% Compute RMSE for Each Axis
% Calculate the differences
diff_x = x_enu - x_ref_enu;
diff_y = y_enu - y_ref_enu;
diff_z = z_enu - z_ref_enu;

% Compute RMSE for each axis
rmse_x = sqrt(mean(diff_x.^2));
rmse_y = sqrt(mean(diff_y.^2));
rmse_z = sqrt(mean(diff_z.^2));

% Compute cumulative RMSE
rmse_total = sqrt(rmse_x^2 + rmse_y^2 + rmse_z^2);

%% Plot the 3D Trajectories
figure('Color', 'white'); % Set background to white for better visibility
plot3(x_enu, y_enu, z_enu, 'b-', 'LineWidth', 1.5); % Actual trajectory in blue
hold on;
plot3(x_ref_enu, y_ref_enu, z_ref_enu, 'r--', 'LineWidth', 1.5); % Reference trajectory in red dashed line

% Configure the plot
grid on;
xlabel('X Position (East)', 'FontWeight', 'bold');
ylabel('Y Position (North)', 'FontWeight', 'bold');
zlabel('Z Position (Up)', 'FontWeight', 'bold');
title('3D Plot of UAV Trajectory vs. Reference', 'FontSize', 14, 'FontWeight', 'bold');
legend('Actual Trajectory', 'Reference Trajectory', 'Location', 'best');
% axis equal
view(3); % Set a 3D view for better visualization

% Display RMSE values on the plot
rmse_text = sprintf('RMSE_x: %.4f\nRMSE_y: %.4f\nRMSE_z: %.4f\nTotal RMSE: %.4f', ...
                    rmse_x, rmse_y, rmse_z, rmse_total);
text('Units', 'normalized', 'Position', [0.9, 0.1, 0], 'String', rmse_text, ...
     'BackgroundColor', 'white', 'EdgeColor', 'black', 'FontSize', 10);

hold off;

%% Extract Velocity Components from Odometry Data
% Ensure required columns are present
requiredCols = {'x_fmu_out_vehicle_odometry_velocity_0_', ...
                'x_fmu_out_vehicle_odometry_velocity_1_', ...
                'x_fmu_out_vehicle_odometry_velocity_2_'};
if all(ismember(requiredCols, data.Properties.VariableNames))
    vx_ned = data.x_fmu_out_vehicle_odometry_velocity_0_; % Velocity in North direction
    vy_ned = data.x_fmu_out_vehicle_odometry_velocity_1_; % Velocity in East direction
    vz_ned = data.x_fmu_out_vehicle_odometry_velocity_2_; % Velocity in Down direction
else
    error('Required velocity columns are not present in the selected file.');
end

% Interpolate missing velocity data
time = (1:length(vx_ned))'; % Create a simple time vector based on index
vx_ned = fillmissing(vx_ned, 'linear', 'SamplePoints', time);
vy_ned = fillmissing(vy_ned, 'linear', 'SamplePoints', time);
vz_ned = fillmissing(vz_ned, 'linear', 'SamplePoints', time);

%% Compute Instantaneous Speed
% Speed is the magnitude of the velocity vector
speed = sqrt(vx_ned.^2 + vy_ned.^2 + vz_ned.^2);

%% Plot Speed Over Time
figure('Color', 'white'); % Set background to white for better visibility
plot(time, speed, 'b-', 'LineWidth', 1.5); % Plot speed in blue line

% Configure the plot
grid on;
xlabel('Time (s)', 'FontWeight', 'bold');
ylabel('Speed (m/s)', 'FontWeight', 'bold');
title('UAV Speed Over Time', 'FontSize', 14, 'FontWeight', 'bold');

%% NMPC Histogram
% Check if the 'x_nmpc_time_tot_data' column exists in the data
if ismember('x_nmpc_time_tot_data', data.Properties.VariableNames)
    % Extract NMPC solve times
    solve_times = data.x_nmpc_time_tot_data;
    
    % Remove any NaN values
    solve_times = solve_times(~isnan(solve_times));
    
    % Calculate mean and standard deviation
    mean_solve_time = mean(solve_times);
    std_solve_time = std(solve_times);
    
    % Plot the histogram with relative frequency
    figure('Color', 'white'); % Set background to white
    histogram(solve_times, 'Normalization', 'probability', ...
              'FaceColor', [0.2 0.2 0.8], 'EdgeColor', 'black');
    hold on;
    
    % Overlay the Gaussian fit
    x_values = linspace(min(solve_times), max(solve_times), 100);
    y_values = normpdf(x_values, mean_solve_time, std_solve_time);
    % Scale the Gaussian fit to match the histogram's relative frequency
    y_values = y_values * (max(histcounts(solve_times, 'Normalization', 'probability')) / max(y_values));
    plot(x_values, y_values, 'r--', 'LineWidth', 2);
    
    % Display mean and standard deviation on the plot
    stats_text = sprintf('Mean: %.4f s\nStd Dev: %.4f s', mean_solve_time, std_solve_time);
    text('Units', 'normalized', 'Position', [0.95, 0.85], 'String', stats_text, ...
         'BackgroundColor', 'white', 'EdgeColor', 'black', 'FontSize', 10);
    
    % Configure the plot
    grid on;
    xlabel('NMPC Solve Time (seconds)', 'FontWeight', 'bold');
    ylabel('Relative Frequency', 'FontWeight', 'bold');
    title('Histogram of NMPC Solve Times with Gaussian Fit', 'FontSize', 14, 'FontWeight', 'bold');
    legend('Solve Times Histogram', 'Gaussian Fit', 'Location', 'best');
    hold off;
else
    error('The selected file does not contain a ''x_nmpc_time_tot_data'' column.');
end

