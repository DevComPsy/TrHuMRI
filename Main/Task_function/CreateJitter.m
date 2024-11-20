function JitterDist = CreateJitter(meanJitter, numValues, range)
% CreateJitter Generates a vector of jitter values based on a Gamma distribution.
%
%   JitterDist = CreateJitter(meanJitter, numValues, range) returns a vector of
%   jitter values generated from a Gamma distribution with a specified mean.
%   The generated values are constrained to be within the user-defined range.
%
%   Inputs:
%       meanJitter - The mean of the Gamma distribution from which the jitter
%                    values are generated.
%       numValues  - The number of jitter values to generate.
%       range      - A 1x2 vector specifying the [min, max] range for the jitter
%                    values.
%
%   Outputs:
%       JitterDist - A 1-by-numValues vector containing the generated jitter
%                    values, all within the specified range.
%
%   Example:
%       % Generate 100 jitter values with a mean of 2 seconds and range [1, 4].
%       jitter = CreateJitter(2, 100, [1, 4]);
%
%   Note:
%       The function uses the Gamma distribution (gamrnd) to generate
%       the jitter values. The values are filtered to ensure they fall within
%       the specified range.

% Extract the minimum and maximum values from the range
minVal = range(1);
maxVal = range(2);

% Create distribution
poisson = 1;
if poisson ==0
    JitterDist = max(min(gamrnd(meanJitter,1,numValues,1),maxVal),minVal);
elseif poisson ==1
    JitterDist = zeros(1,numValues);
    for i = 1:numValues
        notok = 1;
        while notok
            poisson_temp = poissrnd(meanJitter*10);

            if poisson_temp < maxVal*10 && poisson_temp > minVal*10 
                notok = 0;

            end
            JitterDist(i) = poisson_temp/10;

        end

    end
    JitterDist = JitterDist';

end