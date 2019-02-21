#!/usr/bin/env bash

cd "/cbica/home/sakoc/comp_space/Protocols/20190220_n3n4/output";

dir="/cbica/home/sakoc/comp_space/Protocols/20190220_n3n4/output";

script="/cbica/home/hasun/git_sungminha/Python/image_analysis/image_analysis_plot_histogram_of_label_regions_from_intensity_image.py";

outdir="/cbica/home/hasun/comp_space/190216_BiasCorrection_MaskTest/Histograms";
mkdir -pv "${outdir}";

declare -a arr=("AAPL_2014.09.14" "AAPS_2014.11.18" "AAYA_2015.01.21" "ABFB_2015.11.05" "ABFP_2015.06.05" "ABGB_2015.01.09" "ABGF_2015.03.16" "ABGM_2015.02.20" "ABGS_2015.07.22" "ABHB_2014.12.14" "ABHF_2015.09.04" "ABHI_2015.04.10" "ABHK_2015.06.01" "ABHM_2015.08.26" "ABHN_2015.10.07" "ABKX_2016.02.13" "ABKY_2016.02.14" "ABLE_2016.03.08" "ABLI_2016.04.19" "ABLK_2016.05.14" )

# AAPL_2014.09.14
# AAPS_2014.11.18
# AAYA_2015.01.21
# ABFB_2015.11.05
# ABFP_2015.06.05
# ABGB_2015.01.09
# ABGF_2015.03.16
# ABGM_2015.02.20
# ABGS_2015.07.22
# ABHB_2014.12.14
# ABHF_2015.09.04
# ABHI_2015.04.10
# ABHK_2015.06.01
# ABHM_2015.08.26
# ABHN_2015.10.07
# ABKX_2016.02.13
# ABKY_2016.02.14
# ABLE_2016.03.08
# ABLI_2016.04.19
# ABLK_2016.05.14


for t in "${arr[@]}"
do
  s=`echo ${t} | cut -d_ -f1`;
  modality="flair";

  flair="${dir}/${t}_${modality}_LPS_r_SSFinal.nii.gz";
  flair_n3="${dir}/${t}_${modality}_LPS_r_SSFinal_n3.nii.gz";
  flair_n4="${dir}/${t}_${modality}_LPS_r_SSFinal_n4.nii.gz";
  manseg="${dir}/${t}_LPS_r_manualSegm.nii.gz";
  brainmask="/cbica/projects/brain_tumor/Brain_Tumor_2018/Protocols/3_Muse/${s}/${t}/${t}_t1_LPS_N4_r_muse.nii.gz";

  python ${script} -i ${flair} -m ${brainmask} -l ${manseg} -o "${outdir}/${t}_${modality}.png" -t "${t}_${modality}";
  python ${script} -i ${flair_n3} -m ${brainmask} -l ${manseg} -o "${outdir}/${t}_${modality}_n3.png" -t "${t}_${modality}_N3";
  python ${script} -i ${flair_n4} -m ${brainmask} -l ${manseg} -o "${outdir}/${t}_${modality}_n4.png" -t "${t}_${modality}_N4";

  modality="t1ce";

  flair="${dir}/${t}_${modality}_LPS_r_SSFinal.nii.gz";
  flair_n3="${dir}/${t}_${modality}_LPS_r_SSFinal_n3.nii.gz";
  flair_n4="${dir}/${t}_${modality}_LPS_r_SSFinal_n4.nii.gz";
  manseg="${dir}/${t}_LPS_r_manualSegm.nii.gz";
  brainmask="/cbica/projects/brain_tumor/Brain_Tumor_2018/Protocols/3_Muse/${s}/${t}/${t}_t1_LPS_N4_r_muse.nii.gz";

  python ${script} -i ${flair} -m ${brainmask} -l ${manseg} -o "${outdir}/${t}_${modality}.png" -t "${t}_${modality}";
  python ${script} -i ${flair_n3} -m ${brainmask} -l ${manseg} -o "${outdir}/${t}_${modality}_n3.png" -t "${t}_${modality}_N3";
  python ${script} -i ${flair_n4} -m ${brainmask} -l ${manseg} -o "${outdir}/${t}_${modality}_n4.png" -t "${t}_${modality}_N4";

  modality="t1";

  flair="${dir}/${t}_${modality}_LPS_r_SSFinal.nii.gz";
  flair_n3="${dir}/${t}_${modality}_LPS_r_SSFinal_n3.nii.gz";
  flair_n4="${dir}/${t}_${modality}_LPS_r_SSFinal_n4.nii.gz";
  manseg="${dir}/${t}_LPS_r_manualSegm.nii.gz";
  brainmask="/cbica/projects/brain_tumor/Brain_Tumor_2018/Protocols/3_Muse/${s}/${t}/${t}_t1_LPS_N4_r_muse.nii.gz";

  python ${script} -i ${flair} -m ${brainmask} -l ${manseg} -o "${outdir}/${t}_${modality}.png" -t "${t}_${modality}";
  python ${script} -i ${flair_n3} -m ${brainmask} -l ${manseg} -o "${outdir}/${t}_${modality}_n3.png" -t "${t}_${modality}_N3";
  python ${script} -i ${flair_n4} -m ${brainmask} -l ${manseg} -o "${outdir}/${t}_${modality}_n4.png" -t "${t}_${modality}_N4";

  modality="t2";

  flair="${dir}/${t}_${modality}_LPS_r_SSFinal.nii.gz";
  flair_n3="${dir}/${t}_${modality}_LPS_r_SSFinal_n3.nii.gz";
  flair_n4="${dir}/${t}_${modality}_LPS_r_SSFinal_n4.nii.gz";
  manseg="${dir}/${t}_LPS_r_manualSegm.nii.gz";
  brainmask="/cbica/projects/brain_tumor/Brain_Tumor_2018/Protocols/3_Muse/${s}/${t}/${t}_t1_LPS_N4_r_muse.nii.gz";

  python ${script} -i ${flair} -m ${brainmask} -l ${manseg} -o "${outdir}/${t}_${modality}.png" -t "${t}_${modality}";
  python ${script} -i ${flair_n3} -m ${brainmask} -l ${manseg} -o "${outdir}/${t}_${modality}_n3.png" -t "${t}_${modality}_N3";
  python ${script} -i ${flair_n4} -m ${brainmask} -l ${manseg} -o "${outdir}/${t}_${modality}_n4.png" -t "${t}_${modality}_N4";

done;