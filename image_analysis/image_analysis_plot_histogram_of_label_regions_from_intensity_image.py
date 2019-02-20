#!/cbica/software/external/python/anaconda/3/bin/python
import argparse
import numpy as np
import matplotlib.pyplot as plt
import nibabel as nib
from palettable.colorbrewer.qualitative import Set1_4

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
parser.add_argument( '-o', '--output_figure',
type = str,
dest = "output",
required = True,
help = 'full path to the png image file of the histogram plot' )

args = parser.parse_args()

image=args.image
label=args.label
output=args.output

image_load=nib.load(image)
label_load=nib.load(label)

image_img = image_load.get_data()
label_img = label_load.get_data()

# sanity check: do image and label match each other's size?
if (image_img.shape != label_img.shape):
  print("image shape:", image_img.shape)
  print("label shape:", label_img.shape)
  exit

# create figure
fig = plt.figure(1)
ax1 = fig.add_subplot(1,1,1)

#loop and plot to fig
for label_value in np.arange(4):
  print("label_value: ",label_value)
  label_region = image_img[ label_img == label_value ]
  ax1.hist(label_region, color = Set1_4.mpl_colors[label_value], label = ["Label Value ",label_value] )

plt.show()
ax1.savefig( figname = output, dpi=fig.dpi )