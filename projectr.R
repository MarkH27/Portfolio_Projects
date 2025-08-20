library(readxl)
library(dplyr)
library(tidyr)

# Load the Excel file with actual column names on row 2 (skip first row)
file_path <- "2024 WAM Items Sold.xlsx"
df <- read_excel(file_path, skip = 1)

# Column 1 is artist name, last column is art type, columns 3 to 19 are dates
artist_col <- "ARTIST"  # This column actually contains the artist's name
art_type_col <- names(df)[ncol(df)]  # Last column = Art Type (e.g., Ceramics, Painting)
date_cols <- names(df)[2:21]  # Sales columns

# Pivot sales columns into long format
long_df <- df %>%
  pivot_longer(
    cols = all_of(date_cols),
    names_to = "Date",
    values_to = "Sales",
    values_drop_na = TRUE
  ) %>%
  mutate(
    Sales = as.numeric(Sales),
    Artist = .data[[artist_col]],
    Art_Type = .data[[art_type_col]]
  )

# Group by art type and artist to see individual totals
sales_by_artist_type <- long_df %>%
  group_by(Art_Type, Artist) %>%
  summarise(Total_Sales = sum(Sales, na.rm = TRUE)) %>%
  arrange(desc(Total_Sales))

# View full breakdown
print(sales_by_artist_type)

# Total sales per art type
sales_by_type <- sales_by_artist_type %>%
  group_by(Art_Type) %>%
  summarise(Art_Type_Total = sum(Total_Sales)) %>%
  arrange(desc(Art_Type_Total))

# View overall best-selling art type
print(sales_by_type)
