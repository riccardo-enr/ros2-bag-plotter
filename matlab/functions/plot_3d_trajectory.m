function plot_3d_trajectory(data)
    % Extract and convert position data from NED to ENU
    x_enu = data.x_fmu_out_vehicle_odometry_position_1_; % East
    y_enu = data.x_fmu_out_vehicle_odometry_position_0_; % North
    z_enu = -data.x_fmu_out_vehicle_odometry_position_2_; % Up

    x_ref_enu = data.x_debug_ref_pose_pose_position_y; % East
    y_ref_enu = data.x_debug_ref_pose_pose_position_x; % North
    z_ref_enu = -data.x_debug_ref_pose_pose_position_z; % Up

    % Plot the 3D trajectories
    figure('Color', 'white'); % Set background to white
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
    view(3); % Set a 3D view for better visualization
    hold off;
end
