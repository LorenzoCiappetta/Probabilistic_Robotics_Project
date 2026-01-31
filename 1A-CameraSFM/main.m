source "epipolar.m"

#estimate fundamental matrix
function E = estimateEssential_aux(P1_img, P2_img)
  H=zeros(9,9);
  n_points=size(P1_img,2);

  for (i=1:n_points)
    p1_img=[P1_img(:,i)];
    p2_img=[P2_img(:,i)];
    A=reshape(p1_img*p2_img',1,9);
    H+=A'*A;
  endfor;
  [V,lambda]=eig(H);
  E=reshape(V(:,1),3,3);
endfunction

#estimate fundamental matrix
function E = estimateEssential(P1_img, P2_img, use_preconditioning=false)
  n_points=size(P1_img,2);
  A1=A2=eye(3);
  if (use_preconditioning)
    A1=computePreconditioningMatrix(P1_img);
    A2=computePreconditioningMatrix(P2_img);
  endif;
  
  AP1=A1*P1_img;
  AP2=A2*P2_img;
  Ea=estimateEssential_aux(AP1,AP2);
  E=A1'*Ea*A2;
endfunction

function plotCameras2D(poses)
  fig = figure();
  v = [0; 0; 1];

  for i=1:length(poses)
    pose = poses{i}.global;
    x = pose(1, 4);
    y = pose(2, 4);
    R = pose(1:3, 1:3);
    d = R*v;

    plot(x, y, "bo");
    hold on;
    quiver(x, y, d(1), d(2));
    hold on;

  endfor

  xlabel("x");
  ylabel("y");
  title("2D View of camera poses");

endfunction

function main()
    
    %% Load dataset
    % use the following code (uncomment) if "dataset.mat" is not in folder
    
    % filename = "./dataset.txt";
    % dataset = parse_data(filename);
    % save("dataset.mat")

    % else leave this
    load("dataset.mat");
    %disp(dataset);

    % save all the "results" in a cell array (w.r.t. first camera and previous camera)
    transforms = cell(numel(dataset));
    transforms{1}.global = eye(4);
    transforms{1}.local = eye(4);

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

        % use points to estimate Essential Matrix
        E = estimateEssential(points1, points2, true);

        % use essential to estimate transformation
        [X1, X2] = essential2transform(E); 
        
        % disambiguate R and t
        R1 = X1(1:3, 1:3);
        R2 = X2(1:3, 1:3);

        t1 = X1(1:3, 4);
        t2 = X2(1:3, 4);

        tran = {[R1, t1], [R1, t2], [R2, t1 ], [R2, t2]};

        % Compute two rotation options for points2 seen from camera 1
        points2_1 = R1*points2;
        points2_2 = R2*points1;

        % keep track of tests
        record = zeros(1,4);

        % triangulate points for all 4 options
        % count how many points are IN FRONT of camera z>0
        for j=1:size(points1)(2)
          [success, p, e] = triangulatePoint(t1, points1(:, j), points2_1(:, j));
          if success && p(3) > 0
            record(1) += 1;
          endif

          [success, p, e] = triangulatePoint(t2, points1(:, j), points2_1(:, j));
          if success && p(3) > 0
            record(2) += 1;
          endif          

          [success, p, e] = triangulatePoint(t1, points1(:, j), points2_2(:, j));
          if success && p(3) > 0
            record(3) += 1;
          endif

          [success, p, e] = triangulatePoint(t2, points1(:, j), points2_2(:, j));
          if success && p(3) > 0
            record(4) += 1;
          endif          

        endfor

        % Tranformation from camera 1 to camera 2
        [~, index] = max(record);
        final = [tran{index}; 0 0 0 1];

        transforms{i+1}.local = final;
        transforms{i+1}.global = transforms{i}.global*final;

    endfor

    plotCameras2D(transforms);
    pause;

endfunction

main();