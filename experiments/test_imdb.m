function test_imdb()
% script_faster_rcnn_VOC2012_VGG16()
% Faster rcnn training and testing with VGG16 model
% --------------------------------------------------------
% Faster R-CNN
% Copyright (c) 2015, Shaoqing Ren
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------

clc;
clear mex;
clear is_valid_handle; % to clear init_key
run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'startup'));
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
dataset                     = Dataset.voc2012_trainval(dataset, 'train', use_flipped);
dataset                     = Dataset.voc2012_test(dataset, 'test', false);


%% final test
fprintf('\n***************\nfinal test\n***************\n');
     
model.stage2_rpn.nms        = model.final_test.nms;
dataset.roidb_test       	= Faster_RCNN_Train.do_proposal_test(conf_proposal, model.stage2_rpn, dataset.imdb_test, dataset.roidb_test);
opts.final_mAP              = Faster_RCNN_Train.do_fast_rcnn_test(conf_fast_rcnn, model.stage2_fast_rcnn, dataset.imdb_test, dataset.roidb_test);

% save final models, for outside tester
Faster_RCNN_Train.gather_rpn_fast_rcnn_models(conf_proposal, conf_fast_rcnn, model, dataset);
end

function [anchors, output_width_map, output_height_map] = proposal_prepare_anchors(conf, cache_name, test_net_def_file)
    [output_width_map, output_height_map] ...                           
                                = proposal_calc_output_size(conf, test_net_def_file);
    anchors                = proposal_generate_anchors(cache_name, ...
                                    'scales',  2.^[3:5]);
end
