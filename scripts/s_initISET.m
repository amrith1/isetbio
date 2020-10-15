%% s_initISET
%
% Deprecated.  Use ieInit instead.
%
% It is often convenient to use s_initISET at the head of a script, even though
% it is not required.  This script 
%   * Closes down previous instantiations of ISET
%   * Clears the workspace
%   * Starts a fresh version
%   * Hides the main window
%
% We might want to clear out the ISET session file to prevent it from
% loading with the new ISET session.
%
% Copyright ImagEval Consultants, LLC, 2011.

%% Call ieInit
ieInit;

%%