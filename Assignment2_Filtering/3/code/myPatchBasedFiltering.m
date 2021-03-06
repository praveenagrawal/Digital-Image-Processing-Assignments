function [ imgOut, isotropic_gaussian] = myPatchBasedFiltering(img, sigma)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    img = double(img);
    imgOut = zeros(size(img));
    patchSize = 9;
    winSize = 25;
    [inRows, inColumns] = size(img); 
    isotropic_gaussian = fspecial('gaussian', [9 9]);
    
    imgPadded = padImage(img, winSize+patchSize-1);
    [imgPaddedRows, imgPaddedColumns] = size(imgPadded);
    for i = floor(winSize/2)+floor(patchSize/2)+1:1:floor(winSize/2)+floor(patchSize/2)+inRows
        for j = floor(winSize/2)+floor(patchSize/2)+1:1:floor(winSize/2)+floor(patchSize/2)+inColumns
            %Selecting windows
            window = imgPadded(i-floor(winSize/2):i+floor(winSize/2), j-floor(winSize/2):j+floor(winSize/2)); %Selecting the window
            %Selecting patches
            patch = imgPadded(i-floor(patchSize/2):i+floor(patchSize/2), j-floor(patchSize/2):j+floor(patchSize/2));    
            winWeights = zeros(winSize);
            for k = 1:1:winSize
                for l = 1:1:winSize
                    %Selecting the other patches inside the window
                    newPatch = imgPadded((i-12+k-1)-floor(patchSize/2):((i-12+k-1)+floor(patchSize/2)), (j-12+l-1)-floor(patchSize/2):(j-12+l-1)+floor(patchSize/2));
                    winWeights(k,l)=(sum(sum(((newPatch-patch).*isotropic_gaussian).^2)));
                end
            end
            norm = sum(sum(exp(-winWeights/(sigma^2))));
            winWeights = exp(-winWeights/(sigma^2))/norm;
            imgPadded(i,j) = sum(sum(window.*winWeights));
        end
    end
    imgOut =imgPadded(floor(winSize/2)+floor(patchSize/2)+1:floor(winSize/2)+floor(patchSize/2)+inRows,floor(winSize/2)+floor(patchSize/2)+1:inColumns+floor(winSize/2)+floor(patchSize/2));
end


