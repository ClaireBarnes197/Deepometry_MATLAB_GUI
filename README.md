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

![Standalone app](https://github.com/ClaireBarnes197/Deepometry_MATLAB_GUI/images.jpg?raw=true)

















