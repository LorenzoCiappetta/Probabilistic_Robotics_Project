function main()
    
    %% Load dataset
    % use the following code (uncomment) if "dataset.mat" is not in folder
    
    % filename = "./dataset.txt";
    % dataset = parse_data(filename);
    % save("dataset.mat")

    % else leave this
    load("dataset.mat")
    disp(dataset)

endfunction

main()