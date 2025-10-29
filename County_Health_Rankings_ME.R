setwd("~/Desktop/Portfolio")
library(readxl)
library(dplyr)
library(ggplot2)
library(scales)
library(tigris)
# READ IN MAINE COUNTY DATA FROM CHRR
CHRR_ME <- read_xlsx("./ME_Uninsured/2025 County Health Rankings Maine Data.xlsx","Select Measure Data")
# SELECT ONLY UNINSURED DATA AND CREATE A NEW DATASET; RENAME COLUMNS; REMOVE EXTRA HEADER ROW
uninsured_ME <- CHRR_ME %>% select(, c(1:3),c(,113:117)) %>% 
  rename_with(~ c("FIPS", "State", "County","#_Uninsured","%_Uninsured","%_95_LCL","%_95_UCL","National_Z_Score")) %>% 
  slice(-1)
# CHANGE FORMATS OF COLUMN DATA
uninsured_ME <-  uninsured_ME %>% mutate(across(c('#_Uninsured':'National_Z_Score'), as.numeric))
# LOOK AT 5 COUNTIES WITH HIGHEST % UNINSURED
uninsured_ME %>% arrange(desc(uninsured_ME$`%_Uninsured`)) %>% 
  subset(County != 'NA') %>% head(5)
# READ IN ME COUNTY SHAPEFILE
me_counties <- counties(state = "ME", cb = TRUE, class = "sf", progress_bar = FALSE)
# JOIN UNINSURED DATA TO CENSUS SHAPEFILE BY COUNTY NAME
me_map <- me_counties %>% 
  left_join(uninsured_ME, by = c("NAME" = "County")) 
# DIVIDE %_UNINSURED COLUMN BY 100 TO GET IN CORRECT FORMAT FOR MAPPING
me_map$`%_Uninsured` <- me_map$`%_Uninsured` / 100
# MAP OF ME COUNTIES WITH % UNINSURED
uninsured <- me_map %>% 
  ggplot + 
  geom_sf(aes(fill = `%_Uninsured`)) + 
  scale_fill_viridis_c(option = "mako",
                       direction = -1, 
                       name = "Percent of Uninsured",
                       labels = scales::percent,
                       limits = c(.07, 0.13),
                       oob = scales::squish) +
  theme_minimal() + 
  theme(
    axis.text = element_blank(), 
    panel.grid = element_blank(),
    legend.position = "right",
    legend.title = element_text(family = "sans",size = 10),
    legend.text = element_text(hjust = 1),
    plot.caption = element_text(
      family = "sans",
      size = 10,          
      hjust = 0.05,       
      face = "italic",    
      color = "black"      
    )) +
  labs(title = "York and Cumberland Counties in Maine\nHave Lowest Percent Populaion Uninsured", family = "sans",size=9)
uninsured

# NOW GOING TO CREATE A LONGITUDINAL LINE GRAPH Of % UNINSURED IN US AND ME, 2008-2024
#IMPORT CLEANED DATASET WITH LONGITUDINAL DATA (COLUMNS:YEAR,GEOGRAPHY,PERCENTAGE)
longitudinal <- read_xlsx("./ME_Uninsured/longitudinal_uninsured.xlsx","longitudinal")
#GRAPH DATA
longitudinal_US_ME <-ggplot(longitudinal, aes(x=longitudinal$Year, y=longitudinal$Percentage, color=longitudinal$Geography)) +
  geom_line() + geom_point() +
  scale_y_continuous(labels = percent) +
  scale_color_manual(values = c("US" = "red", "ME" = "blue"),name = "Geography") +
  theme_minimal() +
  ggtitle("Percent Uninsured in United States and Maine, 2008-2024") +
  xlab("Year") + ylab("Percentage Population Uninsured") + 
  labs(caption ="(based on data from Census Bureau's Health Insurance Historical Tables)") + 
  annotate("text", x = 2020, y = 0.13, label = "Although the ACA was signed into\nlaw in 2010, most of the new\n rules took effect in 2014.", 
           size = 3, color = "black")
longitudinal_US_ME

# LASTLY, WANT TO UNDERSTAND THE PERCENTAGE OF UNINSURED IN MAINE AS COMPARED TO THE REST OF NEW ENGLAND
# WILL CREATE A BAR CHART AND A MAP
# This data was estimated by KFF based on the 2023 American Community Survey, 1-year Estimate.
health_insurance <- read_xlsx("./ME_Uninsured/health_insurance_us.xlsx")
# CREATE A NEW DATASET WITH JUST NEW ENGLAND STATES: CT,MA,ME,NH,RI,VT
new_england <- health_insurance %>% filter(Location %in% c("Connecticut", "Massachusetts","Maine","New Hampshire","Rhode Island","Vermont"))
# CREATE A BAR CHART SHOWING THE PERCENT UNINSURED IN EACH STATE
col_new_england <- ggplot(new_england, aes(x=Location, y=Uninsured)) +
  geom_col(fill="lightblue") + 
  geom_text(aes(label = paste0(round(Uninsured * 100, 1), "%")), vjust = 2, colour = "black") +
  ggtitle("MA and VT Have Lowest Percent Uninsured Among Population") +
  xlab("State") +
  theme_minimal() +
  scale_y_continuous(labels = percent)
col_new_england

#THIS SHOWS THAT MAINE HAS THE HIGHEST PERCENTAGE OF POPULATION THAT IS UNINSURED OUT OF THE NEW ENGLAND STATES (2023 DATA)  
# NOW TO CREATE MAP OF NEW ENGLAND STATES AND % UNINSURED
# FIRST READ IN CENSUS SHAPEFILES AND THEN SELECT ONLY NEW ENGLAND STATES
ne_states <- states <- states(cb = TRUE)
ne_states <-ne_states %>%  filter(NAME %in% c("Connecticut", "Massachusetts","Maine","New Hampshire","Rhode Island","Vermont"))
# JOIN STATE SENCUS AND STATE UNINSURED DATA
ne_map <- ne_states %>% 
  left_join(new_england, by = c("NAME" = "Location")) 
# NOW CREATE THE HEAT MAP OF % UNINSURED
new_england_map <- ne_map %>% 
  ggplot + 
  geom_sf(aes(fill = `Uninsured`)) + 
  scale_fill_viridis_c(option = "mako",
                       direction = -1, 
                       name = "Percent Uninsured (2023)",
                       labels = scales::percent,
                       limits = c(.02, 0.06),
                       oob = scales::squish) +
  theme_minimal() + 
  theme(
    axis.text = element_blank(), 
    panel.grid = element_blank(),
    legend.position = "right",
    legend.title = element_text(family = "sans",size = 10),
    legend.text = element_text(hjust = 1),
    plot.caption = element_text(
      family = "sans",
      size = 10,          
      hjust = 0.05,       
      face = "italic",    
      color = "black"      
    )) +
   labs(title = "ME and CT Have Highest Percent Uninsured Among Population", family = "sans",size=9)
new_england_map
