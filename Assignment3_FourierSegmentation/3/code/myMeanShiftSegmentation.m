function [B, C] = myMeanShiftSegmentation(A, hs, hrgb, N, Niter)

A = double(A);

% Resizing the image
blur_mask = fspecial('gaussian',[3 3],1);
blur_img = imfilter(A, blur_mask);
% imshow(uint8([A, blur_img]));
B = imresize(blur_img, 0.5);

% hs = 32;  % Spatial kernel bandwidth
% hrgb = 32; % RGB-color kernel bandwidth
% N = 200; % Number of nearest neighbours
% Niter = 40; % Number of iterations
r = B(:,:,1);
g = B(:,:,2);
b = B(:,:,3);
x = 1:256;   % row number
y = 1:256;   % column number
x = repmat(x, [1,256]);
x = x';
y = repmat(y, [256,1]);
y = y(:);
C_5d = [x y r(:) g(:) b(:)];
NN = knnsearch(C_5d, C_5d, 'k', N);  % Index numbers of nearest neighours for each pixel value
NN_y = NN + 65536;
NN_r = NN + (2*65536);
NN_g = NN + (3*65536);
NN_b = NN + (4*65536);

i = 1;

while (i<=Niter)
CN_x = C_5d(NN);  % Each row has x-coordinate of nearest neighbours
CN_y = C_5d(NN_y);  % Each row has y-coordinate of nearest neighbours
CN_r = C_5d(NN_r);  % Each row has r-value of nearest neighbours
CN_g = C_5d(NN_g);  % Each row has g-value of nearest neighbours
CN_b = C_5d(NN_b);  % Each row has b-value of nearest neighbours

Wx = ((bsxfun(@minus,CN_x,C_5d(:,1))).^2)./(hs*hs); % Dim: 65536 x 200
Wy = ((bsxfun(@minus,CN_y,C_5d(:,2))).^2)./(hs*hs);
Wr = ((bsxfun(@minus,CN_r,C_5d(:,3))).^2)./(hrgb*hrgb);
Wg = ((bsxfun(@minus,CN_g,C_5d(:,4))).^2)./(hrgb*hrgb);
Wb = ((bsxfun(@minus,CN_b,C_5d(:,5))).^2)./(hrgb*hrgb);


Wt = sum((exp(-1*(Wx+Wy+Wr+Wg+Wb)))'); % Dinominator corresponding to each of 65536 positions

% Updated C_5d matrix
C_5d(:,1) = ((sum((CN_x.*(exp(-1*(Wx+Wy+Wr+Wg+Wb))))'))./Wt)'; % Dim: 1 x 65536
C_5d(:,2) = ((sum((CN_y.*(exp(-1*(Wx+Wy+Wr+Wg+Wb))))'))./Wt)';
C_5d(:,3) = ((sum((CN_r.*(exp(-1*(Wx+Wy+Wr+Wg+Wb))))'))./Wt)';
C_5d(:,4) = ((sum((CN_g.*(exp(-1*(Wx+Wy+Wr+Wg+Wb))))'))./Wt)';
C_5d(:,5) = ((sum((CN_b.*(exp(-1*(Wx+Wy+Wr+Wg+Wb))))'))./Wt)';


i = i+1;
end

C(:,:,1) = reshape(C_5d(:,3), [256, 256]);
C(:,:,2) = reshape(C_5d(:,4), [256, 256]);
C(:,:,3) = reshape(C_5d(:,5), [256, 256]);

C = uint8(C);

end











