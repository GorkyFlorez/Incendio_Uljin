library(rgee)
library(sf)
library(raster)
library(ggspatial)
library(cptcity)
library(leaflet)
library(leafem)
library(leaflet.extras)
library(grid)
library(RStoolbox)
library(ggplot2)
library(tmap)
library(mapedit)
library(googledrive)
library(tibble)
library(tidyverse)
library(sp)
library(leaflet.extras2)
library(raster)
library(stars)
library(geojsonio)

ee_Initialize("gflorezc", drive = T)

ambito <- mapedit::drawFeatures()       # Creamos el objeto
ambito <- ambito %>% st_as_sf() 
write_sf(ambito, "SHP/Incendio_Uljin.shp")
box <- ee$Geometry$Rectangle(coords= c(129.21 , 36.91746, 129.4982, 37.2323),
                             proj= "EPSG:4326", geodesic = F)

Poligono <-ee$FeatureCollection("users/gflorezc/Incendio_Uljin")
#2. Dataset --------------------------------------------------------------

lista <- ee$ImageCollection("COPERNICUS/S2")$
  filterDate("2022-03-01", "2022-03-14")$
  filterBounds(Poligono)$
  filterMetadata('CLOUDY_PIXEL_PERCENTAGE', 'Less_Than', 100)

catalogo <- ee_get_date_ic(lista)                         # Catalogo de imagenes 
catalogo

sentinel2 <- ee$ImageCollection("COPERNICUS/S2_SR")

Trueimage <-sentinel2$filterBounds(Poligono)$ 
  filterDate("2022-03-01", "2022-03-14")$ 
  sort("CLOUDY_PIXEL_PERCENTAGE", FALSE)$
  mosaic()$
  clip(Poligono)

# Seleccion de las bandas
viz       <- list(min= 0, max= 6000, bands= c("B11","B8", "B2")) 
vi        <- list(min= 0,
                  max= 6000, bands= c("B4","B3", "B2")) 

Map$centerObject(Poligono)
Map$addLayer(eeObject = Trueimage , "Agricultura Sentinel 2 (11 8 2)", visParams = viz)  |
  Map$addLayer(eeObject = Trueimage , "Color Natural Sentinel 2 (4 3 2)", visParams = vi) 


B11.8.2 <-sentinel2$filterBounds(Poligono)$ 
  filterDate("2022-03-01", "2022-03-14")$ 
  sort("CLOUDY_PIXEL_PERCENTAGE", FALSE)$
  mosaic()$
  clip(Poligono)%>% 
  ee$Image$select(c("B11","B8", "B2"))

B432 <-sentinel2$filterBounds(Poligono)$ 
  filterDate("2022-03-01", "2022-03-14")$ 
  sort("CLOUDY_PIXEL_PERCENTAGE", FALSE)$
  mosaic()$
  clip(Poligono)%>% 
  ee$Image$select(c("B4","B3", "B2"))

B432   %>% ee_as_raster(region= box, scale=10, dsn="Uljin_432/Uljin_432") -> UNAMAD_4325
B11.8.2%>% ee_as_raster(region= box, scale=10, dsn="Uljin_B11.8.2/Uljin_B11.8.2") -> UNAMAD_B11.8.2



