% get images
folder_path = '/MATLAB Drive/ORF387/Butterfly/images';
cd(folder_path);
files = dir(fullfile(folder_path, '*.png'));
file_names = {files.name};

encodings = cell(1, numel(file_names));  % Preallocate for storing VLAD encodings

% get segmentations
folder = '/MATLAB Drive/ORF387/Butterfly/segmentations';

% Get list of image file names
files_seg = dir(fullfile(folder, '*.png'));
image_seg = cell(1, numel(files_seg));

for i = 1:numel(files_seg)
    image_seg{i} = fullfile(folder, files_seg(i).name);
end

% Parameters for DSIFT
stepSize = 7;  % Step size for dense SIFT

% Accumulate all descriptors from all images for k-means
all_descriptors = [];

% Display number of images found
num_files = numel(file_names);
fprintf('Number of files: %d\n', num_files);

% Proceed with the rest of your code only if files are found
if num_files == 0
    error('No files found. Check the directory path and file type.');
end
%% 
% Load and process each image to collect descriptors
for i = 1:numel(file_names)
    fprintf('Processing image %d/%d\n', i, numel(file_names));
    file_name = fullfile(folder_path, file_names{i});
    try
        image = imread(file_name);  % Load your image
        
        [seg, cmap] = imread(image_seg{i});
    
        img_gray = rgb2gray(image); % Convert RGB image to grayscale
    
        for y = 1:size(img_gray, 1)
            for x = 1:size(img_gray, 2)
              if seg(y, x) ~= 1 && seg(y, x) ~= 3
                  img_gray(y, x) = 0;
              end
            end
        end
        [~, d1] = vl_dsift(single(img_gray), 'Step', stepSize, 'Fast');  % Extract dense SIFT features
        all_descriptors = [all_descriptors, d1];  % Accumulate descriptors
    catch ME
        warning('Failed to process image %s: %s', file_name, ME.message);
    end
end
%% 
num_clusters = 50;
% Perform k-means clustering to obtain visual vocabulary
[centers, ~] = vl_kmeans(single(all_descriptors), num_clusters, 'Initialization', 'plusplus');
%%

% Process each image again to compute VLAD encodings
for i = 1:numel(file_names)
    fprintf('Second Processing image %d/%d\n', i, numel(file_names));
    file_name = fullfile(folder_path, file_names{i});
    try
        image = imread(file_name);  % Load your image

        [seg, cmap] = imread(image_seg{i});
    
        img_gray = rgb2gray(image); % Convert RGB image to grayscale
    
        for y = 1:size(img_gray, 1)
            for x = 1:size(img_gray, 2)
              if seg(y, x) ~= 1 && seg(y, x) ~= 3
                  img_gray(y, x) = 0;
              end
            end
        end
        [f1, d1] = vl_dsift(single(img_gray), 'Step', stepSize, 'Fast');  % Extract dense SIFT features
        % Compute VLAD encoding
        % d1 = single(d1);
        % fprintf('Type of d1: %s\n', class(d1));
        % fprintf('Type of centers: %s\n', class(centers));
        assignments = calculateAssignments(single(d1), single(centers));
        encodings{i} = vl_vlad(single(d1), centers, single(assignments), 'Unnormalized');
    catch ME
        warning('Failed to process image %s: %s', file_name, ME.message);
        encodings{i} = [];  % Assign empty array in case of failure
    end
end

encodings_new = encodings;
% Save the encodings to a .mat file
filename = 'encodings_new.mat';
save(filename, 'encodings_new');

%% assignments
function assignments = calculateAssignments(d1, centers)
    numDescriptors = size(d1, 2);
    numClusters = size(centers, 2);
    assignments = zeros(numClusters, numDescriptors, 'like', d1);  % Cluster rows, descriptor columns

    % Compute Euclidean distances and find nearest center for each descriptor
    for i = 1:numDescriptors
        distances = sum(bsxfun(@minus, centers, d1(:, i)).^2, 1);
        [~, minIndex] = min(distances);
        assignments(minIndex, i) = 1;
    end
end
