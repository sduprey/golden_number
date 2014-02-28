function [computed_quotients, n_iterations, golden_number, quotient, divisor] = calculate_for_precision(eng, nb_digits_wanted)

% Minimal number of digits allowed is 3
if nb_digits_wanted <= 2
    nb_digits_wanted = 3;
end

% Specify the number of digits for Symbolic calculation
% And calculate real value for golden number with this precision
digits(nb_digits_wanted);
golden_number=vpa('(1+sqrt(5))/2');

% Infinite loop
% Iterations are done until number of digits of precision is found
% Initialize table with all computed quotient (approximations of golden
% number)
computed_quotients={};
precision = 0;
n_iterations = 1;
while precision < nb_digits_wanted
    
    % Calculate 2 consecutive terms of Fibonacci sequence
    quotient=feval(eng,'numlib::fibonacci',n_iterations);
    divisor=feval(eng,'numlib::fibonacci',n_iterations+1);
    
    % Evaluate precision of calculation
    % Substract real value of golden number ((1+sqrt(5)/2) with quotient of
    % 2 terms of Fibonacci sequence
    prec=vpa(['(1+sqrt(5))/2 -' char(quotient) '/' char(divisor) '-1']);
    
    % Evaluate precision of calculation        
    precision_string = char(abs(prec)); % Get string representation of absolute value of precision, something like 0.****
    [~,~,precision] = regexp(precision_string, '0\.0*([1-9])');
    precision = precision{1}(1) - 2; % Remove the 2 first characters that are '0.'
        
    % Add quotient in list
    computed_quotients=[computed_quotients {char(vpa(['1+' char(quotient) '/' char(divisor)]))}]; %#ok<AGROW>
    
    % Increment counter
    n_iterations=n_iterations+1;
end

% Remove 1 from iteration variable (next iteration will not be calculated)
n_iterations=n_iterations-1;
