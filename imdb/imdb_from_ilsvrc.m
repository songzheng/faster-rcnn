function imdb = imdb_from_ilsvrc(root_dir,snippet, flip)
% imdb = imdb_from_voc(root_dir, image_set, year)
%   Builds an image database for the PASCAL VOC devkit located
%   at root_dir using the image_set and year.
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

%imdb.name = 'voc_train_2007'
%imdb.image_dir = '/work4/rbg/VOC2007/VOCdevkit/VOC2007/JPEGImages/'
%imdb.extension = '.jpg'
%imdb.image_ids = {'000001', ... }
%imdb.sizes = [numimages x 2]
%imdb.classes = {'aeroplane', ... }
%imdb.num_classes
%imdb.class_to_id
%imdb.class_ids
%imdb.eval_func = pointer to the function that evaluates detections
%imdb.roidb_func = pointer to the function that returns regions of interest

if nargin < 4
    flip = false;
end

cache_file = [fullfile(fileparts(pwd),'imdb','cache','imdb_ilsvrc_') snippet];
if flip
    cache_file = [cache_file, '_flip'];
end
try
  load(cache_file);
   display('loading testdb from cache');
catch
%  VOCopts = get_ilsvrc_opts();
 VOCopts.classes={...
    'aeroplane'
    'bicycle'
    'bird'
    'boat'
    'bottle'
    'bus'
    'car'
    'cat'
    'chair'
    'cow'
    'diningtable'
    'dog'
    'horse'
    'motorbike'
    'person'
    'pottedplant'
    'sheep'
    'sofa'
    'train'
    'tvmonitor'};

VOCopts.nclasses=length(VOCopts.classes);

% poses

VOCopts.poses={...
    'Unspecified'
    'Left'
    'Right'
    'Frontal'
    'Rear'};
 
  VOCopts.imgpath = fullfile(root_dir,snippet)
display(VOCopts.imgpath);
  imdb.name = ['ilsvrc_' snippet];
  imdb.image_dir = VOCopts.imgpath;

%	sprintf(VOCopts.imgsetpath, image_set)
%  imdb.image_ids = textread(sprintf(VOCopts.imgsetpath, image_set), '%s');
display('herhe');
  imdb.image_ids =  dir(imdb.image_dir);
  imdb.image_ids =  imdb.image_ids(3:end);
  imdb.extension = 'JPEG';
  imdb.flip = flip;
  imdb.classes = VOCopts.classes;
  imdb.num_classes = length(imdb.classes);
  imdb.class_to_id =  containers.Map(imdb.classes, 1:imdb.num_classes);
  imdb.class_ids = 1:imdb.num_classes;

  % private VOC details
  %imdb.details.VOCopts = VOCopts;

  % VOC specific functions for evaluation and region of interest DB
%  imdb.eval_func = @imdb_eval_voc;
  imdb.roidb_func = @roidb_from_ilsvrc;
  imdb.image_at = @(i) ...
      sprintf('%s/%s', imdb.image_dir, imdb.image_ids(i).name);
display('num_files');
size(imdb.image_ids);
  for i = 1:length(imdb.image_ids)
    tic_toc_print('imdb (%s): %d/%d\n', imdb.name, i, length(imdb.image_ids));
    info = imfinfo(fullfile(VOCopts.imgpath, imdb.image_ids(i).name));
    imdb.sizes(i, :) = [info.Height info.Width];
  end

  fprintf('Saving imdb to cache...');
  save(cache_file, 'imdb', '-v7.3');
  fprintf('done\n');
end
