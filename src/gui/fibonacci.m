function varargout = fibonacci(varargin)
% FIBONACCI MATLAB code for fibonacci.fig
%      FIBONACCI, by itself, creates a new FIBONACCI or raises the existing
%      singleton*.
%
%      H = FIBONACCI returns the handle to a new FIBONACCI or the handle to
%      the existing singleton*.
%
%      FIBONACCI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIBONACCI.M with the given input arguments.
%
%      FIBONACCI('Property','Value',...) creates a new FIBONACCI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fibonacci_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fibonacci_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fibonacci

% Last Modified by GUIDE v2.5 11-Mar-2013 14:58:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @fibonacci_OpeningFcn, ...
    'gui_OutputFcn',  @fibonacci_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before fibonacci is made visible.
function fibonacci_OpeningFcn(hObject, ~, handles, varargin)
%%

% Set current language to FR (default)
PbLang_Callback(handles.PbFr, [], handles);

% Define the callback for selection change in panel parameters
set(handles.PnParameters, 'SelectionChangeFcn', @(obj,evt) PnParameters_SelectionChangeFcn(obj,evt,guidata(hObject)))

% Update parameter fields
PnParameters_SelectionChangeFcn(handles.PnParameters,[],guidata(hObject));

% Center window in screen
movegui(hObject,'center')

% --- Outputs from this function are returned to the command line.
function fibonacci_OutputFcn(~, ~, ~)
%%



% --- Executes on button press in PbCalcul.
function PbCalcul_Callback(~, ~, handles) %#ok<DEFNU>
%%

% Display a watch as pointer
set(handles.FgFibonacciNumber, 'Pointer', 'watch');drawnow

% Instanciate Symbolic engine
eng=symengine;

% According to user selection, make calculation to reach a precision or
% with a specified number of iterations
if get(handles.PnParameters,'SelectedObject') == handles.RbPrecision
    
    % Get number of wanted digits
    nb_digits = str2double(get(handles.nb_digits,'String'));
    
    if isnan(nb_digits)
        set(handles.FgFibonacciNumber, 'Pointer', 'arrow');drawnow
        return
    end
    
    % Calculate values
    [computed_quotients, n_iterations, golden_number, quotient, divisor] = ...
        calculate_for_precision(eng, nb_digits);
    
else
    
    % Get number of requested iterations
    n_iterations = str2double(get(handles.nb_iterations,'String'));
    
    if isnan(n_iterations)
        set(handles.FgFibonacciNumber, 'Pointer', 'arrow');drawnow
        return
    end
    
    % Calculate approximation of golden number with specified number of
    % iterations
    [computed_quotients, nb_digits, golden_number, quotient, divisor] = ...
        calculate_for_iterations(eng, n_iterations);
    
end

% Update number of iterations and number of digits
set(handles.nb_digits,'String',nb_digits);
set(handles.nb_iterations,'String',n_iterations);

% Display quotient and divisor (last values)
set(handles.quotient,'String',char(quotient));
set(handles.divisor,'String',char(divisor));

% Display real value of golden number
set(handles.computed_golden_number,'String',[char(golden_number) '...']);

% Update plot
LocalUpdatePlot(handles, computed_quotients, char(golden_number));

% Display an arrow as pointer
set(handles.FgFibonacciNumber, 'Pointer', 'arrow');drawnow

function PnParameters_SelectionChangeFcn(hObject, ~, handles)
%%

% Get handle of selected object
sel_obj = get(hObject, 'SelectedObject');

if (sel_obj == handles.RbIterations)
    
    set(handles.nb_digits, 'Enable', 'off', 'String', '');
    set(handles.nb_iterations, 'Enable', 'on', 'String', '');
    
else
    
    set(handles.nb_digits, 'Enable', 'on', 'String', '');
    set(handles.nb_iterations, 'Enable', 'off', 'String', '');
    
end


function PbLang_Callback(hObject, ~, handles)
%%

% Get selected language
lang = get(hObject, 'UserData');

% Define function handle to get messages
LocalLanguage(lang);

% Update position of pushbutton (only current language is activated)
lang_pb = findobj(handles.PnLang, 'Style', 'togglebutton');
set(lang_pb, 'Value', 0);
set(hObject, 'Value', 1)

% Update label of graphical objects
LocalSetObjectLabels(handles);

function LocalUpdatePlot(handles, computed_quotients, golden_number)
%%
try
    % Define parameters
    NB_POINTS = 10;
    %PRECISION = 1/eps;
    
    % Extract the maximal number of digits available (count only number of
    % decimals)
    golden_number = strrep(golden_number,'.','');
    
    
    % Ensure that all values have the same size
    uniform_quotients=cellfun(@(x) strrep(x,'.',''), computed_quotients, 'UniformOutput', false);
    
    computed_digits = max(max(cellfun(@length, computed_quotients)),length(golden_number));
    NB_POINTS = min(NB_POINTS,computed_digits+1);
    
    golden_number = [golden_number, repmat('0', 1, computed_digits - length(golden_number))];
    uniform_quotients=cellfun(@(x) [x repmat('0', 1, computed_digits - length(x))], uniform_quotients, 'UniformOutput', false);
    
    % Compare digits of each iterations with digits of last iteration
    first_different_digit = cellfun(@(x) find(x~=golden_number,1,'first'), uniform_quotients, 'UniformOutput', false);
    first_different_digit(cellfun(@isempty,first_different_digit)) = {computed_digits+1};
    first_different_digit = cell2mat(first_different_digit);
    
    % Calculate number of digits to display to be able to plot NB_POINTS
    nb_digits = min(first_different_digit(end-(NB_POINTS-1):end));
    
    % Extract vector of data that have to be plotted
    data2plot = cellfun(@(x) str2double(x(max(nb_digits-1,1):end)),uniform_quotients(end-(NB_POINTS-1):end));
    golden_nb2plot = str2double(golden_number(max(nb_digits-1,1):end));
    
    % dec = first_different_digit(end-(NB_POINTS-1))-1;
    % val = 10*abs(str2double([uniform_quotients{end-(NB_POINTS-1)}(dec) '.' uniform_quotients{end-(NB_POINTS-1)}(dec+1:end)]) - ...
    %     str2double([golden_number(dec) '.' golden_number(dec+1:end)]));
    
    iterations = 1:length(uniform_quotients);
    iterations(1:end-NB_POINTS) = [];
    iterations = arrayfun(@num2str, iterations, 'UniformOutput', false);
    
    % Define index of values to plot as upper or lower than golden number
    upper_idx = find(data2plot > data2plot(end),1,'first'):2:length(data2plot);
    lower_idx = find(data2plot < data2plot(end),1,'first'):2:length(data2plot);
    
    xu = 1:length(upper_idx);
    xl = 1:length(lower_idx);
    
    x_lim = [xu(1)-0.1 max(xu(end),xl(end))+0.1];
    
    plage=abs(data2plot(1)-golden_nb2plot);
    
    % Update axe
    cla(handles.my_axes);
    plot(handles.my_axes, xu, data2plot(upper_idx), 'or');
    plot(handles.my_axes, xl, data2plot(lower_idx), 'ob');
    plot(handles.my_axes, x_lim, [golden_nb2plot golden_nb2plot], '-k');
    
    % Change axe properties for better display
    % Remove XTickLabel (n° of iteration is displayed near to each point)
    % Change YTickLabel to have the real delta between values and golden number
    set(handles.my_axes, ...
        'XLim',         x_lim, ...
        'XTick',        unique([xl xu]), ...
        'XTickLabel',   [], ...
        'YLim',         [golden_nb2plot-(1.1*plage) golden_nb2plot+(1.1*plage)], ...
        'YTick',        [golden_nb2plot-plage golden_nb2plot golden_nb2plot+plage], ...
        'YTickLabel',   [])
    
    
    set([handles.StGoldenNumberLegend, handles.StQuotientLegend, handles.StDivisorLegend], 'Visible', 'on')
    
    % Display iteration number near to points
    arrayfun(@(x,y,z) text(x,y,char(z), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom'), xu, data2plot(upper_idx), iterations(upper_idx))
    arrayfun(@(x,y,z) text(x,y,char(z), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top'), xl, data2plot(lower_idx), iterations(lower_idx))
end
function LocalSetObjectLabels(handles)
%%

% List objects in figure (uicontrol/uipanel/figure)
list = findobj(handles.FgFibonacciNumber);

for i_obj = 1:length(list)
    
    % Get message using hGetMessage
    [msg, is_found] = LocalGetMessage(get(list(i_obj), 'Tag'));
    
    % If a function handle is specified in UIcontrol UserData property, it
    % has to be used to modify label
    user_data = get(list(i_obj), 'UserData');
    
    if ~isempty(user_data) && isa(user_data, 'function_handle')
        msg = user_data(msg);
    end
    
    % Get list of properties
    prop_list = fieldnames(get(list(i_obj)));
    
    mask_prop = ismember(prop_list, {'String', 'Title', 'Label', 'Name'});
    
    if any(mask_prop) && is_found
        
        % Extract name of property to set in object
        prop_name = prop_list{mask_prop};
        
        set(list(i_obj), prop_name, msg);
        
    end
    
end

function [msg,is_found] = LocalGetMessage(id,varargin)
%%

% Get message define for ID and current language
[msg,is_found] = get_message(id, LocalLanguage());

% Use SPRINTF to format output message if some additional input arguments
% are specified and msg already contains almost 1 %
if is_found && ~isempty(varargin) && ~isempty(strfind(msg, '%'))
    msg = sprintf(msg, varargin{:});
end


function [varargout] = LocalLanguage(varargin)
%%

persistent lang;

if isempty(lang)
    lang = 'fr';
end

if (nargin == 1) && ischar(varargin{1})
    lang = varargin{1};
elseif (nargout == 1)
    varargout{1} = lang;
end
