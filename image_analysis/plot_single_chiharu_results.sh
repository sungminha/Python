#!/usr/bin/env bash

cd "/cbica/home/sakoc/comp_space/Protocols/20190220_n3n4/output";

dir="/cbica/home/sakoc/comp_space/Protocols/20190220_n3n4/output";

t="ABLK_2016.05.14";
s=`echo ${t} | cut -d_ -f1`;

flair="${dir}/${t}_flair_LPS_r_SSFinal.nii.gz";
flair_n3="${dir}/${t}_flair_LPS_r_SSFinal_n3.nii.gz";
flair_n4="${dir}/${t}_flair_LPS_r_SSFinal_n4.nii.gz";
manseg="${dir}/${t}_LPS_r_manualSegm.nii.gz";
brainmask="/cbica/projects/brain_tumor/Brain_Tumor_2018/Protocols/3_Muse/ABLK/${t}/${t}_t1_LPS_N4_r_muse.nii.gz";

script="/cbica/home/hasun/git_sungminha/Python/image_analysis/image_analysis_plot_histogram_of_label_regions_from_intensity_image.py";

# module unload python;
# module load python/anaconda/3;

# source activate py3_7_conda_forge;

outdir="/cbica/home/hasun/comp_space/190216_BiasCorrection_MaskTest/Histograms";
mkdir -pv "${outdir}";

python ${script} -i ${flair} -m ${brainmask} -l ${manseg} -o "${outdir}/${t}_flair.png";
python ${script} -i ${flair_n3} -m ${brainmask} -l ${manseg} -o "${outdir}/${t}_flair_n3.png";
python ${script} -i ${flair_n4} -m ${brainmask} -l ${manseg} -o "${outdir}/${t}_flair_n4.png";

