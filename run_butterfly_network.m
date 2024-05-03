%%
addpath(genpath(pwd));

%%
load('Raw_butterfly_network.mat')
load('W_matrix.mat')
load('W_matrix_FV.mat')
load('pairwise_cosine_new.mat')
load('pairwise_cosine_FV.mat')

%% optional/don't run -- get only top 40
%matrix = W_matrix;
%[sorted_values, sorted_indices] = sort(matrix, 2, 'descend');
%top_indices = sorted_indices(:, 1:80);

% create a mask to set all values not in the top 40 to 0
%mask = zeros(size(matrix));
%rows = (1:size(matrix, 1)).';
%mask(sub2ind(size(matrix), rows(:, ones(1, 80)), top_indices)) = 1;

% Apply the mask to the original matrix
%result = matrix .* mask;


%% run NE

% select matrix
%result = double(pairwise_cosine_new);
%result = W_matrix;
%result = W_matrix_FV;
%result = pairwise_cosine_FV;
%result = W_matrix .* W_matrix_FV;
%result = double(pairwise_cosine_new) .* pairwise_cosine_FV;

% run Network_Enhancement
W_butterfly_NE=Network_Enhancement(result);
%filename = 'W_butterfly_NE.mat';
%save(filename, 'W_butterfly_NE');

% print/plot the results
[~,acc_raw] = CalACC(result, labels); % calculate acc on the raw network

[~,acc_NE] = CalACC(W_butterfly_NE, labels); % calculate acc on the denoised network

fprintf('The accuracy on raw network is %6.4f \n', acc_raw);
fprintf('The accuracy on enhanced network is %6.4f \n', acc_NE);


figure;
NUM = 80; %the number of images per class
[ tpr0 ] = cal_specific_accuracy(result,labels,NUM);
plot((1:NUM), (tpr0), 'b-', 'Linewidth',5,'MarkerSize',5); hold on;
[ tpr1 ] = cal_specific_accuracy(W_butterfly_NE,labels,NUM);
plot((1:NUM), (tpr1), 'r-', 'Linewidth',5,'MarkerSize',5); hold on;
axis([0,80,0,1])
legend('Raw', 'NE');

h = xlabel('Number of Retrieval');set(h,'FontSize',16);
h = ylabel('Identification Accuracy');set(h,'FontSize',16);

set(gca,'FontSize',16)







