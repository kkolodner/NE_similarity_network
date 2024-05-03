%% VLAD GAUSSIAN ENCODING: compute norms
load('encodings_new.mat')

norm_matrix = zeros(832, 832);

for i = 1:832
    for j = 1:832
        data_i = encodings_new{i};
        data_j = encodings_new{j};
        
        % Calculate the norm of the difference between the arrays
        norm_diff = norm(data_i - data_j);
        
        % Store the result in some output matrix if needed
        norm_matrix(i,j) = norm_diff;
    end
end

k = 20;
epsilon_matrix = zeros(832,1);

for i = 1:832
    sorted_array = sort(norm_matrix(i,:), 'descend');
    top_20_values = sorted_array(1:k);
    epsilon_matrix(i) = sum(top_20_values)/k;
end


%% take gaussian distribution

sigma = 0.5;

%std(result_matrix(:)); % stddev

W_matrix = zeros(832,832);
for i = 1:832
    for j = 1:832
        W_matrix(i,j) = exp(-norm_matrix(i,j)^2 / (sigma^2*( ...
            epsilon_matrix(i)+epsilon_matrix(j))^2));
    end
end

W_matrix(1:size(W_matrix, 1) + 1:end) = 0;

filename = 'W_matrix.mat';
save(filename, 'W_matrix');

%% VLAD COSINE ENCODING
test = cell2mat(encodings_new)';
pairwise_cosine_new = 1 - pdist2(test, test, 'cosine');
for i = 1:length(pairwise_cosine_new)
    pairwise_cosine_new(i,i)=0;
end

filename = 'pairwise_cosine_new.mat';
save(filename, 'pairwise_cosine_new');


%% FV GAUSSIAN ENCODING: compute norms

load('image_featsseg.mat')
result_matrix = zeros(832, 832);

for i = 1:832
    for j = 1:832
        data_i = image_feats(i,:);
        data_j = image_feats(j,:);
        
        % Calculate the norm of the difference between the arrays
        norm_diff = norm(data_i - data_j);
        
        % Store the result in some output matrix if needed
        result_matrix(i,j) = norm_diff;
    end
end

k = 20;
epsilon_matrix_fv = zeros(832,1);

for i = 1:832
    sorted_array = sort(result_matrix(i,:), 'descend');
    top_20_values = sorted_array(1:k);
    epsilon_matrix_fv(i) = sum(top_20_values)/k;
end

%% take gaussian distribution

sigma = 0.5;

%std(result_matrix(:)); % stddev

W_matrix_FV = zeros(832,832);
for i = 1:832
    for j = 1:832
        W_matrix_FV(i,j) = exp(-result_matrix(i,j)^2 / (sigma^2*( ...
            epsilon_matrix_fv(i)+epsilon_matrix_fv(j))^2));
    end
end

W_matrix_FV(1:size(W_matrix_FV, 1) + 1:end) = 0;

filename = 'W_matrix_FV.mat';
save(filename, 'W_matrix_FV');

%% FV COSINE ENCODING
load('image_featsseg.mat')
pairwise_cosine_FV = 1 - pdist2(image_feats, image_feats, 'cosine');
for i = 1:length(pairwise_cosine_FV)
    pairwise_cosine_FV(i,i)=0;
end

filename = 'pairwise_cosine_FV.mat';
save(filename, 'pairwise_cosine_FV');