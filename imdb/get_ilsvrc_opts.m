function VOCopts = get_ilsvrc_opts()

tmp = pwd;
try
 VOCopts = ILSVRCinit();
catch
  cd(tmp);
  error(sprintf('VOCcode directory not found under %s', path));
end
cd(tmp);
