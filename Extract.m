image_directory = 'C:\Documents\images';
model_directory = string('C:\Documents\Trainedmodel');
output_directory = 'C:\Documents\featureplots';
Training_location = 'C:\Documents\Trainingimages';
totalpath = 'C:\umapDistribution\umap';
path1 = totalpath;
addpath(path1)
totalpath = 'C:\umapDistribution\util';
path2 = totalpath;
addpath(path2)
totalpath = 'C:\umapDistribution\umap.jar';
path3 = totalpath;
javaaddpath(path3)

%Choose layer to visualise
%'avg_pool_4_4'
%'activation_25_relu';
%'activation_43_relu';
%Create folder to store all features and plots if this folder
%does not already exit

Layer = 'avg_pool_4_4';
ccc =  '1'; % Channels included in your data

if ~exist(output_directory, 'dir')
    mkdir(output_directory)
end

%Determine which layer the user would like to extract features
%from.


channels =str2num(ccc);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Prepare data and load correct
%fully trained network
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Split the data in the same way as it was seperated for
%training

Datasplit = '80/20';
AA = split(Datasplit,"/");
Valuedata_split2 = str2num(AA{1});

imageFolder = image_directory;
imds = imageDatastore(imageFolder, 'LabelSource', 'foldernames',...
    'IncludeSubfolders',true,'FileExtensions','.mat', 'ReadFcn',@matReader);


[imdsTrain,imdsValidation] = splitEachLabel(imds,(Valuedata_split2/100),'randomized');


%Define size of images used

number_of_channels = length(channels);
x_pixel_size = 64;
y_pixel_size = 64;

%Augment data

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

% Load correct model from which to extract features


numClassesformodel2 = numel(categories(imdsTrain.Labels));

ext = strcat(string(numClassesformodel2),'.mat')

%Extract all .mat files stored at model location

Files=dir(fullfile(model_directory,'*.mat'));
Namefiles = [];
Selectedfiles = [];
for i = 1:length(Files)
    Holding = Files(i).name
    TF = contains(Holding,ext)
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
        %
        % Determine the date each model was created

        if length(AA)>0
            DD{j} = Files(k).date;
            EE{j} = Files(k).name;
        end
    end


    patterns = [];
end

% Find most recent model

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


%Load correct model

ss = strcat(model_directory,'\',nametouse);

load(ss, 'trainedNet')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Generate features from chosen layer of model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

layer = Layer;
featuresTrain = activations(trainedNet,augimdsTrain,layer,'OutputAs','rows');

%Generate labels for each of the images so that colour coding
%may be applied to all plots

Augmented = augimdsTrain.Files;
Holder = [];
label = [];
for i = 1:length(Augmented)
    [a,b,e] = fileparts(Augmented{i});
    Holder{i} = a;
end
tf = []
BB = []
charArr = cellfun(@num2str, Holder, 'Un', 0 );
UniqueAugmented = unique (charArr, 'rows');
for i = 1:length(Augmented)
    BB{i} = Holder{i};
    for j = 1:length(UniqueAugmented)
        strtesting{j} = UniqueAugmented{j};
        tf(j) = strcmp(strtesting{j},BB{i})

    end


    [a,b] = find(tf==1)
    label(i) = b
end
vv = label;
disp(categories(imdsTrain.Labels))
labs = unique(vv);
% Define the two colormaps
cmap1 = hot(length(labs));
cmap2 = winter(length(labs)) 
% Combine them into one tall colormap.
combinedColorMap = [cmap1; cmap2]
% Pick 15 rows at random.
randomRows = randi(size(combinedColorMap, 1), [length(labs), 1])
% Extract the rows from the combined color map
randomColors = combinedColorMap(randomRows, :);

labels_graph = categories(imds.Labels);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot features and save all output to folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Save features extacted as .csv and .mat files

name = 'features.mat';
fullfilepath = strcat(output_directory,'\',name);
save(fullfilepath,'featuresTrain');

name2 = 'featuresforumap.csv';
fullfilepath7 = strcat(output_directory,'\');


if ~exist(fullfilepath7, 'dir')
    mkdir(fullfilepath7)
end
Locationforcsv2 = strcat(fullfilepath7,name2);
csvwrite(Locationforcsv2,featuresTrain)

%Create and save basic 2D and 3D tSNE plots of features, colour coded according to
%classification








%%%%
labels_graph = categories(imds.Labels);
%%%%%



Y = tsne(featuresTrain);
labellen = unique(vv)
for i = 1:length(labellen)
    [a,b] = find(vv == i)
    scatter(Y(b,1),Y(b,2),15,'MarkerEdgeColor',randomColors(i,:),...
    'MarkerFaceColor',randomColors(i,:),...
    'LineWidth',1.5)
    hold on

end
legend (labels_graph)
fi =gcf 






xlabel('x')
ylabel('y')
hold off

vvv = 'tSNEplot.png';
vvv2 = '3DtSNEplot.png';
fullfilepath1 = strcat(output_directory,'\',vvv);
fullfilepath2 = strcat(output_directory,'\',vvv2);
saveas(fi,fullfilepath1)
[Y2,loss2] = tsne(featuresTrain,'Algorithm','exact','NumDimensions',3);
hold off



hold on

%%%%
labels_graph = categories(imds.Labels);
%%%%%



[Y2,loss2] = tsne(featuresTrain,'Algorithm','exact','NumDimensions',3);



for i = 1:length(labellen)
    [a,b] = find(vv == i)
    scatter3(Y2(b,1),Y2(b,2),Y2(b,3),15,'MarkerEdgeColor',randomColors(i,:),...
    'MarkerFaceColor',randomColors(i,:),...
    'LineWidth',1.5)
    hold on

end
legend (labels_graph)
 fi2 =gcf
%             h1 = scatter3(Y2(:,1),Y2(:,2),Y2(:,3),15,vv,'filled')
%      h1 = plot3(Y2(:,1),Y2(:,2),Y2(:,3),'.','markersize',30,'color',vv)
xlabel('x')
ylabel('y')
zlabel('z')
hold off


saveas(fi2,fullfilepath2)

%Create and save basic 3D PCA plot of features, colour coded according to
%classification
[coeff,score,latent,tsquared,explained] = pca(featuresTrain);
hold off

hold on


for i = 1:length(labellen)
    [a,b] = find(vv == i)
    scatter3(score(b,1),score(b,2),score(b,3),15,'MarkerEdgeColor',randomColors(i,:),...
    'MarkerFaceColor',randomColors(i,:),...
    'LineWidth',1.5)
    hold on

end
legend (labels_graph)

fi3 =gcf
%             
%             h1 = scatter3(Y2(:,1),Y2(:,2),Y2(:,3),15,vv,'filled')
%      h1 = plot3(Y2(:,1),Y2(:,2),Y2(:,3),'.','markersize',30,'color',vv)


%              hh2 = scatter3(score(:,1),score(:,2),score(:,3),15,vv,'filled')


xlabel('1st Principal Component')
ylabel('2nd Principal Component')
zlabel('3rd Principal Component')
nameplot = 'PCA3Dplot.png';
 nameplot2 = 'PCA3Dplot.fig';
fullfilepath3 = strcat(output_directory,'\',nameplot);
fullfilepath3b = strcat(output_directory,'\',nameplot);
%legend(imds.Labels)
legend(labels_graph)
saveas(fi3,fullfilepath3)
saveas(fi3,fullfilepath3b)

%If paths to UMAP have been added this section is executed and
%a basic UMAP plot is generated

%if ~isempty(app.UmapEditField) && ~isempty(app.UtilEditField) && ~isempty(app.UmapjarEditField)
close all




%             

name2 = 'featuresforumap.csv';
fullfilepath4 = strcat(output_directory,'\','Dataforumap\');


if ~exist(fullfilepath4, 'dir')
    mkdir(fullfilepath4)
end
Locationforcsv = strcat(fullfilepath4,name2);

fullfilepath5 = strcat(output_directory,'\','Dataforumap\');
if ~exist(fullfilepath5, 'dir')
    mkdir(fullfilepath5)
end

name3 = 'template2D.mat';
Locationfortemplate = strcat(fullfilepath5,name3);
csvwrite(Locationforcsv,featuresTrain)


figure(5)
h1 = run_umap(Locationforcsv,'save_template_file',Locationfortemplate)
nameplot1 = 'UMAP2Dplot.fig';
fullfilepath7 = strcat(output_directory,'\',nameplot1);
savefig(fullfilepath7)

figure(6)
h2 = run_umap(Locationforcsv, 'n_components',3,'save_template_file',Locationfortemplate)
nameplot2 = 'UMAP3Dplot.fig';
fullfilepath6 = strcat(output_directory,'\',nameplot2);
savefig(fullfilepath6)