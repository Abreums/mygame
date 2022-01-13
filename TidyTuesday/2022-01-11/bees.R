
# Read in with tidytuesdayR package 
# Install from CRAN via: install.packages("tidytuesdayR")
# This loads the readme and all the datasets for the week of interest

# Either ISO-8601 date or year/week works!

library(tidyverse)
library(scales)

# Or read in the data manually
colony <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-01-11/colony.csv')


colony <- 
  colony %>% 
  mutate(
    dt_u = case_when(
      months == "January-March" ~ "-02-01",
      months == "April-June" ~ "-05-01",
      months == "July-September" ~ "-08-01",
      TRUE ~"-11-01"),
    dt_u = as.POSIXct(str_c(year, dt_u)),
    season = case_when(
      months == "January-March" ~ "Summer",
      months == "April-June" ~ "Autumn",
      months == "July-September" ~ "Winter",
      TRUE ~"Spring")
    )

# as from this link:
# https://stackoverflow.com/questions/43625341/reverse-datetime-posixct-data-axis-in-ggplot
c_trans <- function(a, b, breaks = b$breaks, format = b$format) {
  a <- as.trans(a)
  b <- as.trans(b)
  
  name <- paste(a$name, b$name, sep = "-")
  
  trans <- function(x) a$transform(b$transform(x))
  inv <- function(x) b$inverse(a$inverse(x))
  
  trans_new(name = name, 
            transform = trans, 
            inverse = inv, 
            breaks = breaks, 
            format=format)
}
rev_date <- c_trans("reverse", "time")

# Need better colors for the seasons
myColors <- c("Summer" = "#f47db7", "Autumn" = "#e6867d", 
              "Winter" = "#4689dd", "Spring" = "#56adc5")

# generate plot for hole country
theState = "United States"
#theState = "Texas"

bee_colony_loss <- 
colony %>% 
  mutate(dt_u = as.POSIXct(dt_u),
         colony_lost_pct = colony_lost_pct/100) %>% 
  filter(state == theState) %>% 
  filter(!is.na(colony_lost_pct)) %>% 
  ggplot(aes(x = colony_lost_pct, y = dt_u, color = season)) +
  geom_point() +
  geom_segment(aes(x = 0, xend = colony_lost_pct, 
                   y = dt_u, yend = dt_u)) +
  scale_x_continuous(position="top", labels = scales::percent_format(accuracy=1)) +
  scale_y_continuous(trans = rev_date) +
  scale_color_manual(values=myColors) +
  theme_bw() +
  labs(color = "Season",
       title = "Percentage of bee colony loss\nEven if the rate is decreasing we are still losing bees",
       subtitle = theState,
       y = NULL,
       x = NULL)

ggsave(filename = "./TidyTuesday/2022-01-11/bee_colony_loss.png", plot = last_plot())
(bee_colony_loss)
