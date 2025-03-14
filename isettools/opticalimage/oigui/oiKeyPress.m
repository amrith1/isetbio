function oiKeyPress
% Define optical image window key press callbacks
%
% Syntax:
%   oiKeyPress
%
% Description:
%    This routine is set as the call back for the optical image key press
%    interpretation the key mappings are defined as:
%       ctl-D -- Delete current optical image
%       ctl-N -- Edit optical image name
%       ctl-R -- Refresh OI window
%
%    This routine is not called from the command line.
%
% Inputs:
%    None.
%
% Outputs:
%    None.
%
% Optional key/value pairs:
%    None.
%

% History:
%    xx/xx/05       Copyright ImagEval Consultants, LLC, 2005.
%    03/19/18  jnm  Formatting
%    07/01/19  JNM  Commented out duplicate case 8 (Ctrl+H) vs bkspc/del

% Read the current key press from the buffer. A control key is empty on
% first entry. But a ctrl-Value gets read properly on second entry.
key = double(get(gcf, 'CurrentCharacter'));

if isempty(key), return; end

handles = guihandles;
eventData = [];
hObject = handles.figure1;

switch key
    case {8 127} % Backspace and Delete
    case 3  % ctrl-C
    case 4  % ctrl-D
       oiWindow('oiDelete', hObject, eventData, handles);
    case 5  % ctrl-E
    case 6  % ctrl-F
    case 7  % ctrl-G
    % case 8  % ctrl-H
    case 9  % ctrl-I
    case 10  % ctrl-J
    case 11  % ctrl-K
    case 12  % ctrl-L
    case 13  % ctrl-M
    case 14 % ctrl-N
        oiWindow('menuEditName_Callback', hObject, eventData, handles)
    case 15 % ctrl-O
    case 16 % ctrl-P
    case 17 % ctrl-Q
    case 18 % ctrl-R
        oiWindow('oiRefresh', hObject, eventData, handles)
    case 19 % ctrl-S
    case 20 % ctrl-T
    case 21 % ctrl-U
    case 22 % ctrl-V
    case 23 % ctrl-W
    case 24 % ctrl-X
    case 25 % ctrl-Y
    case 26 % ctrl-Z
    case 97 % alt-A

    otherwise
        return;
end

return;
