function [target_raw, bias_raw, average, kappa, support] = computeStat(target, response, binSize, mirror)

% convert to [0, 2 pi] range
target = target / 180 * (2 * pi);
target_raw = target;

response = response / 180 * (2 * pi);
bias_raw = wrapToPi(response - target);

% mirroring the data
if ~exist('mirror', 'var')
    mirror = false;
end

if mirror
    target_lh   = target(target <= pi) + pi;
    response_lh = response(target <= pi) + pi;
    
    target_hh   = target(target > pi) - pi;
    response_hh = response(target > pi) - pi;
    
    target   = wrapTo2Pi([target; target_lh; target_hh]);
    response = wrapTo2Pi([response; response_lh; response_hh]);
end

% bias & variance calculation
nBins = 180 / binSize;
delta = (2*pi / nBins) / 2;
support = 0: 0.025: 2*pi;

average = zeros(1, length(support));
kappa  = zeros(1, length(support));

for idx = 1:length(support)
    binLB = support(idx) - delta;
    binUB = support(idx) + delta;
    
    if binLB < 0
        binLB = wrapTo2Pi(binLB);
        binData = response(target >= binLB | target <= binUB);
    elseif binUB > 2 * pi
        binUB = wrapTo2Pi(binUB);
        binData = response(target >= binLB | target <= binUB);
    else
        binData = response(target >= binLB & target <= binUB);
    end
    
    meanRes = circ_mean(binData);
    average(idx) = wrapToPi(meanRes - support(idx));
    kappa(idx)  = circ_kappa(binData);
end

end
