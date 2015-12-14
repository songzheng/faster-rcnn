function y=make_im(vidfile)
[t1 t2 t3]=fileparts(vidfile);
workingDir=strcat(t2,'_images');
mkdir(workingDir)

customVideo = VideoReader(vidfile);
ii = 1;

while hasFrame(customVideo)
   img = readFrame(customVideo);
   filename = [sprintf('%08d',ii) '.jpg'];
   fullname = fullfile(workingDir,filename);
   imwrite(img,fullname)
   ii = ii+1;
end