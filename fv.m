%run("/MATLAB Drive/vlfeat-0.9.21/toolbox/vl_setup")
load("/MATLAB Drive/ORF387/Butterfly/Raw_butterfly_network.mat")

%% build fisher vocabulary
function [means, covariances, priors] = build_fisher_vocabulary( image_paths, image_seg )
    
    % Sample random permutation of images
    sample_size = 200;
    total_descriptors =[];
    perm = randperm(length(image_paths), sample_size);
    n = length(perm);
    
    for i = 1:n
        image_index = perm(i);
        [seg, cmap] = imread(image_seg{image_index});
        
        img = imread(image_paths{image_index});
        img_gray = single(rgb2gray(img)); % Convert RGB image to grayscale

        for y = 1:size(img_gray, 1)
            for x = 1:size(img_gray, 2)
              if seg(y, x) ~= 1 && seg(y, x) ~= 3
                  img_gray(y, x) = 0;
              end
            end
        end

        [~, descriptors] = vl_sift(img_gray);

        
        total_descriptors = [total_descriptors descriptors];
    end

    data = single(total_descriptors);

    disp('Creating GMM Clusters');
    
    numClusters = 50;
    [means, covariances, priors] = vl_gmm(data, numClusters);

end

% Specify the folder containing images
folder = '/MATLAB Drive/ORF387/Butterfly/images';

% Get list of image file names
files = dir(fullfile(folder, '*.png'));
image_paths = cell(1, numel(files));

for i = 1:numel(files)
    image_paths{i} = fullfile(folder, files(i).name);
end

% Specify the folder containing images
folder = '/MATLAB Drive/ORF387/Butterfly/segmentations';

% Get list of image file names
files = dir(fullfile(folder, '*.png'));
image_seg = cell(1, numel(files));

for i = 1:numel(files)
    image_seg{i} = fullfile(folder, files(i).name);
end

%% run function
[means, covariances, priors] = build_fisher_vocabulary(image_paths, image_seg);

%% get fisher sifts
function image_feats = get_fisher_sifts(image_paths, image_seg, means, covariances, priors)

    n = length(image_paths);
    
    clear image_feats;
    for i = 1:n
       
        img = imread(image_paths{i});
        [seg, cmap] = imread(image_seg{i});
        img_gray = single(rgb2gray(img)); % Convert RGB image to grayscale
        for y = 1:size(img_gray, 1)
            for x = 1:size(img_gray, 2)
              if seg(y, x) ~= 1 && seg(y, x) ~= 3
                  img_gray(y, x) = 0;
              end
            end
        end

        [~, descriptors] = vl_sift(single(img_gray));
        
        % dx1
        encoding = vl_fisher(single(descriptors), means, covariances, priors);
        
        if ~exist('image_feats', 'var')
            image_feats = zeros(n, size(encoding, 1));
        end
        
        image_feats(i, :) = encoding';

    end
end

%% run function
image_feats = get_fisher_sifts(image_paths, image_seg, means, covariances, priors);

save("image_featsseg.mat","image_feats");