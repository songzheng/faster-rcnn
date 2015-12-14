function make_vid(snippet,annopath)
repo = fullfile(fileparts(pwd),'datasets',snippet);
%repo = strcat(repo,snippet);
classes={...
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
imageNames = dir(repo );
imageNames = {imageNames.name}';
outname=strcat(snippet,'_annotated.avi');
outputVideo = VideoWriter(char(fullfile(fileparts(pwd),outname)));
open(outputVideo);
for ii = 3:length(imageNames)
    img = imread(fullfile(repo,imageNames{ii}));
    for jj=1:20
    load(strcat(annopath,'/ilsvrc',int2str(jj),'_boxes'));
    positions = filter_boxes(boxes{ii-2});
    for lp=1:size(positions,1)
        position = positions(lp,1:4);
        position(3:4)=position(3:4)-position(1:2);
        img = insertObjectAnnotation(img, 'rectangle', position,classes{jj});
    end
    end
    writeVideo(outputVideo,img)
end
close(outputVideo)
end
