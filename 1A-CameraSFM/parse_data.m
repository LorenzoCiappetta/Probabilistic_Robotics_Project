%% parse_data function:
%    reads from file and returns a structure containing data

function dataset = parse_data (filename)
    fid = fopen("./dataset.txt", "r");
    c = fgetl(fid);
    dataset = cell();

    while c != -1
        #disp(strfind(c, "KF:"));
        l = strsplit(c);
        if strcmp(l{1}, "KF:")
            id = str2num(l{2})+1;
            camera.position = zeros(1,6);
            camera.keypoints = cell();
            for i=1:6
                camera.position(i) = str2num(l{i+2});
            end
            dataset{id} = camera;
        else
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