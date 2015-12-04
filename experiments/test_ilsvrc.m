function test_ilsvrc()
% script_faster_rcnn_ILSVRC()
% Faster rcnn training and testing with VGG16 model
% --------------------------------------------------------
% Faster R-CNN
% Copyright (c) 2015, Shaoqing Ren
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------

clc;
clear mex;
clear is_valid_handle; % to clear init_key
base_dir = fileparts(fileparts(mfilename('fullpath')));
run(fullfile(base_dir, 'startup'));
%% -------------------- CONFIG0--------------------
opts.caffe_version          = 'caffe_faster_rcnn';
%opts.gpu_id                 = auto_select_gpu;
opts.gpu_id                 = 2;
active_caffe_mex(opts.gpu_id, opts.caffe_version);

% do validation, or not 
opts.do_val                 = false; 
% model
model                       = Model.VGG16_for_Faster_RCNN_VOC2012;
% cache base
cache_base_proposal         = 'faster_rcnn_VOC2012_vgg_16layers';
cache_base_fast_rcnn        = '';
% train/test data
dataset                     = [];
use_flipped                 = true;
snippet			   = 'ILSVRC2015_train_00030000';
dataset                     = Dataset.voc2012_trainval(dataset, 'train', use_flipped);
dataset                     = Dataset.ilsvrc_test(dataset, 'test',snippet,false);

%% -------------------- TRAIN --------------------
% conf
conf_proposal               = proposal_config('image_means', model.mean_image, 'feat_stride', model.feat_stride);
conf_fast_rcnn              = fast_rcnn_config('image_means', model.mean_image);
% set cache folder for each stage
model                       = Faster_RCNN_Train.set_cache_folder(cache_base_proposal, cache_base_fast_rcnn, model);
% generate anchors and pre-calculate output size of rpn network 
[conf_proposal.anchors, conf_proposal.output_width_map, conf_proposal.output_height_map] ...
                            = proposal_prepare_anchors(conf_proposal, model.stage1_rpn.cache_name, model.stage1_rpn.test_net_def_file);


%% final test
fprintf('\n***************\nfinal test\n***************\n');
imdbs_name = cell2mat(cellfun(@(x) x.name, dataset.imdb_train, 'UniformOutput', false));
model.stage2_rpn.output_model_file = fullfile(base_dir,'output','rpn_cachedir',model.stage2_rpn.cache_name,imdbs_name,'final');
model.stage2_rpn.nms        = model.final_test.nms;
size(dataset.roidb_test.rois)
dataset.roidb_test       	= Faster_RCNN_Train.generate_proposal(conf_proposal, model.stage2_rpn, dataset.imdb_test, dataset.roidb_test);

model.stage2_fast_rcnn.output_model_file = fullfile(base_dir,'output','fast_rcnn_cachedir',model.stage2_fast_rcnn.cache_name,imdbs_name,'final');
size(dataset.roidb_test.rois)
display('proposal_test_complete');

Faster_RCNN_Train.do_fast_rcnn_test_ilsvrc(conf_fast_rcnn, model.stage2_fast_rcnn, dataset.imdb_test, dataset.roidb_test,false);

% save final models, for outside tester
%Faster_RCNN_Train.gather_rpn_fast_rcnn_models(conf_proposal, conf_fast_rcnn, model, dataset);
end

function [anchors, output_width_map, output_height_map] = proposal_prepare_anchors(conf, cache_name, test_net_def_file)
    [output_width_map, output_height_map] ...                           
                                = proposal_calc_output_size(conf, test_net_def_file);
    anchors                = proposal_generate_anchors(cache_name, ...
                                    'scales',  2.^[3:5]);
end
