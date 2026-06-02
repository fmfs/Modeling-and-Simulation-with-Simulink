%% Module 01: Introduction & Programmatic Simulink Basics
% Description: This script demonstrates how to create a Simulink model, 
% add source/sink blocks, route signals, and execute a simulation 
% entirely via MATLAB code expressions.
% Reference: Dingyü Xue - Modeling and Simulation with Simulink

clear; clc; close all;

%% 1. Initialize and Create a New Simulink Canvas
modelName = 'automated_basics_demo';

% If the model is already open or exists in memory, close it without saving
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end

% Create a fresh, empty canvas
new_system(modelName);
open_system(modelName);

fprintf('Successfully initialized new system: %s\n', modelName);

%% 2. Add System Blocks (Sources, Routes, and Sinks)
% Syntax: add_block('SourceBlockPath', 'TargetBlockPath', 'ParameterName', Value, ...)

% Add a Sine Wave Source Generator
add_block('simulink/Sources/Sine Wave', [modelName, '/SineSource'], ...
    'Position', [50, 100, 100, 140], ...
    'Amplitude', '2.5', ...
    'Frequency', '2*pi*0.5'); % 0.5 Hz frequency

% Add a Gain Multiplier Block (Scales the input signal)
add_block('simulink/Math Operations/Gain', [modelName, '/SignalGain'], ...
    'Position', [180, 105, 220, 135], ...
    'Gain', '3');

% Add a To Workspace Sink Block (Sends output arrays directly to MATLAB)
add_block('simulink/Sinks/To Workspace', [modelName, '/WorkspaceSink'], ...
    'Position', [300, 105, 360, 135], ...
    'VariableName', 'sim_output_data', ...
    'SaveFormat', 'Timeseries');

fprintf('Blocks placed inside canvas with custom spatial coordinates.\n');

%% 3. Establish Signal Line Connections
% Syntax: add_line('ModelName', 'SourceBlock/PortNumber', 'DestinationBlock/PortNumber')

% Connect SineSource Output (Port 1) to SignalGain Input (Port 1)
add_line(modelName, 'SineSource/1', 'SignalGain/1');

% Connect SignalGain Output (Port 1) to WorkspaceSink Input (Port 1)
add_line(modelName, 'SignalGain/1', 'WorkspaceSink/1');

fprintf('Signal connections successfully routed.\n');

%% 4. Programmatic Simulation Setup and Execution
fprintf('Configuring solver parameters and executing simulation...\n');

% Set model parameters via the SimulationInput API
simConfig = Simulink.SimulationInput(modelName);
simConfig = simConfig.setModelParameter('StopTime', '10.0');      % Run for 10 seconds
simConfig = simConfig.setModelParameter('Solver', 'ode45');        % Run variable-step solver

% Execute the simulation setup
simResults = sim(simConfig);

fprintf('Simulation execution completed safely!\n');

%% 5. Extract and Plot Workspace Simulation Outputs
% Extract the timeseries object captured during the run
outputData = simResults.get('sim_output_data');

timeVector = outputData.Time;
signalValues = outputData.Data;

% Generate a high-quality visualization plot of the results
figure('Color', [1 1 1]);
plot(timeVector, signalValues, 'LineWidth', 2, 'Color', [0 0.4470 0.7410]);
grid on;
title('Programmatic Simulink Model Execution Result', 'FontSize', 12);
xlabel('Time (Seconds)', 'FontSize', 10);
ylabel('Amplitutes (Scaled Outputs)', 'FontSize', 10);
legend('Scaled Output Signal (Gain = 3)', 'Location', 'best');

% Save model canvas state and close window clean-up
save_system(modelName);
fprintf('Demo script execution complete. Model file saved as %s.slx\n', modelName);
