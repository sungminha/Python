#!/cbica/software/external/python/anaconda/3/bin/python
import argparse
import numpy as np
import matplotlib.pyplot as plt
import nibabel as nib
from palettable.colorbrewer.qualitative import Set1_6

# user input paths to the input intensity image and label map
parser = argparse.ArgumentParser( description = 'Takes in intensity image and label map, calculate histogram and plot the histogram of the intensity distribution of the different labels.' )
parser.add_argument( '-i', '--intensity_image',
type = str,
dest = "image",
required = True,
help = 'full path to the intensity image' )
parser.add_argument( '-t', '--title',
type = str,
dest = "title",
required = True,
help = 'output figure title string' )
parser.add_argument( '-l', '--label_map',
type = str,
dest = "label",
required = True,
help = 'full path to the label map image' )
parser.add_argument( '-m', '--mask_brain',
type = str,
dest = "mask",
required = True,
help = 'full path to the binary brain mask image' )
parser.add_argument( '-o', '--output_figure',
type = str,
dest = "output",
required = True,
help = 'full path to the png image file of the histogram plot' )

def plot_histogram( image_path, mask_path, label_path, output_path, title_string = "Title" ):
  "take in image and corresponding label, plot intensity distribution per label to output_figure path"
  image_load = nib.load(image_path)
  label_load = nib.load(label_path)
  mask_load = nib.load(mask_path)

  image_img = image_load.get_data()
  label_img = label_load.get_data()
  mask_img = mask_load.get_data()

  # sanity check: do image and label match each other's size?
  if (image_img.shape != label_img.shape):
    print("image shape:", image_img.shape)
    print("label shape:", label_img.shape)
    print("mask shape:", mask_img.shape)
    exit

  # create figure
  fig = plt.figure(1)
  ax1 = fig.add_subplot(1,1,1)

  #get max of image
  max_value = np.max(image_img)

  #mask data
  mask_region = image_img[ mask_img == 1 ]
  hist_mask = ax1.hist(mask_region, color = Set1_6.mpl_colors[0], label = "Brain Mask", density = True, histtype = 'step', range = (0, max_value), bins = 200 )

  #loop and plot to fig
  for label_value in np.arange(start=1,stop=5,step=1):
    if label_value == 3:
      continue
    print("label_value: ",label_value)
    label_region = image_img[ label_img == label_value ]
    hist_label = ax1.hist(label_region, color = Set1_6.mpl_colors[label_value], label = label_value, density = True, histtype = 'step', range = (0, max_value) )

  ax1.legend()
  ax1.set_title(title_string)

  # plt.show()
  plt.savefig( fname = output, dpi=fig.dpi )
  # return hist

args = parser.parse_args()

image=args.image
mask=args.mask
label=args.label
output=args.output
title=args.title

plot_histogram( image_path = image, mask_path = mask, label_path = label, output_path = output, title_string = title )