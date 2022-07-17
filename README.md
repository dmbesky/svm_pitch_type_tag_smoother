# SVM Pitch Type Tag Smoother

## Intro

With pitch tracking technology, pitch classifications are in many cases manually tagged and can correspondingly be inconsistent - leading to issues with summarizing that data. 
Assuming these tags are broadly correct just inconsistent, we may be able to generate more consistent tags by fitting a rigid SVM for each pitcher to find the dividing lines between the pitch types in a feature space including the critical pitch movement metrics (velocity, horizontal break, vertical break) - without overfitting to the incorrect labels.

*svm_pitch_tag_cleaner.R* takes in a csv with the required column types (*sample_data.csv* illustrates the required csv specifications) and returns a copy of said dataframe with the SVM fit pitch type tags as well. It also includes a function - visualize_tag_adjustments() - for comparing the initial pitch type tags with the SVM based tags.

I thought this approach was an efficient way to bulk clean pitch tags that accounts for different pitchers arsenals and leverages the information from the existing tags rather than ignoring those and attempting to reclassify pitches from scratch.

Thus, the results here depend upon the initial pitch tags being generally directionally correct - and may output weird results when that does not hold. Furthermore, pitch types with only a couple occurences prove difficult to handle.

Nonetheless, I believe this approach may provide some value relative to applying fixed pitch classification heuristics across all athlete and/or in its simplicity. A couple of examples showing how it adjusts tags:

![svm_pitch_tag_example_1](https://user-images.githubusercontent.com/38742461/179382989-823f3186-64e0-4b68-981b-495d0fd69898.jpg)

![svm_pitch_tag_example_2](https://user-images.githubusercontent.com/38742461/179383005-5136cbe3-474a-499c-8fd7-0a8e689d5330.jpg)

## Dependencies

The following R packages are required:

* e1071
* magrittr
* dplyr
* ggplot2
* cowplot
