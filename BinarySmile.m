function [binarySmileNetwork ] = BinarySmile()
    %load in and reshape data so it can be trained.
    load('facialPoints.mat');
    points = reshape(points, [132, 150]);
    load('labels.mat');
    %Invert labels in order to match the points (input) data.
    labels = labels';
    
    predicted = [];
    actual = [];
    
    k = 10; % k in k-cross validation
    
    cv = cvpartition(size(points, 2), 'kfold', k);
    for i = 1:cv.NumTestSets
        % Training loop
        %Create a new binarySmileNetwork with 10 hidden nodes.
        binarySmileNetwork = newff(points, labels, 10);
    
        binarySmileNetwork.name = 'BinarySmile';
        binarySmileNetwork.trainParam.epochs = 100;
        binarySmileNetwork.trainParam.show = 7;
        
        % Training setup

        trainX = points(:, cv.training(i));
        trainY = labels(cv.training(i));
        testX = points(:, cv.test(i));
        testY = labels(cv.test(i));

        %train(net, inputs, taregts)
        binarySmileNetwork = train(binarySmileNetwork, trainX, trainY);
        t = sim(binarySmileNetwork, testX);
        predicted = [predicted t];
        actual = [actual testY];
        
        [c, cm] = confusion(testY, t);

    end
end