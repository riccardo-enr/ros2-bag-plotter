function plot_velocity_over_time(data)
    % Create a simple time vector based on index
    time = (1:height(data))';

    % Extract velocity components from NED
    vx_ned = data.x_fmu_out_vehicle_odometry_velocity_0_; % North
    vy_ned = data.x_fmu_out_vehicle_odometry_velocity_1_; % East
    vz_ned = data.x_fmu_out_vehicle_odometry_velocity_2_; % Down

    % Compute instantaneous speed
    speed = sqrt(vx_ned.^2 + vy_ned.^2 + vz_ned.^2);

    % Plot speed over time
    figure('Color', 'white'); % Set background to white
    plot(time, speed, 'b-', 'LineWidth', 1.5); % Plot speed in blue line

    % Configure the plot
    grid on;
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Speed (m/s)', 'FontWeight', 'bold');
    title('UAV Speed Over Time', 'FontSize', 14, 'FontWeight', 'bold');
end
