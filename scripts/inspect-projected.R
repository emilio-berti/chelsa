library(terra)

ff <- list.files("data/original/present/europe", full.names = TRUE)
bios <- sapply(ff, function(f) strsplit(f, "/")[[1]][5], USE.NAMES = FALSE)
bios <- gsub("-[0-9]+.tif", "", bios)
r <- rast(ff)
names(r) <- bios
r[[1]] <- r[[1]] - 273.15
r[[2]] <- r[[2]] - 273.15
r[[3]] <- r[[3]] - 273.15
plot(r[[2]] / 3 - 273.15)
