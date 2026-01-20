source "epipolar.m"

function main()
    
    %% Load dataset
    % use the following code (uncomment) if "dataset.mat" is not in folder
    
    % filename = "./dataset.txt";
    % dataset = parse_data(filename);
    % save("dataset.mat")

    % else leave this
    load("dataset.mat")
    %disp(dataset);

    for i=1:(numel(dataset)-1)

        % Compare images a pair at a time
        image1 = dataset{i};
        image2 = dataset{i+1};

        % take keypoints
        keypoints1 = image1.keypoints;
        keypoints2 = image2.keypoints;

        % find association
        id1 = keypoints1.ids - 100;
        as1 = keypoints1.associations;

        id2 = keypoints2.ids - 100;
        as2 = keypoints2.associations;

        as2 = nonzeros(as2(id1)); 
        id2 = id2(as2);
        as1 = nonzeros(as1(id2));

        % keep only points with an association
        points1 = keypoints1.vectors;
        points2 = keypoints2.vectors;

        points1 = points1(as1, :).';
        points2 = points2(as2, :).';

        % Plot points (quite janky)
        % hf = figure();
        % plot3(points1(1,:), points1(2,:), points1(3,:), 'o');
        % xlabel("x")
        % ylabel("y")
        % zlabel("z")
        % title(strcat("Keypoints from camera ", num2str(i)))
        % print (hf, strcat(strcat("./plots/plot",num2str(i)), ".pdf"), "-dpdflatexstandalone");

        % pause;

        % TODOs:

        % use points to estimate Essential Matrix
        %E = estimateEssential(points1, points2);

        % use essential to estimate transformation
        % R, t = Essential2Transform(E) % disambiguate R

        % Does it make any sense to use least squares afterwards?
        % Is RANSAC needed or are the associations good already?

    endfor

endfunction

main();