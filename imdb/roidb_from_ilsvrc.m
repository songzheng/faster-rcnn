function roidb = roidb_from_ilsvrc(imdb, varargin)
% roidb = roidb_from_voc(imdb, rootDir)
%   Builds an regions of interest database from imdb image
%   database. Uses precomputed selective search boxes available
%   in the R-CNN data package.
%
%   Inspired by Andrea Vedaldi's MKL imdb and roidb code.

% AUTORIGHTS
% ---------------------------------------------------------
% Copyright (c) 2014, Ross Girshick
% 
% This file is part of the R-CNN code and is available 
% under the terms of the Simplified BSD License provided in 
% LICENSE. Please retain this notice and LICENSE if you use 
% this file (or any portion of it) in your project.
% ---------------------------------------------------------

ip = inputParser;
ip.addRequired('imdb', @isstruct);
ip.addParamValue('rootDir',                         '.',    @ischar);
ip.parse(imdb, varargin{:});
opts = ip.Results;

opts.rootDir=fileparts(pwd);
roidb.name = imdb.name;

cache_file_ss = [];
cache_file_eb = [];
cache_file_sp = [];

opts.extension = '.mat';
cache_file = fullfile(opts.rootDir, ['/imdb/cache/roidb_' cache_file_ss cache_file_eb cache_file_sp imdb.name opts.extension]);
cache_file = [cache_file, '.mat'];
try
  load(cache_file);
catch
  %VOCopts = imdb.details.VOCopts;

  roidb.name = imdb.name;

  fprintf('Loading region proposals...');
  regions = [];
  fprintf('done\n');

if isempty(regions)
      fprintf('Warrning: no windows proposal is loaded !\n');
      regions.boxes = cell(length(imdb.image_ids), 1);
      if imdb.flip
            regions.images = imdb.image_ids(1:2:end);
      else
            regions.images = imdb.image_ids;
      end
  end

      for i = 1:length(imdb.image_ids)
        tic_toc_print('roidb (%s): %d/%d\n', roidb.name, i, length(imdb.image_ids));
          voc_rec = [];
        roidb.rois(i) = attach_proposals(voc_rec, regions.boxes{i}, imdb.class_to_id);
      end
size(roidb.rois)
  fprintf('Saving roidb to cache...');
  save(cache_file, 'roidb', '-v7.3');
  fprintf('done\n');
end


% ------------------------------------------------------------------------
function rec = attach_proposals(voc_rec, boxes, class_to_id)
% ------------------------------------------------------------------------

% change selective search order from [y1 x1 y2 x2] to [x1 y1 x2 y2]
if ~isempty(boxes)
    boxes = boxes(:, [2 1 4 3]);
end

%           gt: [2108x1 double]
%      overlap: [2108x20 single]
%      dataset: 'voc_2007_trainval'
%        boxes: [2108x4 single]
%         feat: [2108x9216 single]
%        class: [2108x1 uint8]
if isfield(voc_rec, 'objects')
      valid_objects = 1:length(voc_rec.objects(:));
  gt_boxes = cat(1, voc_rec.objects(valid_objects).bbox);
  all_boxes = cat(1, gt_boxes, boxes);
  gt_classes = class_to_id.values({voc_rec.objects(valid_objects).class});
  gt_classes = cat(1, gt_classes{:});
  num_gt_boxes = size(gt_boxes, 1);
else
  gt_boxes = [];
  all_boxes = boxes;
  gt_classes = [];
  num_gt_boxes = 0;
end
num_boxes = size(boxes, 1);

rec.gt = cat(1, true(num_gt_boxes, 1), false(num_boxes, 1));
rec.overlap = zeros(num_gt_boxes+num_boxes, class_to_id.Count, 'single');
for i = 1:num_gt_boxes
  rec.overlap(:, gt_classes(i)) = ...
      max(rec.overlap(:, gt_classes(i)), boxoverlap(all_boxes, gt_boxes(i, :)));
end
rec.boxes = single(all_boxes);
rec.feat = [];
rec.class = uint8(cat(1, gt_classes, zeros(num_boxes, 1)));

% ------------------------------------------------------------------------
function regions = load_proposals(proposal_file, regions)
% ------------------------------------------------------------------------
if isempty(regions)
    regions = load(proposal_file);
else
    regions_more = load(proposal_file);
    if ~all(cellfun(@(x, y) strcmp(x, y), regions.images(:), regions_more.images(:), 'UniformOutput', true))
        error('roidb_from_ilsvrc: %s is has different images list with other proposals.\n', proposal_file);
    end
    regions.boxes = cellfun(@(x, y) [double(x); double(y)], regions.boxes(:), regions_more.boxes(:), 'UniformOutput', false);
end
