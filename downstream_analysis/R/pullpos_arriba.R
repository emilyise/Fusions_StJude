# script to pull chromosomal location data from arriba for circos plot

egi_find_pos <- function(arriba_data) {
  
  aggpos <- arriba_data %>%
    mutate(sample.id = sample_name,
           chr1 = gsub("chr", "", word(breakpoint1, 1, sep = ":")),
           pos1 = word(breakpoint1, 2, sep = ":"),
           chr2 = gsub("chr", "", word(breakpoint2, 1, sep = ":")),
           pos2 = word(breakpoint2, 2, sep = ":"),
           Fusion = paste(gene1, gene2, sep = ":")) %>%
    select(sample.id, Fusion, chr1, pos1, chr2, pos2) %>%
    mutate(pos1 = as.numeric(pos1),
           pos2 = as.numeric(pos2))
  
  return(aggpos)
  
}