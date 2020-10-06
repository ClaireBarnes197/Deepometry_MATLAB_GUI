# Deepometry (MATLAB version)
Deep learning-based image classification and featurization for imaging (flow) cytometry.

This workflow was originally built for imaging flow cytometry data but can be readily adapted for any microscopic images of isolated single objects. The modified implementation of ResNet50 allows researchers to use data made up of any number of color channels.

# Installation - MATLAB users

The MATLAB version of Deepometry requires the following toolboxes:

        1. Statistical toobox
        2. Deep learning toolbox
    
Deepometry also makes use of the MATLAB version of [bioformats,](www.openmicroscopy.org/bio-formats/downloads/) a standalone Java library for reading and writing life science image file formats.(Please note that the minimum MATLAB version recommended for this package is R2017b). Lastly, this version completes some basic plots of features learnt from data by applying several dimensional reduction techniques, in particular, UMAP. A MATLAB version can be downloaded from [File Exchange](www.mathworks.com/matlabcentral/fileexchange/71902-uniform-manifold-approximation-and-projection-umap). 

Full installation instructions to install the MATLAB version of Deepometry can be found [here]

# Installation - Non- MATLAB users

Non-MATLAB users may download and install our standalone GUI. Download the sharable folder and simply right clicking on the file, ‘MyAppinstaller.web.exe’. This will begin installation process which may take a few minutes. 

Full installation instructions to install the MATLAB version of Deepometry can be found [here]

# Use

Deepometry may be executed in a of ways:

# MATLAB

Switch to the MATLAB branch.

Once the sharable folder containing the app and all accompanying functions has been downloaded, this may be run by either typing >> GUI_deepometry at the command line or by navigated to the file and hitting the run button at the top of the window. 

# Standalone GUI (highly recommended)

Switch to the GUI branch

Once the app has been installed it will be found in the program folder of your machine. This app is run by simply right clicking on the executable.

![images](https://user-images.githubusercontent.com/72154816/95145308-cc4a0000-0772-11eb-8451-3c2f48ae2106.jpg)

Deepometry involves several important steps

**1. Parsing data:**

This stage involves the transformation of single-cell image data from .TIF, .CIF (gated populations exported from IDEAS software) files, placed in a directory structure shown below:

![firstone](https://user-images.githubusercontent.com/72154816/95145594-96f1e200-0773-11eb-93b8-1f4c26254b25.jpg)

To .mat files, stored in subdirectories according to class label

![Secondone](https://user-images.githubusercontent.com/72154816/95146592-226c7280-0776-11eb-9463-b6a13c807ae0.jpg)

To action this step the user must input the following fields:

Essential user inputs:

_Channels:_ Choose the channel(s) imaged by the instrument (e.g. image flow cytometer, fluorescent microscopy). Multiple channels are specified as an array, e.g. 0,6,3,4. 

_Input location:_ choose the folder that contains original image inputs. Note: it is highly recommended to structure the input folder into hierarchical sub-folders tagged with Experiment ..., Day ..., Sample ..., Replicate ... , Class ...

_Output location:_ location to store the parsed .mat arrays. 

_Montage size (optional):_ use this option to generate per-channel tiled (stitched) montages, which can be efficiently used for CellProfiler. Leave blank for no stitching.

_Target classification:_ choose the target categories to train the classifier, e.g. choose "Samples" to instruct the model to learn to categorize Sample A, Sample B, Sample C; choose "Classes" to train the model to distinguish "Class Control_cells", "Class Treated_cells" and so on. This will instruct the app to place images in subfolders named according to your classification labels. 

**2. Model training**

This step allows the user to train MAT:AB's version of ResNet50 according to your specification classification task. 

Essential user inputs:

Input location: choose the folder that contains parsed numpy arrays (from step 1).
Output location: location to store the trained model.
Target classification: choose the target categories to train the classifier, e.g. choose "Samples" to instruct the model to learn to categorize Sample A, Sample B, Sample C; choose "Classes" to train the model to distinguish "Class Control_cells", "Class Treated_cells" etc...
Learning iteration: the number of epochs for a deep learning training session. By default it is set to 512, which might take several days (depends on the size of the training materials and available hardware, especially GPUs).
More (hyper)parameters for model training can be set at model.fit.





















