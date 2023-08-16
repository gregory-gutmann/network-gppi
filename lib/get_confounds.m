%{
Note by Gregory Gutmann (30.11.22)
Function was directly taken from the PPPI-Package written by Donald G. McLaren
and Aaron Schulz 
    % $Id: get_cofounds.m
    % Copyright (c) 2011, Donald G. McLaren and Aaron Schultz
    % Donald G. McLaren and Aaron Schultz
%}


function [xY,y]=get_confounds(SPM,xY,y)
        % confounds
        %-----------------------------------------------------------------------
        xY.X0     = SPM.xX.xKXs.X(:,[SPM.xX.iB SPM.xX.iG]);
        
        % extract session-specific rows from data and confounds
        %-----------------------------------------------------------------------
        try
            i     = SPM.Sess(xY.Sess).row;
            if exist('y','var')
                y     = y(i,:);
            end
            xY.X0 = xY.X0(i,:);
        catch
        end
        
        % and add session-specific filter confounds
        %-----------------------------------------------------------------------
        try
            xY.X0 = [xY.X0 SPM.xX.K(xY.Sess).X0];
        catch
        end
        
        %=======================================================================
        try
            xY.X0 = [xY.X0 SPM.xX.K(xY.Sess).KH]; % Compatibility check
        catch
        end
        
        %=======================================================================
        % Remove null space of X0
        %-----------------------------------------------------------------------
        xY.X0   = xY.X0(:,~~any(xY.X0));
end