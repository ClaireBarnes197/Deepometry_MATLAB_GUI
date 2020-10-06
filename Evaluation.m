image_directory =  'C:\Documents\Parsedimages'; %Specify location of evaluation data
output_directory = 'C:\Documents\Evaluationresults'; %Specify location to store all plots
model_directory1 ='C:\Documents\Model'; %Specify the location of your fully trained model
model_directory = string(model_directory1); 
Training_location = 'C:\Documents\Trainingimages'; %Specify the location of your training data
%Create a folder to store output if it does not already exist.

if ~exist(output_directory, 'dir')
    mkdir(output_directory)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Prepare data and load correct
%fully trained network
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Use datastore to assess both evaluation data and original
%training data

imageFolder = image_directory;
imageFolder2 = Training_location;

imds = imageDatastore(imageFolder, 'LabelSource', 'foldernames',...
    'IncludeSubfolders',true,'FileExtensions','.mat', 'ReadFcn',@matReader);

imds2 = imageDatastore(imageFolder2, 'LabelSource', 'foldernames',...
    'IncludeSubfolders',true,'FileExtensions','.mat', 'ReadFcn',@matReader);


%define size of images

x_pixel_size=64;
y_pixel_size=64;


% Load most recently trained model with the
% correct number of classifications

numClassesformodel2 = numel(categories(imds2.Labels));
disp(numClassesformodel2)


%Extract all .mat files trained with correct number of classifications
% from the model location

ext = strcat(string(numClassesformodel2),'.mat');
Files=dir(fullfile(model_directory,'*.mat'));

Namefiles = [];
Selectedfiles = [];
for i = 1:length(Files)
    Holding = Files(i).name;
    disp(Files(i).name)
    disp(ext)
    TF = contains(Holding,ext);
    disp(TF)
    if TF>0
        Selectedfiles{i} = Holding;
    else
        Selectedfiles{i} = '0';

    end
end
AA22 = find(matches(Selectedfiles,'0'));
Selectedfiles(AA22) = [];
patterns = [];
for j = 1:length(Selectedfiles)
    patterns = Selectedfiles{j}
    M = size(Files);
    %
    for k = 1:M(1)
        AA = find(matches(Files(k).name,patterns))

        % Determine the date of training

        if length(AA)>0
            disp(Files(1).date)
            DD{j} = Files(k).date;
            EE{j} = Files(k).name;
        end
    end


    patterns = [];
end

%Select most recently trained model

DD2 = DD;
V = split(DD2,' ');
if length(DD2)>1
    New1 = datenum(V(:,:,1))
    [a,b] = max(New1);
    [anew,bnew] = find(New1 ==a);
    New2 = [];
    New22 = [];
    if length(anew)>1
        New2 = replace(V(:,:,2),':','');
        for m = 1:length(New2)
            New22(m) = str2num(New2{m});
        end
        testingvals = [];
        for t = 1:length(anew)
            testingvals(t) = New22(anew(t));
        end
        [a2,b2] = max(testingvals);

        index = anew(b2);

    else
        index = anew;

    end
    nametouse = EE{index};
else
    nametouse = EE;
end






ss = strcat(model_directory,'\',nametouse);
disp(ss)
tf = isa(ss,'string');
disp(tf)
load(ss,'trainedNet')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Prepare data and load correct
%fully trained network
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Use model to classify images

[YPred,probs] = classify(trainedNet,imds);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Use data to evaluate model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Compare predicted labels with actual images labels to find accuracy

accuracy = mean(YPred == imds.Labels);

%Save accuracy value to specified output location

name = 'accuracyvalues.csv';
fullnameandpath1 = strcat(output_directory,'\',name);
csvwrite(fullnameandpath1,'accuracy');

%Create a confusion plot and save this to specified output location

imds.Labels = removecats(imds.Labels);
YPred = removecats(YPred);
hh = plotconfusion(imds.Labels,YPred);
vv = 'confusion_matrix.png';
fullnameandpath2 = strcat(output_directory,'\',vv);
saveas(hh,fullnameandpath2)

%Create a confusion plot of ALL classes, even if these are not present in
% evaluation data set. Save this to specified output location

fig = figure
grouporder = categories(imds2.Labels);
[C,order] = confusionmat(imds.Labels,YPred,'Order',grouporder);
hh2 = confusionchart(C,order);
ww = 'confusion_matrix_all_classes.png';
fullnameandpath4 = strcat(output_directory,'\',ww);
saveas(fig,fullnameandpath4)

%Save predicted classes for each of the evaluation images

name2 = 'Predictions.csv';
fullnameandpath3 = strcat(output_directory,'\',name2);
csvwrite(fullnameandpath3,'YPred');