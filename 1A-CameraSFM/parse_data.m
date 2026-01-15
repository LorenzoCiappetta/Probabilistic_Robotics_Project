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
            end

            % compute rotation quaternion
	        n = norm(quat)^2;
	        if (n > 1)
	            camera.quaternion = [1, 0, 0, 0];
            else
	            qw = sqrt(1 - n);
	            camera.quaternion = [qw, quat(1), quat(2), quat(3)]; 
            end

            % initialize keypoints
            camera.keypoints = cell();

            dataset{id} = camera;
        else
            % fill keypoints
            n = str2num(l{2})+1;
            m = str2num(l{3});
            keypoint.id = m;
            keypoint.v = zeros(1,3);

            for i=1:3
                keypoint.v(i) = str2num(l{i+3});
            end

            dataset{id}.keypoints{n} = keypoint;  
            
        end

        c = fgetl(fid);        
    end
    fclose(fid);
    
endfunction