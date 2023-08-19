%% Transform conditions into single vectors
% Gregory Gutmann (15.11.22)

%{
Code was directly taken from PPPI.m script written by Donald G. McLaren
and Aaron Schulz and only slightly edited (part of PPPI-package)
    $Id: PPPI.m
    Copyright (c) 2011, Donald G. McLaren and Aaron Schultz
    Donald G. McLaren and Aaron Schultz
%}

function PSY = psy_parameter(Sess_U,tasks, N, NT)
    
u                       = length(Sess_U);
U.name                  = {};
U.u                     = [];
U.w                     = [];

T                       = zeros(numel(tasks)-1,1);
I                       = zeros(numel(tasks)-1,1);
TASK_Match              = [];
for j=2:numel(tasks)
    for jj = 1:numel(Sess_U)
        TASK_match          = 0;
        if strcmp(tasks{j},Sess_U(jj).name(1))
            T(j)                = jj;
            I(j)                = j; 
            TASK_match          = 1;
            TASK_Match(end+1)   = 1;
            break
        end
    end
end

I=I(I~=0);
T=T(T~=0);
for i = 1:numel(T)
    for j = 1:length(Sess_U(T(i)).name)
        if any(Sess_U(T(i)).u(33:end,j))
            U.u                 = [U.u Sess_U(T(i)).u(33:end,j)];
            U.name{end + 1}     = Sess_U(T(i)).name{j};
            U.w                 = 1;
        end
    end
end
for i = 1:size(U.u,2)
    PSY(:,i)                = zeros(N*NT,1);
    PSY(:,i)	            = PSY(:,i) + full(U.u(:,i)*U.w);
end

