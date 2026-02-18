rm(list = ls(all.names = TRUE))
library(dplyr)
library(tidyr)
library(paran)
library(data.table)
library(psych)
library(tidyverse)
behav.raw <- read_csv('D:/InformationGatheringMRI/BEH/InformationGathering_DATA_2025-04-08_1320.csv')
filtered_data <- behav.raw %>%
  filter(inf_gather_timestamp != "[not completed]")
########################## Demography ##############################

ethnicity_raw  <-filtered_data$ethnicity
slices <- table(ethnicity)
lbls <- c("Asian", "Arab", "Black/African/Caraibean",'Latino/Hispanic', "White", "Other")
pie(slices, labels = lbls, main="Pie Chart of Countries")

ethnicity <- factor(ethnicity_raw, levels = 1:6, labels = lbls)
eth_table <- table(ethnicity)

bp <- barplot(eth_table,
              main = "Ethnicity Distribution",
              ylab = "Count",
              col = "skyblue",
              xaxt = "n")  # Suppress x-axis labels

# Add rotated labels manually
text(x = bp, 
     y = par("usr")[3] - 0.5,
     labels = names(eth_table), 
     xpd = TRUE,
     srt = 45,
     adj = 1,
     cex = 0.8)  # Smaller size (1 = default)



education_raw <- filtered_data$education
lbls <- c('No formal schooling','Primary school','Secondary school',
          'College/Pre-University','Undergraduate or equivalent',
          'Master or equivalent',
          'Doctorate/PhD or equivalent')
education_factor <- factor(education_raw, levels = 1:7, labels = lbls)

# Create table including 0s for missing categories
slices <- table(education_factor)

# Plot pie chart
pie(slices,
    labels = names(slices),
    main = "Pie Chart of Education",
    col = rainbow(length(slices)))


######################## Extract questionnaires ###############################

OCI <- filtered_data %>% dplyr::select(ocir_1:ocir_18)
STAI_state <- filtered_data %>% dplyr::select(stai_1_state:stai_20_state)
PADUA <- filtered_data %>% dplyr::select(padua_1:padua_39)
FMPI <-  filtered_data %>% dplyr::select(fmps_0:fmps_34)
STAI_trait <-  filtered_data %>% dplyr::select(stai_1_v2:stai_20_v2)
IUS <-   filtered_data %>% dplyr::select(ius_1_v2:ius_27_v2)
BIS <-  filtered_data %>% dplyr::select(bis_1_v2:bis_30_v2)
BDI <-  filtered_data %>% dplyr::select(bdi_sad:bdi_sex)

##################### Subscales ###############################

