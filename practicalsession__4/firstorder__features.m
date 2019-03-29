function features = firstorder__features(tumour__volume)
    
    % THIS FUNCTION IS INCOMPLETE (see the code below)
    
    %
    % INPUT
    % tumour__volume is the segmented 3D volume of the lesion (x-by-y-by-z
    % matrix)
    %
    % OUTPUT
    % features is a matlab structure containing all the histogram-based
    % features extracted in the code
    %
    
    features = [];
    
    % Tip: some preprocessing needed here
    % >>>
    
    [count,~] = hist(tumour__volume, 256); % The second argument represent the number of bins
    tot = sum(count);
    frequency = count/tot;

    tumour__dimension = size(tumour__volume);
    squared__matrix = tumour__volume.^2;
    
    % Maximum
    tumour__max = max(tumour__volume);
    features.max = tumour__max;
    
    % Minimum
    % >> INSERT CODE HERE
    
    % Mean
    % >> INSERT CODE HERE
    
    % Median
    % >> INSERT CODE HERE

    % Mean Absolute Deviation (MAD)
    m__dev = abs(tumour__volume - tumour__mean);
    MAD = mean(m__dev);
    features.mad = MAD;
    
    % Root Mean Square (RMS)
    % >> INSERT CODE HERE

    % Energy
    energy = sum(sum(squared__matrix));
    features.energy = energy;
    
    % Entropy
    entropy__vector = frequency.*log2(frequency);
    for i=1:256
        if isnan(entropy__vector(1, i))
            entropy__vector(1, i) = 0;
        end
    end
    entropy = (-1) * sum(entropy__vector);
    features.entropy = entropy;

    % Kurtosis
    num_vector = (tumour__volume - tumour__mean).^4;
    den_vector = (tumour__volume - tumour__mean).^2;
    num = sum(num_vector)/tumour__dimension(1,1);
    den = ((sum(den_vector) / tumour__dimension(1,1)))^2;
    kurtosis = num / den;
    features.kurtosis = kurtosis;

    % Skewness
    temp__vector = (tumour__volume - tumour__mean).^3;
    num1 = sum(temp__vector)/tumour__dimension(1,1);
    den1 = (sqrt(sum(den_vector)/tumour__dimension(1,1)))^3;
    skewness = num1/den1;
    features.skewness = skewness;
    clear temp__vector
    
    % Standard Deviation 
    % >> INSERT CODE HERE

    % Uniformity
    uniformity__vector = frequency.*frequency;
    uniformity = sum(sum(uniformity__vector));
    features.uniformity = uniformity;

    % Variance
    temp__vector = (tumour__volume - tumour__mean).^2;
    variance = (1/(tumour__dimension(1,1)-1)) * sum(sum(temp__vector));
    features.variance = variance;
    clear temp__vector

end