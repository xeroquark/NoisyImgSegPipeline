% Dr. Omer Demirel - 05/2015,
% Multiscale Marker-controlled Watershed segmentation,
% University of Zurich. oemer.demirel@uzh.ch
%
% In multiscale marker-controlled watershed segmentation (MSMCW), we generate two watershed
% segmentations with different Gaussian kernel widths. 2nd level, which has
% more segmented regions than the 1st one, is used to correct the borders
% in the first scale. This means that MSMCW has to get the number of regions
% correct in the first scale.
function [] = run_msmcws(filename,sigmaVec,h)
I = read3D(filename);
label_i = msmcws3d(I,sigmaVec,h);
warning('off','all')
% visualize results
sizeI = size(I);
if length(sizeI)==3
    [gx,gy,gz] = gradient(double(label_i));
    label_i((gx.^2+gy.^2+gz.^2)~=0) = 0;
else
    [gx,gy] = gradient(double(label_i));
    label_i((gx.^2+gy.^2)~=0) = 0;
    label = label_i;
    %     rgb = label2rgb(label,'jet', [.5 .5 .5]);
    %     figure, imshowpair(I,rgb,'MONTAGE'),title('Merged');
end

% write results
%% black & white TIF output
label_i(label_i~=0)=10000;
% label_i = im2bw(label_i, 0.95);
outputFileName = ['multi_ws_' filename '_s' num2str(sigmaVec(1)) '-' num2str(sigmaVec(2)) '-' num2str(sigmaVec(3)) '_h' num2str(h) '.tif'];
if exist(outputFileName, 'file')==2
    delete(outputFileName);
end
cd('../../Algorithms/multiscale_mcws/results')
for K=1:length(label_i(1, 1, :))
    label = label_i(:, :, K);
    label = im2bw(~label,0.95);
    imwrite(label, outputFileName, 'WriteMode', 'append','Compression','none');
end
cd('../../../Noise/test_images')
% cd('/Users/demirelo/Documents/Work/ScienceCloud/Segmentation/automatedPipeline/Algorithms/')
% cd(folder)
end
