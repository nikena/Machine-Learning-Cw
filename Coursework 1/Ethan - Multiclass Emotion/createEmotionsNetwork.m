function [emotionsNetwork, avgf1scores, confusionMatricies, recall, precision] = createEmotionsNetwork()
    % Load emotions data, must be in same folder
    load("emotions_data.mat");
    
    % Make x and y into usable data
    x=x';
    s = length(y);
    classes = max(y,[],'all'); % Get number of classes
    target = zeros(s, classes);
    for i = 1:s
        target(i, y(i)) = 1;
    end
    y=target';
    
    % Create emotions network
    emotionsNetwork = newff(x, y, 10);
       
    % Training setup
    k = 10; % k in k-cross validation
    s = length(x); % Re-get size of input set after validation part
    [trainIndxs, testIndxs, trainSize, testSize] = kFoldSplitData(s,k); % Parition data into k folds
    % Modify train parameters
    emotionsNetwork.trainParam.show = 5;
    emotionsNetwork.trainParam.epochs = 100;
    
    recall = zeros(k, classes);
    precision = recall;
    confusionMatricies = zeros(k, classes, classes); % Index as (i,:,:) for individual matricies
    
    % Training loop
    for i = 1:k
        % Assign test and training indicies
        testLabels = x(:, testIndxs(:,i));
        testTargets = y(:, testIndxs(:,i));
        trainLabels = x(:, trainIndxs(:,i));
        trainTargets = y(:, trainIndxs(:,i));
        
        % Train
        emotionsNetwork = train(emotionsNetwork, trainLabels, trainTargets);
    
        % Validate, getting confusion matrix
        % Get output from k+1th data
        out = sim(emotionsNetwork, testLabels);
        [~, index] = max(out);
        % Convert output to classification
        outMax = zeros(classes, length(testLabels(1, :)));
        for j = 1 : length(testLabels(1, :))
            outMax(index(j), j) = 1;
        end
        % Get confusion matrix and from it recall and precision
        confusionMatricies(i,:,:) = confusionMatrix(testTargets, outMax);
        recall(i,:) = 1:classes;
        precision(i,:) = 1:classes;
        for j = 1:classes
            recall(i,j) = confusionMatricies(i,j,j)/sum(confusionMatricies(i,j,:));
            precision(i,j) = confusionMatricies(i,j,j)/sum(confusionMatricies(i,:,j));
        end
    end
    
    % Calculate F1 scores
    fscores = zeros(k, classes); % Get every f score from precision and recall
    for i = 1:k
        for j = 1:classes
            fscores(i,j) = fscore(1, recall(i,j), precision(i,j));
        end
    end
    
    % Averages
    avgf1scores = 1:classes;
    for i = 1:classes
        avgf1scores(i) = mean(fscores(:,i));
    end
end

function fs = fscore(beta, recall, precision)
    fs = (1+(beta*beta))*((precision*recall)/((beta*beta*precision)+recall));
end

% Targets = Actual value, Outputs = Predicted value
% Returns confusion matrix where x is the predicted result and y is the
% actual result. cm(n,:) will give all results where 1 was the output class
% and cm(:,n) will give all results where 1 was the target class, in both
% of these the nth index is the number of true positives
function cm = confusionMatrix(targets, outputs)
    l = size(targets, 1);
    cm = zeros(l, l);
    for i = 1:length(targets)
        [~,x] = max(targets(:, i));
        [~,y] = max(outputs(:, i));
        cm(x,y) = cm(x,y) + 1;
    end
end