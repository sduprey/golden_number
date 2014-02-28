function [computed_quotients, precision, golden_number, quotient, divisor] = calculate_for_iterations(eng, nb_iterations_wanted)

% Preallocate output array (computed_quotients)
computed_quotients = cell(1,nb_iterations_wanted);

for i=1:nb_iterations_wanted
    
    % Calculate 2 consecutive terms of Fibonacci sequence
    quotient=feval(eng,'numlib::fibonacci',i);
    divisor=feval(eng,'numlib::fibonacci',i+1);
    
    % Calculate quotient for current iteration
    computed_quotients{i}=char(vpa(['1+' char(quotient) '/' char(divisor)]));
    
end

% Evaluate precision of calculation
% Substract real value of golden number ((1+sqrt(5)/2) with quotient of
% 2 terms of Fibonacci sequence
digits(1e4);
prec=vpa(['(1+sqrt(5))/2 -' char(quotient) '/' char(divisor) '-1']);

% Evaluate precision of calculation        
precision_string = char(abs(prec)); % Get string representation of absolute value of precision, something like 0.****
[~,~,precision] = regexp(precision_string, '0\.0*([1-9])');
precision = precision{1}(1) - 2; % Remove the 2 first characters that are '0.'

% Calculate golden number with calculation precision
precision=max(2,precision);
digits(precision);
golden_number=vpa('(1+sqrt(5))/2');