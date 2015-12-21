function dataset = custom_test(dataset, usage,snippet, use_flip)
% Pascal voc 2012 test set
% set opts.imdb_train opts.roidb_train 
% or set opts.imdb_test opts.roidb_train

% change to point to your devkit install
devkit                      = custom_devkit();

switch usage
    case {'train'}
        dataset.imdb_train    = {  imdb_from_ilsvrc(devkit, snippet, use_flip) };
        %dataset.roidb_train   = cellfun(@(x) x.roidb_func(x), dataset.imdb_train, 'UniformOutput', false);
    case {'test'}
        dataset.imdb_test     = imdb_from_ilsvrc(devkit,snippet, use_flip) ;
        dataset.roidb_test    = dataset.imdb_test.roidb_func(dataset.imdb_test);
    otherwise
        error('usage = ''train'' or ''test''');
end

end
