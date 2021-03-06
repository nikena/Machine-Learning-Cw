function leaf = MajorityValue(targets)
    % Prepare leaf node
    leaf = struct();
    leaf.op = "";
    leaf.kids = cell(0);
    leaf.attribute = 0;
    leaf.threshold = 0;
    % leaf.class calculated later
    
    % Count number of 0s and 1s in targets and store in results array
    % (where index = target value + 1)
    results = zeros(1:2);
    for i = 1:length(targets)
        results(targets(i) + 1) = results(targets(i) + 1) + 1;
    end
    
    % Get highest number from results array and set class to its index
    % (minus 1), so can be either 0 or 1
    max = 0;
    for i = 1:length(results)
        if results(i) > max
            leaf.class = i - 1;
        end
    end
end