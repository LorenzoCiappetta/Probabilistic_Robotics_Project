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

function main()
    
    %% Load dataset
    % use the following code (uncomment) if "dataset.mat" is not in folder
    
    % filename = "./dataset.txt";
    % dataset = parse_data(filename);
    % save("dataset.mat")

    % else leave this
    load("dataset.mat")
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
        E = estimateEssential(points1, points2);

        % use essential to estimate transformation
        [X1, X2] = essential2transform(E); 
        
        % disambiguate R and t
        R1 = X1(1:3, 1:3);
        R2 = X2(1:3, 1:3);

        t1 = X1(1:3, 4);
        t2 = X2(1:3, 4);

        
        % Does it make any sense to use least squares afterwards?
        % Is RANSAC needed or are the associations good already?

    endfor

endfunction

main();