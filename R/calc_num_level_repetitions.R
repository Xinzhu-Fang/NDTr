#' @title calc_num_level_repetitions
#'
#' @description  This function takes in labels in binned label format, and an integer k,
#' and returns the indices for all sites (e.g. neurons) that have at least
#' k presentations of each condition.
#'
#' @param binned_data Should be a dataframe in binned format.
#' @param variable_to_use A string that indicates what variable to analyze.
#' @param levels_to_use A single string or a vector of strings.
#' @param k_value  Returns indices for all sites (e.g. neurons) that have at least
#'   k presentations of each condition.
#'
#' @return 
#' \item{level_repetition_info}{A list of tables and plots containing the level repetition info}
#' @examples
#' \dontrun{
#' calc_num_level_repetitions(binned_data, "labels.stimulus_ID")
#' }
#' \dontrun{
#' calc_num_level_repetitions(binned_data, "labels.stimulus_ID", c("kiwi", "flower"), 60)
#' }      
#'
#' @import R6
#' @import dplyr
#' @import ggplot2
#' @import magrittr
#' @export



# binned_data = binned_data[ceiling(runif(10000, 0, 15833)), ] 
#
# variable_to_use = "labels.stimulus_ID"
# 
# levels_to_use =c("kiwi", "flower")

calc_num_level_repetitions <- function(binned_data, variable_to_use, levels_to_use = NULL, k = 0) {

  # browser()
  # dealing with dplyr nonstandard evaluation...
  binned_data <- select(binned_data, siteID, level = paste0("labels.", variable_to_use))


  if (is.null(levels_to_use)) {
    levels_to_use <- levels(binned_data$level)
  } else {
    # Test if levels_to_use given is valid
    contain_all = TRUE
    for (iLevel in levels_to_use) {
      if(!(iLevel %in% levels(binned_data$level))){
        contain_all = FALSE
      }
    }
    if (!contain_all) {
      stop("Error: invalid level_to_use")
    }
  }

  binned_data <- filter(binned_data, binned_data$level %in% levels_to_use)


  melted_num_repeats_per_level_per_site <- binned_data %>%
   group_by(siteID, level) %>%
    count()


  num_repeats_per_level_per_site <- tidyr::spread(melted_num_repeats_per_level_per_site, level, n)

  num_repeats_across_levels_per_site <- melted_num_repeats_per_level_per_site %>%
    group_by(siteID) %>%
     summarize(min_repeats = min(n))

  sites_with_at_least_k_repeats <- filter(num_repeats_across_levels_per_site, min_repeats >= k)

  # all ints become characters here, wouldn't help to convert them back here cuz it happens again the next step
  # num_sites_with_certain_repeats_per_level <- ungroup(melted_num_repeats_per_level_per_site %>% 
  #   group_by(level) %>% 
  #   count(n)) %>% 
  #   transmute(level = level, n = as.numeric(n), nn = as.numeric(nn))
  
  num_sites_with_certain_repeats_per_level <- ungroup(melted_num_repeats_per_level_per_site %>% 
                                                        group_by(level) %>% 
                                                        count(n)) 
  # all ints become characters here
  min_repeats_across_sites_across_levels <-  as.numeric(min(num_sites_with_certain_repeats_per_level$n))
  for (iLevel in levels_to_use){
    # min_repeat <- min(filter(num_sites_with_certain_repeats_per_level, level == iLevel)$n)
    iMin_repeats <- as.numeric(min(filter(num_sites_with_certain_repeats_per_level, level == iLevel)$n))
    # if we don't check here, n might = iMin_repeats = min_repeats_across_sites_across_levels 
    if(min_repeats_across_sites_across_levels != iMin_repeats){
      level <- rep(iLevel, iMin_repeats - min_repeats_across_sites_across_levels)
      n <- min_repeats_across_sites_across_levels : iMin_repeats 
      nn <- rep(0, iMin_repeats - min_repeats_across_sites_across_levels)
      # all ints become characters here 
      dfSup <- cbind(level, n, nn)
      num_sites_with_certain_repeats_per_level %<>% rbind(dfSup)
    }

    
  }
  
  
  # cumsum() nicely sums by factor
  num_sites_with_certain_repeats_per_level %<>%
    group_by(level) %>%
    mutate(n = as.numeric(n), nn = as.numeric(nn)) %>%
    arrange(desc(n)) %>% 
    mutate(cumulative_sum = cumsum(nn)) 
  
  plot_num_sites_against_num_level_repetitions <- num_sites_with_certain_repeats_per_level %>%
        ggplot(aes(n, cumulative_sum, col = level)) +
    geom_line(alpha = 0.7) + 
    scale_x_continuous(breaks =  min(num_sites_with_certain_repeats_per_level$n): max(num_sites_with_certain_repeats_per_level$n)) +
    scale_y_continuous(breaks = min(num_sites_with_certain_repeats_per_level$cumulative_sum) : max(num_sites_with_certain_repeats_per_level$cumulative_sum)) +
         labs(x = "Number of repeats", y = "Number of sites")
  # title = "Number of sites with at least certain number of repeats for all levels"
  # browser()
  
  #check if all sites have the same number of repetitions

  plotly_num_sites_against_num_level_repetitions <- plotly::ggplotly(plot_num_sites_against_num_level_repetitions)

  level_repetition_info <- NULL
  # level_repetition_info$melted_num_repeats_per_level_per_site <- melted_num_repeats_per_level_per_site
  # level_repetition_info$num_repeats_per_level_per_site <- num_repeats_per_level_per_site
  level_repetition_info$num_repeats_across_levels_per_site <- num_repeats_across_levels_per_site
  level_repetition_info$sites_with_at_least_k_repeats <- sites_with_at_least_k_repeats
  # level_repetition_info$levels_used <- levels_to_use
  level_repetition_info$plotly <- plotly_num_sites_against_num_level_repetitions
  level_repetition_info$max_repetition_avail_with_any_site <- max(num_repeats_across_levels_per_site$min_repeats)
  return(level_repetition_info)

} #end calc_num_level_repetitions



