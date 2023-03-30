library(prism)
library(terra)
library(tidyverse)
library(tidyterra)
library(scico)
library(httr)
library(tmap)

#### First use the GEE script to download the dataset 

setwd('D:/Projetos_Artigos/Artigos/Cobertura_Caudal/Dados_Smap/')

files <- list.files('SMAP10KM_soil_moisture_UY/', full.names = T, pattern =  ".tif$")

grid = terra::rast(xmin = -59, xmax = -52.5, ymin = -35.5, ymax = -29.5, resolution = c(0.01, 0.01), vals = 0)

TC <- terra::vect("D:/Projetos_Artigos/Artigos/Cobertura_Caudal/GIS_data/Bacia.shp")
TC <- terra::project(TC, grid) %>%  terra::makeValid()

Date <- files %>% stringr::str_split_fixed(pattern = 'P_', n = 2) %>% .[,2] %>%
  stringr::str_split_fixed(pattern = '.tif', n = 2) %>% .[,1] %>%
  stringr::str_split_fixed(pattern = '._', n = 2) %>% .[,2]

Date <-  as.Date(as.character(Date),format = "%Y%m%d")

SMAP <- terra::rast(files)

terra::plot(SMAP)

#### Convert to monthly

out0 <- SMAP %>% terra::resample(grid) %>% terra::mask(TC) %>% terra::trim() #Resample and clip
time(out0) <- Date 
d <- time(out0)
m <- as.numeric(format(d, "%m"))
y <- as.numeric(format(d, "%Y"))
ym <- paste0(y, m)
out_ym <- tapp(out0, ym, mean)
Date_m <- seq(from = first(Date), to = last(Date), by= 'month')
names(out_ym) <- c(Date_m, last(Date))

terra::plot(out_ym[[30]])
terra::lines(TC)
animate(out_ym)

#### Convert to yearly
out1 <- out_ym
time(out1) <-  c(Date_m, last(Date))
d <- time(out1)
y <- as.numeric(format(d, "%Y"))
out_y1<- tapp(out1, y, sum)
names(out_y1) <- seq(from = 2016, to = 2022)

plot(out_y1)

#########################################################

# Improve the plot 
# See: https://github.com/lvsantarosa/Multi-temporal-maps-plot/blob/main/Script_Prec.R

ggplot() +
  geom_spatraster(data = out_y1) +
  geom_spatvector(data =TC, fill = NA, size = 0.1) +
  scale_fill_scico(name = "Subsurface soil moisture \n (mm year-1)", palette = "lajolla", direction = -1,
                   breaks = c(0,300,600,900,1200,1500),
                   na.value = "transparent") +
  facet_wrap(~lyr, ncol = 3, nrow = 4) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        panel.border = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        strip.text = element_text(hjust = 0, size = 9),
        strip.background = element_blank(),
        legend.position = "right",
        legend.direction = "vertical",
        legend.key.height = ggplot2::unit(40L, "pt")) +
  labs(caption = "2016-2022 Yeartly Subsurface soil moisture\n Source: NASA-USDA Enhanced SMAP Global Soil Moisture Data 0.1 deg.")

# Animate 
animation <- tm_shape(out_y1)+tm_raster()+
             tm_facets(nrow = 1, ncol = 1)
animation
tmap_animation(animation, filename = "Animation.mp4", 
               width=1200, height = 600, fps = 2, outer.margins = 0)
