    load('labels');
    load('facialPoints');
    points = reshape(points, [132, 150]);
    tree = DecisionTreeLearning(points,  labels);
    %DrawDecisionTree(tree);
    f1score = kfold(points, labels);