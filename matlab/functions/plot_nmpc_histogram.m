function plot_nmpc_histogram(data)
    % Check if NMPC solve times column exists
    if ismember('x_nmpc_time_tot_data', data.Properties.VariableNames)
        % Extract NMPC solve times and remove NaNs
        solve_times = data.x_nmpc_time_tot_data;
        solve_times = solve_times(~isnan(solve_times));

        % Calculate mean and standard deviation
        mean_solve_time = mean(solve_times);
        std_solve_time = std(solve_times);

        % Plot the histogram with relative frequency
        figure('Color', 'white'); % Set background to white
        histogram(solve_times, 30, 'Normalization', 'probability', ...
                  'FaceColor', [0.2 0.2 0.8], 'EdgeColor', 'black');
        hold on;

        % Overlay the Gaussian fit
        x_values = linspace(min(solve_times), max(solve_times), 100);
        y_values = normpdf(x_values, mean_solve_time, std_solve_time);
        y_values = y_values * (max(histcounts(solve_times, 'Normalization', 'probability')) / max(y_values));
        plot(x_values, y_values, 'r--', 'LineWidth', 2);

        % Configure the plot
        grid on;
        xlabel('NMPC Solve Time (seconds)', 'FontWeight', 'bold');
        ylabel('Relative Frequency', 'FontWeight', 'bold');
        title('NMPC Solve Times - Histogram', 'FontSize', 14, 'FontWeight', 'bold');

        % Create legend text with mean and standard deviation
        legend_text = sprintf('Gaussian Fit\nMean: %.4f s\nStd Dev: %.4f s', mean_solve_time, std_solve_time);
        legend('Solve Times Histogram', legend_text, 'Location', 'best');

        hold off;
    else
        error('The selected file does not contain a ''x_nmpc_time_tot_data'' column.');
    end
end
