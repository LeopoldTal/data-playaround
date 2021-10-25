# Which time period's literature Nobel Prize winners have I heard of?

library(ggplot2)

nobel <- read.csv2('./nobel/nobel.txt', sep = '\t', header = TRUE)

# Cohen's d
# TODO: pull from a package instead of rewriting the wheel
pooled_sd <- function(treatment, control) {
	nt <- length(treatment) - 1
	vt <- var(treatment)
	
	nc <- length(control) - 1
	vc <- var(control)
	
	pooled_var <- (nt*vt + nc*vc) / (nt + nc)
	sqrt(pooled_var)
}
cohen.d <- function(treatment, control) {
	effect <- mean(treatment) - mean(control)
	effect / pooled_sd(treatment, control)
}

# Binary classification
nobel$known <- nobel$heardOf | nobel$read
ggplot(nobel, aes(x = factor(known), y = year, color = factor(known))) +
	geom_point(position = position_jitter(width = 0.05, height = 0)) +
	ylim(1900, 2022) + # FIXME: limits
	labs(title = 'Literature Nobel Prize winners') +
	scale_x_discrete('Have I heard of/read them?', labels = c('Unknown', 'Known')) + 
	ylab('Year prize received') +
	theme(legend.position = 'none', plot.title = element_text(hjust = 0.5))
known_years <- subset(nobel, nobel$known == TRUE)$year
unknown_years <- subset(nobel, nobel$known == FALSE)$year
cohen.d(known_years, unknown_years)

# Ternary classification
# FIXME: can I name the factors something nicer and still preserve the order?
nobel$group <- ifelse(
	nobel$read,
	'2-Read',
	ifelse(nobel$heardOf, '1-Heard of', '0-Unknown')
	)
ggplot(nobel, aes(x = factor(group), y = year, color = factor(group))) +
	geom_point(position = position_jitter(width = 0.05, height = 0)) +
	labs(title = 'Literature Nobel Prize winners') +
	xlab('Have I heard of/read them?') + 
	ylab('Year prize received') +
	theme(legend.position = 'none', plot.title = element_text(hjust = 0.5))
unknown_years <- subset(nobel, nobel$group == '0-Unknown')$year
heard_of_years <- subset(nobel, nobel$group == '1-Heard of')$year
read_years <- subset(nobel, nobel$group == '2-Read')$year
cohen.d(read_years, unknown_years)
cohen.d(read_years, heard_of_years)
cohen.d(heard_of_years, unknown_years)
