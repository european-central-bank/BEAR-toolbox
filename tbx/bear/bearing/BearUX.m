classdef BearUX < matlab.task.LiveTask
    % Add summary here

    % NOTE: To register/update your task, run matlab.task.configureMetadata
    % in command window. To de-register run matlab.task.removeMetadata
    % This class extends the base class LiveTask and provides the
    % implementation for all the abstract methods defined in the parent
    % class.

    properties(Access = private,Transient)
        % Declare UI elements here

    end

    properties(Dependent)
        % State property stores current state of UI objects in the task, specified as a struct.
        State

        % Task summary, specified as a string scalar or character vector.
        Summary
    end

    methods(Access = protected)
        function setup(task)
            % Method to set up the initial state of the task.
            % This method is called when the task is constructed.
            % Add your implementation here
        end
    end

    methods
        function [code,outputs] = generateCode(task)
            % Method to generate code and outputs for the task.
            % Construct code exclusively using information from this class.
            % Add your implementation here
            code = "";
            outputs = {};
        end

        function summary = get.Summary(task)
            % Define this method to get the Summary of the task.
            % This is used to dynamically generate the description of what the task does.
            summary = "";
        end

        function state = get.State(task)
            % Used along with jsonencode for serialization of task
            state = struct;
        end

        function set.State(task,state)
            % Used along with jsondecode for task restoration
        end

        function reset(task)
            % This method is called when a user restores the default values
            % of the task by clicking the options button
        end
    end
end