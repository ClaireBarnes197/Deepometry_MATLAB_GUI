image_directory =  'C:\Users\Paul\Desktop\AABBBlatestggggNEWNEWNEW'; %Input directory containing preprocessed images
output_directory = 'C:\Users\Paul\Desktop\AABBBlatestggggNEWNEWNEWbbb';%Specify where to store your fully trained model
channel_holder =  '1';%Channels to be included in training your model




Iterations_num =  '1'; %Specify how many training epoch you wish to use
Iterations_num2 = str2num(Iterations_num);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Prepare and organise data for training
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%At present a default training/validation split of 80/20 is
%applied to the data (80% training and 20% testing)

channels =str2num(channel_holder);
Datasplit = '80/20';

imageFolder = image_directory;

%imageDatastore is used to pass images to the network without
%having to load all images into memory

imds = imageDatastore(imageFolder, 'LabelSource', 'foldernames',...
    'IncludeSubfolders',true,'FileExtensions','.mat', 'ReadFcn',@matReader);


%Determine number of classes
numClasses = numel(categories(imds.Labels));


AA = split(Datasplit,"/");
Valuedata = str2num(AA{1});

[imdsTrain,imdsValidation] = splitEachLabel(imds,(Valuedata/100),'randomized');

%Specify size of images

number_of_channels=length(channels);
x_pixel_size=64;
y_pixel_size=64;


% LOAD RESNET50
net = resnet50;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Modify ResNet50 for our dataset
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Extract the layer graph from the trained network and plot the layer graph.
lgraph = layerGraph(net);



net.Layers(1)



% New input layer
new_input_layer = [imageInputLayer([x_pixel_size y_pixel_size number_of_channels],'Name','input')]
lgraph = replaceLayer(lgraph,'input_1', new_input_layer);
% New 2 channel conv layer
new_conv1_layer = ...
    convolution2dLayer([3,3],64,'Stride', [1,1] , 'Padding', [1,1,1,1],'Name','new_conv1');

lgraph = replaceLayer(lgraph,'conv1', new_conv1_layer);


% Replacing last three layers for transfer learning / retraining
lgraph = removeLayers(lgraph, {'ClassificationLayer_fc1000','fc1000_softmax','fc1000','avg_pool'});
% Define layers
numClasses = numel(categories(imdsTrain.Labels));
newLayers = [
    averagePooling2dLayer(2,'Stride',1,'Name','avg_pool_4_4')
    fullyConnectedLayer(numClasses,'Name','fc','WeightLearnRateFactor',10,'BiasLearnRateFactor',10)
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classoutput')]
lgraph = addLayers(lgraph,newLayers);


lgraph = connectLayers(lgraph,'activation_49_relu','avg_pool_4_4');


%             analyzeNetwork(lgraph)

% Data augmentation

inputSize=[ x_pixel_size; y_pixel_size; number_of_channels]';
pixelRange = [-30 30];
imageAugmenter = imageDataAugmenter( ...
    'RandRotation',[0 360], ...
    'RandXReflection',true, ...
    'RandYReflection',true, ...
    'RandXTranslation',pixelRange, ...
    'RandYTranslation',pixelRange)
augimdsTrain = augmentedImageDatastore(inputSize,imdsTrain,'DataAugmentation',imageAugmenter);
augimdsValidation = augmentedImageDatastore(inputSize,imdsValidation);

% Set training options

options = trainingOptions('sgdm', ...
    'MiniBatchSize',64, ...
    'MaxEpochs',Iterations_num2, ... % was 6
    'LearnRateSchedule', 'piecewise', ...
    'InitialLearnRate',1e-3, ...
    'LearnRateDropFactor',0.9, ...
    'LearnRateDropPeriod',50, ...
    'ValidationData',augimdsValidation, ...
    'ValidationFrequency',3000, ...
    'ValidationPatience',Inf, ...
    'Verbose',false, ...
    'Plots','training-progress',...
    'ExecutionEnvironment','parallel')


% Set a time and date stamp for the network
modelDateTime = datestr(now,'dd-mmm-yyyy-HH-MM-SS');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Train network
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[trainedNet, traininfo] = trainNetwork(augimdsTrain,lgraph,options);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Saving model and produce some initial
%validation plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Name model according to number of training classes
if ~exist(output_directory, 'dir')
    mkdir(output_directory)
end

numClassesformodel = num2str(numClasses);
name = strcat('Deepometry-Trained_net_', modelDateTime, '_',numClassesformodel,'.mat');

%             app.Location = uigetdir; 
%             temp = app.Net; 
% %             save(fullfile(app.Location, 'Saved network'), 'temp');
%              fullnameandpath = fullfile(output_directory,'\',name);


name2 = strcat(output_directory,'\',name);
save(name2,'trainedNet');               





% Classify Validation Images
[YPred,probs] = classify(trainedNet,augimdsValidation);
accuracy = mean(YPred == imdsValidation.Labels)


imdsValidation.Labels = removecats(imdsValidation.Labels);

YPred = removecats(YPred);

plotconfusion(imdsValidation.Labels,YPred)

% Display some sample images with predicted probabilities

idx = randperm(numel(imdsValidation.Files),36);
figure
for i = 1:36
    subplot(6,6,i)
    I = readimage(imdsValidation,idx(i));
    imshow(I(:,:,1),[])
    label = YPred(idx(i));
    title(string(label) + ", " + num2str(100*max(probs(idx(i),:)),3) + "%");
end