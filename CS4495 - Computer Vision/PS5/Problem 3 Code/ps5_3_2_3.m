%f = {imread('shift0.png'), imread('shiftR2.png')};
%f = {imread('yos_img_01.jpg'), imread('yos_img_02.jpg'), imread('yos_img_03.jpg')};
f = {rgb2gray(imread('0.png')), rgb2gray(imread('1.png')), rgb2gray(imread('2.png'))};
ws = 30;
wsig = 13;
bs = 30;
bsig = 13;
frameTransitions = length(f) - 1;
lHeight = 3;
gHeight = lHeight + 1;
selectedHeight = 2;
errorPerPixel = zeros(1, gHeight);
[lPyr, gPyr] = LaplacianSequence(f, lHeight);
U = cell(frameTransitions, gHeight);
V = cell(frameTransitions, gHeight);
warped = cell(frameTransitions, gHeight);
diff = cell(frameTransitions, gHeight);
for i = 1 : frameTransitions
    for j = 1 : gHeight
        [sr, sc] = size(gPyr{i, j})
        [u, v] = OpticFlow(gPyr{i, j}, gPyr{i + 1, j}, bs, bsig, ws, bsig);
        U{i, j} = u;
        V{i, j} = v;
        warped{i, j} = Warp(gPyr{i + 1, j}, u, v);
        diff{i, j} = warped{i, j} - gPyr{i + 1, j};
        errorPerPixel(j) = errorPerPixel(j) + (sum(sum(abs(diff{i, j})))) / (sr * sc);
    end
end
[~, selectedIndex] = find(errorPerPixel == min(min(errorPerPixel)));
frameTime = 1/60;
[sr, sc] = size(warped{1, selectedHeight});
for i = 1 : frameTransitions
    figure, DrawOpticFlow(U{i, selectedHeight}, V{i, selectedHeight});
    figure, imshow(diff{i, selectedHeight});
    sum(sum(diff{i, selectedHeight})) / (sr * sc)
    framesij = zeros(sr, sc, 2);
    framesij(:, :, i) = gPyr{i + 1, selectedHeight};
    framesij(:, :, i + 1) = warped{i, selectedHeight};
    implay(framesij, 60);
end