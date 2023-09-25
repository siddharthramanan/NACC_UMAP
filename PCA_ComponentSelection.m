%load data into MATLAB compatible format (.mat) and change the file name accordingly
Data = xlsread('C:\work\Matlab code\LPA_PPCA_Percent.xlsx');

% load the .mat file
%load('C:\work\Matlab code\Data.mat');
% call the data file as a vector named X
X = Data;

%pre-allocate memory and variables
% ask MATLAB to compute up to 10 components
maxcomp=10;
average_rmse=zeros(maxcomp,size(X,2));

% iterate through number of components for pPCA (in this case, 10 as specified above)
for nn = 1:maxcomp;
    
    % the PPCA analyses produces multiple outputs, but we are only
    % interested in 'S' file (structure), where the imputed and component outputs are
    % stored (stores final results at convergence in the rsltStruct)
    
    [~,~,~,~,~,S] = ppca((X),nn); % using the tilde tells the algorithm to not spit out outputs for other things except the S file
    ImputedScores = S.Recon; % look inside the 'S' file, in the 'Recon'structed observations using nn principal components (specified in line above)
    NaNs = isnan(X); %find NaNs
    X_imputed=X;
    %replace NaNs in original dataset with imputed scores
    X_imputed(NaNs) = ImputedScores(NaNs);
    %kmo_val(nn,:)=kmo(X_imputed);

    %%% run PCA component selection multiple times
    PPCA_rmse_collate=zeros(100,size(X,2));
        for i=1:10
            %shuffle data
            ind=randperm(size(X_imputed,1));
            tmpscore=X_imputed(ind,:);
            %run compsel code
            res=pca_compsel(zscore(tmpscore),'none','vene',4);
            PPCA_rmse_collate(i,:)=res.rmsecv;
        end
    % average rmse for each pPCA model
    average_rmse(nn,:)=mean(PPCA_rmse_collate,1);

end

% write the imputed results into a new excel file and change file names accordingly
filename = 'RMSE_LPA_PPCA.xlsx';
xlswrite(filename,average_rmse,'Original_LPA_PPCA','B2');
%xlswrite(filename,kmo_val,'Original_LPA_PPCA','A1');

% create a heatmap figure for the number of imputed components and change file names accordingly
figfilename = 'RMSE_PPCA_LPA';
figure;imagesc(average_rmse(:,1:10));
savefig(figfilename); % save as a matlab figure
saveas(gcf,'RMSE_PPCA_LPA.jpg'); %save as a .jpg
close all;