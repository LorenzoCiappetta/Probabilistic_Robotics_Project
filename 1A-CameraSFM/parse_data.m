%% parse_data function:
%    reads from file and returns a structure containing data

function dataset = parse_data (filename)
    fid = fopen("./dataset.txt", "r");
    c = fgetl(fid);
    dataset = cell();

    while c != -1
        % readline
        l = strsplit(c);

        % fill dataset structure
        if strcmp(l{1}, "KF:")
            id = str2num(l{2})+1;

            % initialize position
            camera.position = zeros(1,3);

            % fill position
            quat = zeros(1,3);
            for i=1:3
                camera.position(i) = str2num(l{i+2});
                quat(i) =str2num(l{i+5});
            endfor

            % compute rotation quaternion
	        n = norm(quat)^2;
	        if (n > 1)
	            camera.quaternion = [1, 0, 0, 0];
            else
	            qw = sqrt(1 - n);
	            camera.quaternion = [qw, quat(1), quat(2), quat(3)]; 
            endif

            % initialize keypoints
            camera.keypoints.ids = cell();
            camera.keypoints.vectors = cell();
            k = 1;

            dataset{id} = camera;

            if id > 1
                dataset{id-1}.keypoints.ids = cell2mat(dataset{id-1}.keypoints.ids);
                dataset{id-1}.keypoints.vectors = reshape(cell2mat(dataset{id-1}.keypoints.vectors), 3, []).';
            endif
        else
            % fill keypoints
            n = str2num(l{2})+1;
            m = str2num(l{3});
            dataset{id}.keypoints.ids{k} = m;
            dataset{id}.keypoints.vectors{k} = zeros(1,3);
            

            for i=1:3
                dataset{id}.keypoints.vectors{k}(i) = str2num(l{i+3});
            endfor
            
            k+=1;
        endif

        c = fgetl(fid);        
    end
    fclose(fid);

    dataset{id}.keypoints.ids = cell2mat(dataset{id}.keypoints.ids);
    dataset{id}.keypoints.vectors = reshape(cell2mat(dataset{id}.keypoints.vectors), 3, []).';    
    
endfunction