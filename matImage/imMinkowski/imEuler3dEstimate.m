function [chi, labels] = imEuler3dEstimate(img, varargin)
%Estimate Euler number in a 3D image
%
%   CHIest = imEuler3dEstimate(IMG)
%   CHIest = imEuler3dEstimate(IMG, CONN)
%   Estimate Euler number in a 3D image, without taking into account the
%   contribution of the voxels located on image border. The result of this
%   function is usually divided by the volume the sampling window to obtain
%   an estimate of Euler number density.
%
%   Example
%   imEuler3dEstimate
%
%   See also
%     imEuler3dDensity, imEuler3d

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2010-07-26,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


%% Process input arguments 

% check image dimension
if ndims(img) ~= 3
    error('first argument should be a 3D image');
end

% in case of a label image, return a vector with a set of results
if ~islogical(img)
    labels = unique(img);
    labels(labels==0) = [];
    chi = zeros(length(labels), 1);
    for i = 1:length(labels)
        chi(i) = imEuler3dEstimate(img==labels(i), varargin{:});
    end
    return;
end

% extract connectivity
conn = 6;
if ~isempty(varargin)
    conn = varargin{1};
end

% determines connectivity to use on faces
conn2d = 4;
if conn == 26
    conn2d = 8;
end

% in case of binary image, compute only one label...
labels = 1;


%% Main processing

% Euler-Poincare Characteristic of the binary structure in image
chi     = imEuler3d(img, varargin{:});

% compute EPC on each of the 12 border edge of image, and keep the average
chix    = mean([ ...
    imEuler1d(img(:,   1,   1)) ...
    imEuler1d(img(:, end,   1)) ...
    imEuler1d(img(:,   1, end)) ...
    imEuler1d(img(:, end, end)) ...
    ]);
chiy    = mean([ ...
    imEuler1d(img(  1, :,   1)) ...
    imEuler1d(img(end, :,   1)) ...
    imEuler1d(img(  1, :, end)) ...
    imEuler1d(img(end, :, end)) ...
    ]);
chiz    = mean([ ...
    imEuler1d(img(  1,   1, :)) ...
    imEuler1d(img(end,   1, :)) ...
    imEuler1d(img(  1, end, :)) ...
    imEuler1d(img(end, end, :)) ...
    ]);

% compute EPC on each of the 6 border faces, and keep the average
chixy    = mean([ ...
    imEuler2d(squeeze(img(:, :,   1)), conn2d) ...
    imEuler2d(squeeze(img(:, :, end)), conn2d) ...
    ]);
chixz    = mean([ ...
    imEuler2d(squeeze(img(:,  1,  :)), conn2d) ...
    imEuler2d(squeeze(img(:, end, :)), conn2d) ...
    ]);
chiyz    = mean([ ...
    imEuler2d(squeeze(img(  1, :, :)), conn2d) ...
    imEuler2d(squeeze(img(end, :, :)), conn2d) ...
    ]);

% compute EPC on each of the 8 corners of image, and keep the average
chixyz   = mean([ ...
    img(  1,   1,   1), ...
    img(end,   1,   1), ...
    img(  1, end,   1), ...
    img(end, end,   1), ...
    img(  1,   1, end), ...
    img(end,   1, end), ...
    img(  1, end, end), ...
    img(end, end, end), ...
    ]);


% estimate EPC in image using mean edge correction
chi = chi - (chix + chiy + chiz) + (chixy + chixz + chiyz) - chixyz;
