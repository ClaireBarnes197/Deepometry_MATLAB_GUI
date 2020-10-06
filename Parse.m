original_imageFolder =  'C:\Documents\Imagesraw'; %Enter the location of your images here
save_new_imageFolder = 'C:\Documents\Imagesparsed'; % Enter where to store parsed images here
channels_holder =  '1'; %Enter the channels you would like to include for analysis
Montage_size = 10; %If you wish to montage images enter size here, otherwise input a value of 0
pathtobio = 'C:\Downloads\bfmatlab\bfmatlab'; %If you have .Cif images input path to bioformats here
%Create a unique list of labels for images
%Choose level of directorty structure to use for classification
%1 = Experiment
%2 = Days
%3 = Samples
%4 = Replicates
%5 = Classes

Classification = 1;


channels =str2num(channels_holder);


rootdir = original_imageFolder;
filelist = dir(fullfile(rootdir, '**\*.*'));
filelist = filelist(~[filelist.isdir]);


%Determine format of the image files


for k =1:length(filelist)
namep = filelist(k).name;
pattern = 'tif';
pattern2 = 'cif';
TF(k) = contains(namep,pattern);
TF2(k) = contains(namep,pattern2);
end
[a,b] = find(TF>0);
[a2,b2] = find(TF2>0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Execute if tif images are found
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if length(a)>0

File_listings = struct2cell(filelist);
File_listings_transposed = File_listings';
newStr = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Clean data, removing any images with missing channels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
File_directory = File_listings_transposed(:,2);

files = File_listings_transposed(:,1);
Total_path = strcat(File_directory,'\',files);

%Find groups of images based on subdirectories

ind = findgroups(File_directory);
Number_groups = max(ind);
groups_ = [];
LChan = length(channels);


Total_path2 = Total_path;
files2 = files;
File_directory2 = File_directory;

AA = [];
Holder = [];
B = [];
for i = 1:Number_groups
    [a,b] = find(ind==i);
    AA = files(a);
    Holder = File_directory(a);
    B = split(AA,"Ch");

    S = length(a);
    if S == 1
        B = B';
    end


    Names_ = [];
    ind2 = [];
    for j = 1:length(a)
        Names_{j} = B{j,1};
    end

    %Group images according to filenames


    ind2 = findgroups(Names_);


    %Check to see if images have all specified channels


    for t = 1:max(ind2)
        [aa,bb] = find(ind2==t);
        AA2 = [];
        Holder2 = [];
        Overall = [];
        for k = 1:length(bb)
            AA2{k} = strcat(B{bb(k),1},'Ch',B{bb(k),2});
            Holder2{k} = Holder{bb(k)};
            Overall{k} = strcat(Holder2{k},'\',AA2{k});
        end

        for m = 1:LChan
            v = num2str(channels(m));
            pattern1 = strcat('Ch',v,'.');
            TF = contains(AA2,pattern1);
            [a3,b3] = find(TF==1);



            if length(a3) ==0
                for ii =1:length(AA2)
                    pattern2 = Overall{ii}
                    Index = find(matches(Total_path,pattern2));
                    Total_path2{Index} = '0';
                    files2{Index} = '0';
                    File_directory2{Index} = '0';
                end


            end
        end
    end

    AA = [];
    Holder = [];
    B = [];
end

%Groups of images without a full set of channels are deleted
%from list


AA22 = find(matches(Total_path2,'0'));
Total_path2(AA22) = [];
AA22 = find(matches(File_directory2,'0'));
File_directory2(AA22) = [];
AA22 = find(matches(files2,'0'));
files2(AA22) = [];
File_directory_new1 = File_directory2;
files_new1 = files2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Remove channels not specified from the list of images to be
%processed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

File_directory_new = [];
files_new = [];
Lchan = length(channels);


for k =1:length(files_new1)
    namep = files_new1{k};
    TK3 = [];
    for m = 1:Lchan

        pattern = string(channels(m));
        patternfinal = strcat('Ch',pattern,'.');
        TK3(m) = contains(namep,patternfinal);
    end
    [a,b] = find(TK3==1);
    if length(a)>0
        files_new{k} = files_new1{k};
        File_directory_new{k} = File_directory_new1{k};

    else
        files_new{k} ='0';
        File_directory_new{k} = '0';

    end
    namep =[];
end

%Delete all additional channel images from list

AA22 = find(matches(files_new,'0'))
files_new(AA22) = [];
files_new = files_new';
AA33 = find(matches(File_directory_new,'0'))
File_directory_new(AA33) = [];

newStr = [];
strtester = [];
newStr = [];
tokenNames = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analyse the directory structure and radio button selection to
% determine the labels for the processed images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:length(File_directory_new)
    strtester = File_directory_new(i);

    expression = original_imageFolder;
    matchStr = regexp(strtester,expression,'match');
    testing = erase(strtester,expression);
    newStr{i} = testing;

    newChr = char(newStr{i});
    A = count(newStr{i},"\");
    B = strrep(newChr,'\','/');
    if A == 1
        expression = ['/(?<Experiment>\w+)|'];
        tokenNames{i} = regexp(B,expression,'names');
    elseif A == 2
        expression = ['/(?<Experiment>\w+)/(?<Days>\w+)|'];
        tokenNames{i} = regexp(B,expression,'names');
    elseif A == 3
        expression = ['/(?<Experiment>\w+)/(?<Days>\w+)/(?<Sample>\w+)|'];
        tokenNames{i} = regexp(B,expression,'names');
    elseif A == 4
        expression = ['/(?<Experiment>\w+)/(?<Days>\w+)/(?<Sample>\w+)/(?<Replicates>\w+)|'];
        tokenNames{i} = regexp(B,expression,'names');
    else
        expression = ['/(?<Experiment>\w+)/(?<Days>\w+)/(?<Sample>\w+)/(?<Replicates>\w+)/(?<Classes>\w+)|'];
        tokenNames{i} = regexp(B,expression,'names');
    end
    Selected{i} = tokenNames{i};
end

b = size(Selected);


Experimentgroup = [];
Daysgroup = [];
Samplegroup = [];
Replicatesgroup = [];
Classesgroup = [];


%Create a unique list of labels for images

for i = 1 : b(2)
    if Classification == 1
        if numel(fieldnames(Selected{i}))>=1
            Experimentgroup{i} = Selected{i}.Experiment;
        end
    elseif Classification == 2
        if numel(fieldnames(Selected{i}))>=2
            Daysgroup{i} = Selected{i}.Days;
        end
    elseif Classification == 3
        if numel(fieldnames(Selected{i}))>=3
            Samplegroup{i} = Selected{i}.Sample;
        end
    elseif Classification == 4
        if numel(fieldnames(Selected{i}))>=4
            Replicatesgroup{i} = Selected{i}.Replicates;
        end
    elseif Classification == 5
        if numel(fieldnames(Selected{i}))>=5
            Classesgroup{i} = Selected{i}.Classes;
        end
    end
end




BBBB = [];
if Classification == 1
    charArr = cellfun(@num2str, Experimentgroup, 'Un', 0 );
    Uniqueexperiment2 = unique (charArr, 'rows');
    Lengthexper = length(Uniqueexperiment2);
    for i =1:Lengthexper
        k = i;
        Uniqueexperiment{k} = Uniqueexperiment2{i};
        disp(Uniqueexperiment)
    end
    number_of_directories = Lengthexper;
elseif Classification == 2
    charArr = cellfun(@num2str, Daysgroup, 'Un', 0 );
    UniqueDays2 = unique (charArr, 'rows');
    LengthDays = length(UniqueDays2);
    for i =1:LengthDays
        k = i;
        UniqueDays{k} = UniqueDays2{i};
    end
    number_of_directories = LengthDays;
elseif Classification == 3
    charArr = cellfun(@num2str, Samplegroup, 'Un', 0 );
    UniqueSample2 = unique (charArr, 'rows');

    LengthSample = length(UniqueSample2);
    for i =1:LengthSample
        k = i;
        UniqueSample{k} = UniqueSample2{i};
    end
    number_of_directories = LengthSample;
elseif Classification == 4
    charArr = cellfun(@num2str, Replicatesgroup, 'Un', 0 );
    UniqueReplicates2 = unique (charArr, 'rows');
    LengthReplicates = length(UniqueReplicates2);
    for i =1:LengthReplicates
        k = i;
        UniqueReplicates{k} = UniqueReplicates2{i};
    end
    number_of_directories = LengthReplicates;
elseif Classification == 5
    charArr = cellfun(@num2str, Classesgroup, 'Un', 0 );
    UniqueClasses2 = unique (charArr, 'rows');
    LengthClasses2 = length(UniqueClasses2);
    for i =1:LengthClasses
        k = i;
        UniqueClasses{k} = UniqueClasses2{i};
    end
    number_of_directories = LengthClasses;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create the folder if it doesn't exist already.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist(save_new_imageFolder, 'dir')
    mkdir(save_new_imageFolder);
end

% Get directory info
FolderInfo = dir(original_imageFolder);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop through each of the classes and collect all
% images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for phenotype_loop=1:number_of_directories

    if Classification == 1
        directory_list=Uniqueexperiment{phenotype_loop};
    elseif Classification == 2
        directory_list=UniqueDays{phenotype_loop};
    elseif Classification == 3
        directory_list=UniqueSample{phenotype_loop};
    elseif Classification == 4
        directory_list=UniqueReplicates{phenotype_loop};
    elseif Classification == 5
        directory_list=UniqueClasses{phenotype_loop};
    end

    %Isolate images that belong to each class
    CC = [];
    RFiles = [];
    RFilesonly = [];

    for i = 1:length(File_directory_new)
        CC{i} = join([File_directory_new{i},'\',files_new{i}]);
        BB{i} = files_new{i};
    end

    str = directory_list;
    tf = contains(CC,str);
    [a,b] = find(tf>0);
    RFiles = CC(b);
    RFilesonly = BB(b);

    %Create a folder named according to class to store all
    %images

    save_new_imageFolder_pheno = fullfile([save_new_imageFolder,'\',directory_list]);
    if ~exist(save_new_imageFolder_pheno, 'dir')
        mkdir(save_new_imageFolder_pheno);
    end

    phenotype_directory_info = natsortfiles(RFilesonly);
    [~,ndx] = natsortfiles(RFilesonly);
    RFilesupdate = RFiles(ndx);
    SIZE_files = length(RFilesupdate);
    Lchan = length(channels);


    imageloop3 = Lchan - 1;
    for image_loop=1:((numel(phenotype_directory_info))/Lchan)
        m = 0;
        if Lchan == 1
            imageloop = imageloop3+1;
        else
            imageloop(1) = imageloop3+1;
            j = m+2;
            b = 1;
            for k = 2:Lchan

                imageloop(j) = imageloop(1)+b;
                j = j+1;
                b = b+1;
            end
        end
        image_name = [];
        image_matrix = [];
        data = [];
        channel11 =[];

        %collecting images from all channels and stacking them
        %into one 3D matrix
        padded_image_channel = [];
        for mm=1:Lchan

            image_name{mm}=phenotype_directory_info{imageloop(mm)};
            [~,image_name_without_ext{mm},~] = fileparts(image_name{mm});

            image_matrix{mm}=imread(RFilesupdate{imageloop(mm)});
            holder1 = image_matrix{mm};
            data{mm} = uint16(holder1);

            channel11{mm}=imresize(data{mm},0.9,'bilinear');

            %Pad or crop images to the correct size for the
            %network

            size_all(image_loop,mm)=size(data{mm},1);
            padded_image_channel{mm}=double(pad_image_to_correct_size2(channel11{mm},[64 64]));
            holder = padded_image_channel{mm};
            min_channel{mm} = double(min(holder(:)));
            max_channel{mm} = double(max(holder(:)));
            both_channels(:,:,mm)=((padded_image_channel{mm}-min_channel{mm})/(max_channel{mm}-min_channel{mm}))*255 ;
            new=uint8(both_channels(:,:,:));



            A = string(image_loop);



            channel = '_channel_all';
            name = strcat(A,channel);
            name2 = strcat(save_new_imageFolder_pheno,'\',directory_list,'_',name,'.mat');
            outputFileName = name2 ;
            save(name2, 'new')



        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If Monatge is required this section will be executed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if Montage_size>0
    for phenotype_loop=1:number_of_directories

        if Classification == 1
            directory_list=Uniqueexperiment{phenotype_loop};
        elseif Classification == 2
            directory_list=UniqueDays{phenotype_loop};
        elseif Classification == 3
            directory_list=UniqueSample{phenotype_loop};
        elseif Classification == 4
            directory_list=UniqueReplicates{phenotype_loop};
        elseif Classification == 5
            directory_list=UniqueClasses{phenotype_loop};
        end

        CC = [];
        RFiles = [];
        RFilesonly = [];

        %List all files to be considered for montaging

        for i = 1:length(File_directory_new)
            CC{i} = join([File_directory_new{i},'\',files_new{i}]);
            BB{i} = files_new{i};
        end

        str = directory_list;
        tf = contains(CC,str);
        [a,b] = find(tf>0);
        RFiles = CC(b);
        RFilesonly = BB(b);


        phenotype_directory_info = natsortfiles(RFilesonly);
        [~,ndx] = natsortfiles(RFilesonly);
        RFilesupdate = RFiles(ndx);
        SIZE_files = length(RFilesupdate);

        %determine number of images per tile and remaining images to be placed
        %on black background

        image_count = length(RFilesupdate);

        montage_size = Montage_size;
        montage_chunks = montage_size^2;

        n_chunks =floor((image_count)/length(channels));
        image_holder = [];
        extracted = [];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %When number of images is greater or equal to required
        %number for one tile, they should be stitched together
        %in the following way
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if n_chunks>=montage_chunks

            n_chunks
            montage_chunks
            Number_of_montage = floor(n_chunks/montage_chunks);

            Remaining_images = n_chunks-(Number_of_montage*montage_chunks);
            chunk_size = montage_chunks;
            Overall_size = image_count;
            %Collect together images from same channel

            for m = 1:length(channels)
                namep =[];
                TK3 = [];
                for k =1:length(RFilesupdate)
                    namep = RFilesupdate{k};
                    pattern = string(channels(m));
                    patternfinal = strcat('Ch',pattern,'.');
                    TK3(k) = contains(namep,patternfinal);
                end

                [aaa,bbb] = find(TK3>0);
                disp(TK3(120))
                disp(RFilesupdate{2})
                disp(bbb)
                BBB = 10/length(bbb);
                extracted = RFilesupdate(bbb);
                extracted{1};
                image_number = 0;
                vv = 0;

                %Create tiles of stitches images

                for l = 1:Number_of_montage

                    all_images = [];
                    chunk_size
                    Number_of_montage
                    for s = 1:chunk_size
                        value = s+vv
                        image_matrix=imread(extracted{value});
                        holder1 = image_matrix;
                        data = holder1;

                        image_holder=imresize(data,0.9,'bilinear');
                        padded_image_channel=uint8(double(pad_image_to_correct_size2(image_holder,[64 64])))
                        all_images = cat(3,all_images,padded_image_channel);


                    end

                    images_montage = montage(all_images);

                    montage_IM=images_montage.CData;
                    name_channel = strcat('Channel_',string(channels(m)));
                    Montage_no = string(l);


                    ImFileOut = strcat(save_new_imageFolder,directory_list,'Montage_images,','\');
                    if ~exist(ImFileOut, 'dir')
                        mkdir(ImFileOut);
                    end

                    nameoffile = strcat(name_channel,'Montage_',Montage_no,'.tif');
                    ImfileOutfinal = strcat(ImFileOut,nameoffile);

                    imwrite(montage_IM,ImfileOutfinal,'tif');


                    image_number = chunk_size+image_number;
                    vv = value;

                end
                all_images = [];
                if Remaining_images >0
                    start = Number_of_montage*montage_chunks;
                    for t = start+1:(start+Remaining_images-1)


                        image_matrix=imread(extracted{t});
                        holder1 = image_matrix;
                        data = holder1;

                        image_holder=imresize(data,0.9,'bilinear');
                        padded_image_channel=uint8(double(pad_image_to_correct_size2(image_holder,[64 64])));
                        all_images = cat(3,all_images,padded_image_channel);



                    end

                    images_montage = montage(all_images, 'Size', [montage_size montage_size]);
                    montage_IM=images_montage.CData;
                    name_channel = strcat('Channel_',string(channels(m)));
                    Montage_no = string(l+1);


                    ImFileOut = strcat(save_new_imageFolder,directory_list,'Montage_images,','\');
                    if ~exist(ImFileOut, 'dir')
                        mkdir(ImFileOut);
                    end

                    nameoffile = strcat(name_channel,'Montage_',Montage_no,'.tif');
                    ImfileOutfinal = strcat(ImFileOut,nameoffile);

                    imwrite(montage_IM,ImfileOutfinal,'tif');




                end

            end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        %When number of files is less than those required
        %for a tile
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        elseif n_chunks<montage_chunks

            Number_of_montage = 1;
            chunk_size = n_chunks;
            namep =[];
            TK4 = []
            extracted = [];

            for m = 1:length(channels)
                for k =1:length(RFilesupdate)
                    namep = RFilesupdate{k};
                    pattern = string(channels(m));
                    patternfinal = strcat('Ch',pattern,'.');
                    TK4(k) = contains(namep,patternfinal);
                end
                [aaa,bbb] = find(TK4>0)

                extracted = RFilesupdate(bbb);

                for l = 1:Number_of_montage

                    all_images = [];
                    for s = 1:chunk_size
                        image_matrix=imread(extracted{l});
                        holder1 = image_matrix;
                        data = holder1;

                        image_holder=imresize(data,0.9,'bilinear');
                        padded_image_channel=uint8(double(pad_image_to_correct_size2(image_holder,[64 64])));
                        all_images = cat(3,all_images,padded_image_channel);
                    end

                    images_montage = montage(all_images,'Size', [montage_size montage_size]);
                    montage_IM=images_montage.CData;
                    name_channel = strcat('Channel_',string(channels(m)));
                    Montage_no = string(l);


                    ImFileOut = strcat(save_new_imageFolder,directory_list,'Montage_images,','\');
                    if ~exist(ImFileOut, 'dir')
                        mkdir(ImFileOut);
                    end

                    nameoffile = strcat(name_channel,'Montage_',Montage_no,'.tif');
                    ImfileOutfinal = strcat(ImFileOut,nameoffile);

                    imwrite(montage_IM,ImfileOutfinal,'tif');
                end
            end
        end




    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%If .CIF files are present they are processed in the following way
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

else
%Add bioformats to the MATLAB search path


addpath(pathtobio)


File_listings = struct2cell(filelist);
File_listings_transposed = File_listings';
newStr = [];

File_directory = File_listings_transposed(:,2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Search directory structure to find classes to use for each
%image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

strtester = [];
newStr = [];
tokenNames = [];
Selected = [];
for i = 1:length(File_directory)

    strtester = File_directory(i);

    expression = original_imageFolder;
    matchStr = regexp(strtester,expression,'match');
    testing = erase(strtester,expression);
    newStr{i} = testing;

    newChr = char(newStr{i});
    A = count(newStr{i},"\");
    B = strrep(newChr,'\','/');
    if A == 1
        expression = ['/(?<Experiment>\w+)|'];
        tokenNames{i} = regexp(B,expression,'names');
    elseif A == 2
        expression = ['/(?<Experiment>\w+)/(?<Days>\w+)|'];
        tokenNames{i} = regexp(B,expression,'names');
    elseif A == 3
        expression = ['/(?<Experiment>\w+)/(?<Days>\w+)/(?<Sample>\w+)|'];
        tokenNames{i} = regexp(B,expression,'names');
    elseif A == 4
        expression = ['/(?<Experiment>\w+)/(?<Days>\w+)/(?<Sample>\w+)/(?<Replicates>\w+)|'];
        tokenNames{i} = regexp(B,expression,'names');
    else
        expression = ['/(?<Experiment>\w+)/(?<Days>\w+)/(?<Sample>\w+)/(?<Replicates>\w+)/(?<Classes>\w+)|'];
        tokenNames{i} = regexp(B,expression,'names');
    end
    Selected{i} = tokenNames{i};
end

b = size(Selected);

Experimentgroup = [];
Daysgroup = [];
Samplegroup = [];
Replicatesgroup = [];
Classesgroup = [];




for i = 1 : b(2)
    if Classification == 1
        if numel(fieldnames(Selected{i}))>=1
            Experimentgroup{i} = Selected{i}.Experiment;
        end
    elseif Classification == 2
        if numel(fieldnames(Selected{i}))>=2
            Daysgroup{i} = Selected{i}.Days;
        end
    elseif Classification == 3
        if numel(fieldnames(Selected{i}))>=3
            Samplegroup{i} = Selected{i}.Samples;
        end
    elseif Classification == 4
        if numel(fieldnames(Selected{i}))>=4
            Replicatesgroup{i} = Selected{i}.Replicates;
        end
    elseif Classification == 5
        if numel(fieldnames(Selected{i}))>=5
            Classesgroup{i} = Selected{i}.Classes;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Get unique list of class names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BBBB = [];
if Classification == 1
    charArr = cellfun(@num2str, Experimentgroup, 'Un', 0 );
    Uniqueexperiment2 = unique (charArr, 'rows');
    Lengthexper = length(Uniqueexperiment2);
    for i =1:Lengthexper
        k = i;
        Uniqueexperiment{k} = Uniqueexperiment2{i};
        disp(Uniqueexperiment)
    end
    number_of_directories = Lengthexper;
elseif Classification == 2
    charArr = cellfun(@num2str, Daysgroup, 'Un', 0 );
    UniqueDays2 = unique (charArr, 'rows');
    LengthDays = length(UniqueDays2);
    for i =1:LengthDays
        k = i;
        UniqueDays{k} = UniqueDays2{i};
    end
    number_of_directories = LengthDays;
elseif Classification == 3
    charArr = cellfun(@num2str, Samplegroup, 'Un', 0 );
    UniqueSample2 = unique (charArr, 'rows');

    LengthSample = length(UniqueSample2);
    for i =1:LengthSample
        k = i;
        UniqueSample{k} = UniqueSample2{i};
    end
    number_of_directories = LengthSample;
elseif Classification == 4
    charArr = cellfun(@num2str, Replicatesgroup, 'Un', 0 );
    UniqueReplicates2 = unique (charArr, 'rows');
    LengthReplicates = length(UniqueReplicates2);
    for i =1:LengthReplicates
        k = i;
        UniqueReplicates{k} = UniqueReplicates2{i};
    end
    number_of_directories = LengthReplicates;
elseif Classification == 5
    charArr = cellfun(@num2str, Classesgroup, 'Un', 0 );
    UniqueClasses2 = unique (charArr, 'rows');
    LengthClasses2 = length(UniqueClasses2);
    for i =1:LengthClasses
        k = i;
        UniqueClasses{k} = UniqueClasses2{i};
    end
    number_of_directories = LengthClasses;
end


% Create the folder if it doesn't exist already.
if ~exist(save_new_imageFolder, 'dir')
    mkdir(save_new_imageFolder);
end

% Get directory info
FolderInfo = dir(original_imageFolder);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop through classes and select all appropriate images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for phenotype_loop=1:number_of_directories
    % % % % %


    if Classification == 1
        directory_list=Uniqueexperiment{phenotype_loop};
    elseif Classification == 2
        directory_list=UniqueDays{phenotype_loop};
    elseif Classification == 3
        directory_list=UniqueSample{phenotype_loop};
    elseif Classification == 4
        directory_list=UniqueReplicates{phenotype_loop};
    elseif Classification == 5
        directory_list=UniqueClasses{phenotype_loop};
    end

    CC = [];
    RFiles = [];
    RFilesonly = [];
    disp(directory_list)


    CC = [];

    %Get images from each class

    for i = 1:size(File_listings_transposed,1)
        CC{i} = join([File_listings_transposed{i,2},'\',File_listings_transposed{i,1}]);

        pattern = directory_list;
        TF2 = contains(CC{i},pattern);
        if TF2>0



            %Use bioformats to read .CIF files
            Data21 = bfopen(CC{i});

            save_new_imageFolder_pheno = fullfile([save_new_imageFolder,'\',directory_list]);
            if ~exist(save_new_imageFolder_pheno, 'dir')
                mkdir(save_new_imageFolder_pheno);
            end
            Overall_size = length(Data21)
            nums = [1:2:Overall_size-1];
            for j = 1:(length(Data21)/2)
                both_channels = [];
                data = [];
                channel11 = [];
                padded_image_channel = [];
                min_channel=[];
                max_channel = [];
                for k = 1:length(channels)
                    p = channels(k);
                    image_current = Data21{nums(j),1}{p,1}
                    data{k} = uint16(image_current);
                    image_name{j}=join(directory_list,num2str(j))
                    %Pad or crop images to appropriate size
                    %for network
                    channel11{k}=imresize(data{k},0.9,'bilinear');
                    padded_image_channel{k}=double(pad_image_to_correct_size2(channel11{k},[64 64]));
                    holder = padded_image_channel{k};
                    min_channel{k} = double(min(holder(:)));
                    max_channel{k} = double(max(holder(:)));
                    both_channels(:,:,k)=((padded_image_channel{k}-min_channel{k})/(max_channel{k}-min_channel{k}))*255 ;

                end
                new=uint8(both_channels(:,:,:));
                A = string(j);
                channel = '_channel_all';
                name = strcat(A,channel);
                name2 = strcat(save_new_imageFolder_pheno,'\',directory_list,'_',name,'.mat');
                outputFileName = name2 ;
                save(name2, 'new')
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %If Montaging is required
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            if Montage_size>0
                Data_montage = bfopen(CC{i});
                omeMeta = Data_montage{1,4};
                image_count = omeMeta.getImageCount;

                %Determine number of images required for
                %each tile and number of images present
                montage_size = Montage_size;
                montage_chunks = montage_size^2;

                n_chunks =(image_count/2);
                image_holder = [];

                %If number of images is less than or equal
                %to number required per tile

                if n_chunks>=montage_chunks
                    Number_of_montage = floor(n_chunks/montage_chunks);

                    Remaining_images = n_chunks-(Number_of_montage*montage_chunks);
                    chunk_size = montage_chunks;
                    Overall_size = image_count;
                    nums = [1:2:Overall_size];

                    for m = 1:length(channels)
                        image_number = 0;
                        for l = 1:Number_of_montage

                            all_images = [];


                            %Stitch images together

                            for s = 1:chunk_size
                                image_current = Data_montage{nums(image_number+s),1}{channels(m),1};
                                data = image_current;

                                image_holder=imresize(data,0.9,'bilinear');
                                padded_image_channel=uint8(double(pad_image_to_correct_size2(image_holder,[64 64])));
                                all_images = cat(3,all_images,padded_image_channel);


                            end

                            images_montage = montage(all_images);

                            montage_IM=images_montage.CData;
                            name_channel = strcat('Channel_',string(channels(m)));
                            Montage_no = string(l);


                            ImFileOut = strcat(save_new_imageFolder,directory_list,'Montage_images,','\');
                            if ~exist(ImFileOut, 'dir')
                                mkdir(ImFileOut);
                            end

                            nameoffile = strcat(name_channel,'Montage_',Montage_no,'.tif');
                            ImfileOutfinal = strcat(ImFileOut,nameoffile);

                            imwrite(montage_IM,ImfileOutfinal,'tif');


                            image_number = chunk_size+image_number;


                        end
                        all_images = [];

                        %Place any remaining images of
                        %black background

                        if Remaining_images >0
                            start = Number_of_montage*montage_chunks;
                            for t = start+1:(start+Remaining_images-1)


                                image_current = Data_montage{nums(t),1}{m,1};
                                data = image_current;

                                image_holder=imresize(data,0.9,'bilinear');
                                padded_image_channel=uint8(double(pad_image_to_correct_size2(image_holder,[64 64])));
                                all_images = cat(3,all_images,padded_image_channel);


                            end

                            images_montage = montage(all_images, 'Size', [montage_size montage_size]);
                            montage_IM=images_montage.CData;
                            name_channel = strcat('Channel_',string(channels(m)));
                            Montage_no = string(l+1);


                            ImFileOut = strcat(save_new_imageFolder,directory_list,'Montage_images,','\');
                            if ~exist(ImFileOut, 'dir')
                                mkdir(ImFileOut);
                            end

                            nameoffile = strcat(name_channel,'Montage_',Montage_no,'.tif');
                            ImfileOutfinal = strcat(ImFileOut,nameoffile);

                            imwrite(montage_IM,ImfileOutfinal,'tif');




                        end

                    end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
                %If number of images is less than
                %number required per tile
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                elseif n_chunks<montage_chunks

                    Number_of_montage = 1;


                    chunk_size = n_chunks;


                    nums = [1:2:Overall_size-1];

                    for h = 1:length(channels)

                        for l = 1:Number_of_montage

                            all_images = [];
                            for s = 1:chunk_size
                                image_current = Data_montage{nums(s),1}{h,1};
                                data = image_current;

                                image_holder=imresize(data,0.9,'bilinear');
                                padded_image_channel=uint8(double(pad_image_to_correct_size2(image_holder,[64 64])));
                                all_images = cat(3,all_images,padded_image_channel);


                            end

                            images_montage = montage(all_images,'Size', [montage_size montage_size]);
                            montage_IM=images_montage.CData;
                            name_channel = strcat('Channel_',string(channels(h)));
                            Montage_no = string(l);


                            ImFileOut = strcat(save_new_imageFolder,directory_list,'Montage_images,','\');
                            if ~exist(ImFileOut, 'dir')
                                mkdir(ImFileOut);
                            end

                            nameoffile = strcat(name_channel,'Montage_',Montage_no,'.tif');
                            ImfileOutfinal = strcat(ImFileOut,nameoffile);

                            imwrite(montage_IM,ImfileOutfinal,'tif');
                        end
                    end
                end
            end
        end
    end




end






end
