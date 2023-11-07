%% Transform conditions into single vectors
% Gregory Gutmann (15.11.22)

%{
Replaces codes from Donald G. McLaren and Aaron Schulz. As scan timing
instead of microtiming (which takes account for the different slices) was
used, it was possible to simplify the code.
%}

function PSY = design_vectors(SPM,sess,N,RT)

% Create empty PSY for design vectors
PSY             = [];

% Iterates over conditions
for c=1:length(SPM.Sess(sess).U)

    % Get onset and duration of respective condition
    ons             = SPM.Sess(sess).U(c).ons;
    durs            = SPM.Sess(sess).U(c).dur;

    % Create design vector by itearting over onsets and durations
    psy             = [];
    for i=1:length(ons)
        
        % Onset of singular block
        on          = round(ons(i)/RT);
    
        % Singular duration (in case duration is differently defined)
        if length(durs) == length(ons)
            dur         = round(durs(i)/RT);
        else
            dur         = round(durs(i)/RT);
        end
    
        % Add together design vector
        psy             = [psy; zeros(on-length(psy),1); ones(dur,1)];
    end

    % Fill up design vector to the end
    psy             = [psy; zeros(N-length(psy),1)];

    % Add to PSY
    PSY             = [PSY psy];

end