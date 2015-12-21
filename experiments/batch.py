#from __future__ import unicode_literals
import youtube_dl
import os
from os import listdir
from os.path import isfile
import scipy.io as sio


video_dir = '/home/satyam/faster_rcnn/batch_data/videos'

video_frames_dir = '/home/satyam/faster_rcnn/batch_data/frames'
video_frames_dir = '/home/satyam/faster_rcnn/datasets'
detection_result_dir = '/home/satyam/faster_rcnn/batch_data/detection'
project_dir = '/home/satyam/faster_rcnn/experiments'


def download(video_url):
    os.chdir(video_dir) 
    #ydl_opts = {'outtmpl': '%(id)s.%(ext)s'}
    #ydl_opts = {'outtmpl': '%(id)s'}
    #ydl = youtube_dl.YoutubeDL(ydl_opts)
    #ydl.download([video_url])

    cmd = "youtube-dl {} -o '%(id)s'".format(video_url)
    os.system(cmd)

    video_filename = None

    video_id = video_url[video_url.rfind('=') + 1 : ]
    for filename in listdir(video_dir):
        if isfile(os.path.join(video_dir, filename)):
            filenm, fileext = filename.split('.')
            if filenm == video_id:
                video_filename = filename

    return video_filename


def extract_frames(video_filename):
    video_path = os.path.join(video_dir, video_filename)
    
    video_frame_dir = os.path.join(video_frames_dir, video_filename)
    if not os.path.exists(video_frame_dir):
        os.makedirs(video_frame_dir)
    
        os.chdir(video_frame_dir)

        cmd = 'ffmpeg -i {} -vf fps=1/5 img%03d.jpg'.format(video_path)
        os.system(cmd)

    return video_filename


def detect(video_filename):
    os.chdir(project_dir)

    detection_result_directory = os.path.join(detection_result_dir,
            video_filename)
    matlab_function = "test_custom('{}', '{}')".format(video_filename,
            detection_result_directory
            )
    cmd = 'matlab -r "{}"; exit;'.format(matlab_function)
    
    print cmd

    os.system(cmd)


def load_tags(video_filename):
    result_dir = '/home/satyam/faster_rcnn/experiments/output/fast_rcnn_cachedir/faster_rcnn_VOC2012_vgg_16layers_top-1_nms0_7_top2000_stage2_fast_rcnn/ilsvrc_{}'.format(video_filename)
    classes = ['aeroplane','bicycle','bird','boat','bottle','bus','car','cat','chair','cow','diningtable','dog','horse','motorbike','person','pottedplant','sheep','sofa','train','tvmonitor']

    objs = []
    for filename in listdir(result_dir):
        if filename.endswith('.mat'):
            class_name = filename.split('_')[0]
            class_name_ind = int(''.join(ele for ele in class_name if
                ele.isdigit())) - 1
            class_name = classes[class_name_ind]

            content = sio.loadmat(os.path.join(result_dir, filename))
            
            classframes_list = []

            frame_count = content['boxes'].shape[0]
            for i in xrange(frame_count):
                for obj in content['boxes'][i][0].tolist():
                    position = obj[:4]
                    score = obj[-1]
                    if score > 0.8:
                        classframes_list.append(i)
            print '{}: {}'.format(class_name, len(classframes_list))

if __name__ == '__main__':
    #for video_url in ['https://www.youtube.com/watch?v=ts8PqTPE88k', 'https://www.youtube.com/watch?v=ZgRdRHmYuN8',
    #        'https://www.youtube.com/watch?v=q2lE84ncQ4Q']:
    #    detect(extract_frames(download(video_url)))

    load_tags('ZgRdRHmYuN8.mp4')
