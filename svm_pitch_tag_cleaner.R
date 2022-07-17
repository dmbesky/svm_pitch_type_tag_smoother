library(e1071) #for svm function
library(magrittr) #for %>%
library(dplyr) #for summarize and filter
library(ggplot2) #for the pitch label comparison visuals
library(cowplot) #for plot_grid

init_data = read.csv('sample_data.csv') #required column names are pitcher_id, initial_pitch_type, velo, vert_break, horz_break

init_data = init_data %>% 
  filter_at(vars(velo,vert_break, horz_break),any_vars(!is.na(.))) %>%
  mutate(initial_pitch_type = as.factor(initial_pitch_type))

#Function to Createa a Separate SVM Model for each pitcher - to customize pitch tags to their unique clusters and pitch types
tag_cleaner <- function(spec_pitcher_id){
  print(spec_pitcher_id)
  #Filter to just specific pitcher and remove any pitches with NAs in Velo, HB, VB 
  pdata <- init_data %>% filter(pitcher_id == spec_pitcher_id)  

  #Create the training dataset - just the tagged pitches and only the specific columns
  predvars <-pdata %>% filter(!is.na(initial_pitch_type))
  
  #Fit the SVM and then predict the new tags - parameters manually set through trial and error to achieve the desired effect
  svmfit = svm(initial_pitch_type ~ velo + vert_break + horz_break, data = predvars, kernel = "linear", cost = 0.5, scale = TRUE)
  pdata$svm_pitch_type <- predict(svmfit, pdata)
  
  return(pdata)
}  

#Create a Grid of ggplot's illustrating the initial and cleaned pitch tags
visualize_tag_adjustments <- function(spec_pitcher_id){
  spec_pitcher_data = output %>% filter(pitcher_id == spec_pitcher_id)
  
  #define a consistent color scale for pitch tags - across the different plots here - with only the relevant pitch types in the legend
  colors_for_scale = c('#0072b2', "#ffa300", '#009e73', '#F0E442', '#CC79A7', '#9d79cc', '#3dad26', "#fc3535", 'gray50', '#000000')
  names(colors_for_scale) <- unique(spec_pitcher_data$initial_pitch_type)
  pitch_type_color_scale <- scale_colour_manual(name = "Pitch Type", values = colors_for_scale)
  
  plot1 = spec_pitcher_data %>% ggplot(aes(x = horz_break, y= vert_break)) + geom_point(aes(color = initial_pitch_type)) + 
    ggtitle('Initial Tags', 'Movement Plot') + pitch_type_color_scale + theme(legend.position="none")
  plot2 = spec_pitcher_data %>% ggplot(aes(x = velo, y= vert_break)) + geom_point(aes(color = initial_pitch_type)) + 
    ggtitle('Initial Tags', 'Velo and VB') + pitch_type_color_scale + theme(legend.position="none")

  plot3 = spec_pitcher_data %>% ggplot(aes(x = horz_break, y= vert_break)) + geom_point(aes(color = svm_pitch_type))  + 
    ggtitle('Cleaned Tags', 'Movement Plots') + pitch_type_color_scale + theme(legend.position="none")
  plot4 = spec_pitcher_data %>% ggplot(aes(x = velo, y= vert_break)) + geom_point(aes(color = svm_pitch_type)) + 
    ggtitle('Cleaned Tags', 'Velo and VB') + pitch_type_color_scale + theme(legend.position="none")
  
  #Add the shared legend and create the grid of plots
  legend <- get_legend(plot1 + theme(legend.position = 'bottom', legend.spacing.x = unit(0.75, 'cm')))
  scatter_plots = plot_grid(plot1, plot2, plot3, plot4)
  scatter_plots = plot_grid(scatter_plots, legend, ncol = 1, rel_heights = c(8, 1))
  
  return(scatter_plots)
}


#Require at least 20 pitches of 2 pitch types, so the model has something reasonable to work with
qualifiers <- init_data %>% filter(!is.na(initial_pitch_type)) %>% group_by(pitcher_id) %>% 
  summarize(numtaggedpitches = n(), numpitches = n_distinct(initial_pitch_type)) %>% 
  filter(numtaggedpitches >= 20, numpitches >= 2)
qualifiers <- unique(qualifiers$pitcher_id)


output= bind_rows(lapply(qualifiers, tag_cleaner)) #apply function for each pitcher than merge to one dataframe

visualize_tag_adjustments('Test Athlete 1') #plot the adjustment for a specific athlete
