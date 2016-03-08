function I = main(imsize, numCells, batchSize, cellRoughness, writeRGB)

%MAIN generates 2D/3D synthetic (ground truth) images for membrane-based 
% segmentation, adds noise to them, and runs selected segmentation algorithms on these generated
% test images.
% 
%
% Example:
%   main([256 256 50], 150, 5, 3, 1)
%
% IN:
%   imsize        - size of the to-be generated image: exp: [512 512]. If
%                   length(imsize)==1, then a square image is produced.
%                   X and Y dimensions must be a multiple of 32.
%   numCells      - approximate number of cells to be generated in the image
%   batchSize     - the number of GT images to be generated
%   cellRoughness -  defines how rough the cells will be. Only 3D, Integer-value
%   writeRGB      - if 1, an RGB image will be written as well. 
%
% Copyright: Omer Demirel (omerddd@gmail.com), University of Zurich, 2015
%% sanity checks
if isempty(imsize)
    warning('Forgot to specify IMSIZE: Default size [512x512] is applied')
    imsize = [512 512];
elseif ndims(imsize)==1
    error('IMSIZE should be either 2D or 3D.')
elseif ndims(imsize)>3
    error('GTGen can generate only 2D/3D images. Please check your IMSIZE again')
end
if batchSize<1
    error('BATCHSIZE >= 1')
end
if cellRoughness<1
    error('CELLSURFACEROUGHNESS should be an integer >=1')
elseif length(imsize)==2
    warning('2D image.. CELLSURFACEROUGNESS is ignored')
elseif ( mod(imsize(1),32)~=0 || mod(imsize(2),32)~=0)
    error('IMSIZE dimensions (X and Y) must be a multiple of 32.')
end

%% generate GT images
cd GTGen
I_GT = GTGen(imsize, numCells, batchSize, cellRoughness, writeRGB);
assignin('base','I_GT',I_GT)
disp('New images are created')
%% add noise.
allGt = dir('*_label.tif');
gt_folder = pwd;
for i=1:length(allGt)
    cd(gt_folder)
    I = noiseSim(allGt(i).name,'cloudy',1.8); 
end
disp('Noise added to all images')
%% run algorithms
disp('Running segmentatiopn algorithms...')
cd('../../Noise/test_images/')
% marker-controlled watershed
allTest = dir('*.tif');
if isempty(allTest)
    error(['No synthetic data is found in ' pwd]);
end
testdata_folder = pwd;
disp('marker-controlled watershed...')
paramSweep_mcws(testdata_folder)

% multiscale marker-controlled watershed
disp('multiscale marker-controlled watershed...')
paramSweep_msmcw(testdata_folder)
cd('../../GTGen/gt_images');