# Using dataset toothgrowth
ToothGrowth
?ToothGrowth

# Upload tidyr
#install.packages("tidyr") if necessary
library(tidyr)

# Create row_id for supp

ToothGrowth$row_id <- rep(1:30, times = 2)
ToothGrowth
toothgrow_supp <- pivot_wider(ToothGrowth, id_cols = row_id, names_from = supp, values_from = len)
toothgrow_supp

ToothGrowth$row_dose <- c(rep(1:10, times=3), rep(11:20, times=3))
ToothGrowth
toothgrow_dose <- pivot_wider(ToothGrowth, id_cols = row_dose, names_from = dose, values_from = len)
toothgrow_dose

ToothGrowth$combined <- rep(1:10, times = 6)
wide_supp_dose <- pivot_wider(ToothGrowth,id_cols = combined, names_from = c(supp, dose), values_from = len, names_sep = "_")
wide_supp_dose

# another way - pivot_longer(toothgrow_supp, cols= VC:OJ, names_to = "supp", values_to = "len")

toothgrow_long_supp <- toothgrow_supp %>%
pivot_longer(names_to = "supp", values_to = "len", cols = c("VC", "OJ"))
toothgrow_long_supp

toothgrowth_long_dose <- toothgrow_dose %>%
pivot_longer(names_to = "dose", values_to = "len", cols = c("0.5", "1", "2"))
toothgrowth_long_dose

long_supp_dose <- wide_supp_dose %>%
pivot_longer(names_to = c("supp", "dose"), values_to = "len", names_sep = "_", cols = c("VC_0.5","VC_1","VC_2","OJ_0.5","OJ_1","OJ_2"))
long_supp_dose

# ctrl + alt+ b runs everything before cursor


# Another approach: reorder first
# Toothgrowth[order(toothgrowth$dose),]

# playing in tidyverse







