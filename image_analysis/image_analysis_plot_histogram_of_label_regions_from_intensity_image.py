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
required = False,
help = 'output figure title string. Defaults to -- Title -- if not provided.' )
parser.add_argument( '-l', '--label_map',
type = str,
dest = "label",
required = False,
help = 'full path to the label map image. Full image used if not provided.' )
parser.add_argument( '-m', '--mask_brain',
type = str,
dest = "mask",
required = False,
help = 'full path to the binary brain mask image. Full image used if not provided.' )
parser.add_argument( '-o', '--output_figure',
type = str,
dest = "output",
required = True,
help = 'full path to the png image file of the histogram plot' )
parser.add_argument( '-x', '--xmax_value',
type = int,
dest = "xmax",
required = False,
help = 'xmax value on the x scale. Max of the image used if not provided.' )
parser.add_argument( '-s', '--show_image',
type = bool,
dest = "show_image",
required = False,
help = 'If True, show the image on pop up screen before saving the figure. Default is false.' )
parser.add_argument( '-v', '--verbose',
type = bool,
dest = "verbose",
required = False,
help = 'If True, Show more verbose statements echoed on screen as progress is made.' )
parser.add_argument( '-n', '--numbin',
type = int,
dest = "numbin",
required = False,
help = 'Number of bins for histogram plotting.' )

def plot_histogram( image_path, output_path, mask_path = None, label_path = None, title_string = "Title", xmax_value = None, show_image = False, verbose = False, numbin = 200 ):
  "take in image and corresponding label, plot intensity distribution per label to output_figure path"
  image_load = nib.load(image_path)
  image_img = image_load.get_data()

  if label_path != None:
    label_load = nib.load(label_path)
    label_img = label_load.get_data()

  if mask_path != None:
    mask_load = nib.load(mask_path)
    mask_img = mask_load.get_data()

  if verbose == True:
    if mask_path != None:
      print("Checking if image dimensions of the input image ({:s}) and mask ({:s}) match.".format(image_path, mask_path) )
    if label_path != None:
      print("Checking if image dimensions of the input image ({:s}) and label ({:s}) match.".format(image_path, label_path) )

  # sanity check: do image and label match each other's size?
  if label_path != None:
    if (image_img.shape != label_img.shape):
      print("image shape:", image_img.shape)
      print("label shape:", label_img.shape)
      exit

  # sanity check: do mask and label match each other's size?
  if mask_path != None:
    if (image_img.shape != mask_img.shape):
      print("image shape:", image_img.shape)
      print("mask shape:", mask_img.shape)
      exit

  # create figure
  fig = plt.figure(num = 1, figsize = (16,12) )
  ax1 = fig.add_subplot(1, 1, 1)

  #get max of image
  if xmax_value == None:
    max_value = np.max(image_img)
  else:
    max_value = xmax_value

  #mask data
  if mask_path == None:
    mask_img = image_img
    mask_img[ image_img < 0 ] = 1
    mask_img[ image_img >= 0 ] = 1
    
  mask_region = image_img[ mask_img == 1 ]

  hist_mask = ax1.hist(mask_region, color = Set1_6.mpl_colors[0], label = "Brain Mask", density = True, histtype = 'step', range = (0, max_value), bins = numbin )

  #loop and plot to fig
  if label_path != None:
    for label_value in np.arange(start=1,stop=5,step=1):
      if label_value == 3:
        continue
      print("label_value: ",label_value)
      label_region = image_img[ label_img == label_value ]
      hist_label = ax1.hist(label_region, color = Set1_6.mpl_colors[label_value], label = label_value, density = True, histtype = 'step', range = (0, max_value), bins = numbin )

  ax1.legend()
  ax1.set_title(title_string)
  ax1.set_xlim(0, max_value)

  if show_image == True:
    plt.show()

  plt.savefig( fname = output, dpi=fig.dpi )

args = parser.parse_args()

image=args.image
mask=None
mask=args.mask
label=None
label=args.label
output=args.output
title=None
title=args.title
xmax=None
xmax=args.xmax
show_image=False
show_image=args.show_image
verbose=False
verbose=args.verbose
numbin=False
numbin=args.numbin

plot_histogram( image_path = image, output_path = output, mask_path = mask, label_path = label,  title_string = title, xmax_value = xmax, show_image = show_image, verbose = verbose, numbin = numbin )