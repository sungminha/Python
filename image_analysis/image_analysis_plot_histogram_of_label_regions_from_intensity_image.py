#!/cbica/software/external/python/anaconda/3/bin/python
import argparse
import numpy as np
import matplotlib.pyplot as plt
import nibabel as nib
from palettable.colorbrewer.qualitative import Set1_5

# user input paths to the input intensity image and label map
parser = argparse.ArgumentParser( description = 'Takes in intensity image and label map, calculate histogram and plot the histogram of the intensity distribution of the different labels.' )
parser.add_argument( '-i', '--intensity_image',
type = str,
dest = "image",
required = True,
help = 'full path to the intensity image' )
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

def plot_histogram( image_path, mask_path, label_path, output_path ):
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

  #mask data
  mask_region = image_img[ mask_img == 1 ]
  hist_mask = ax1.hist(mask_region, color = Set1_5.mpl_colors[0], label = "Brain Mask", density = True, histtype = 'step' )

  #loop and plot to fig
  for label_value in np.arange(start=1,stop=4,step=1):
    print("label_value: ",label_value)
    label_region = image_img[ label_img == label_value ]
    hist_label = ax1.hist(label_region, color = Set1_5.mpl_colors[label_value], label = label_value, density = True, histtype = 'step' )

  ax1.legend()

  plt.show()
  plt.savefig( figname = output, dpi=fig.dpi )
  return hist

args = parser.parse_args()

image=args.image
mask=args.mask
label=args.label
output=args.output

plot_histogram( image_path = image, mask_path = mask, label_path = label, output_path = output )