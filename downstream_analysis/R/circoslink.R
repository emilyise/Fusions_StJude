# script to easily plot link tracks 
## use data structure of output from "pullpos.R"

egi_circoslink <- function(links, basecolor, thetitle){
  
  # derive fill colors from basecolor
  basecolor <- unname(basecolor)
  base <- col2rgb(basecolor) / 255
  
  dark  <- rgb(base[1, ] * 0.55,
               base[2, ] * 0.55,
               base[3, ] * 0.55)
  
  light <- rgb(1 - (1 - base[1, ]) * 0.35,
               1 - (1 - base[2, ]) * 0.35,
               1 - (1 - base[3, ]) * 0.35)
  
  cols <- colorRampPalette(c(dark, basecolor, light))(23)
  
  # make background track
  tracklist = BioCircosBackgroundTrack('myBackgroundTrack', minRadius = 0, 
                                       maxRadius = 0.9, borderSize = 0, 
                                       fillColors = "white")
  
  # make link track
  tracklist = tracklist + BioCircosLinkTrack('myLinkTrack',
                                             links$chr1, 
                                             links$pos1,
                                             links$pos1 + 750000,
                                             links$chr2,
                                             links$pos2,
                                             links$pos2 + 750000,
                                             maxRadius = .95,
                                             color = basecolor,
                                             labels = links$Fusion,
                                             displayLabel = F)
  
  # make title track
  tracklist = tracklist + BioCircosTextTrack('myTextTrack', 
                                            paste0(thetitle), 
                                            size = "1.6em", 
                                            opacity = 0.8, 
                                            x = -1.4, y = -1.5)
  
  p <- BioCircos(tracklist, genomeFillColor = cols,
                 chrPad = 0.02, displayGenomeBorder = TRUE, yChr = FALSE,
                 genomeTicksDisplay = FALSE)
  
  return(p)
}






