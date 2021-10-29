# Which time period's literature Nobel Prize winners have I heard of?

library(ggplot2)

nobel <- read.csv2('./nobel/nobel.txt', sep = '\t', header = TRUE)
palette_name <- 'Set1'
common_theme <- theme(legend.position = 'none', plot.title = element_text(hjust = 0.5))

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
cohen_d <- function(treatment, control) {
	effect <- mean(treatment) - mean(control)
	effect / pooled_sd(treatment, control)
}

# Binary classification
nobel$known <- nobel$heardOf | nobel$read
ggplot(nobel, aes(x = factor(known), y = year, color = factor(known))) +
	geom_point(position = position_jitter(width = 0.05, height = 0)) +
	scale_y_continuous(limits = c(min(nobel$year), max(nobel$year)), expand = expansion(add = 2)) +
	scale_colour_brewer(palette = palette_name) +
	labs(title = 'Literature Nobel Prize winners') +
	scale_x_discrete('Have I heard of/read them?', labels = c('Unknown', 'Known')) + 
	ylab('Year prize received') +
	common_theme
known_years <- subset(nobel, nobel$known == TRUE)$year
unknown_years <- subset(nobel, nobel$known == FALSE)$year
cohen_d(known_years, unknown_years)

# Ternary classification
nobel$group <- ifelse(
	nobel$read,
	'Read',
	ifelse(nobel$heardOf, 'Heard of', 'Unknown')
	)
group_factor <- factor(nobel$group, ordered = TRUE, levels = c('Unknown', 'Heard of', 'Read'))

# Strip chart
ggplot(nobel, aes(x = group_factor, y = year, color = group_factor)) +
	geom_point(position = position_jitter(width = 0.05, height = 0)) +
	scale_y_continuous(limits = c(min(nobel$year), max(nobel$year)), expand = expansion(add = 2)) +
	scale_colour_brewer(palette = palette_name) +
	labs(title = 'Literature Nobel Prize winners') +
	xlab('Have I heard of/read them?') + 
	ylab('Year prize received') +
	common_theme
unknown_years <- subset(nobel, nobel$group == 'Unknown')$year
heard_of_years <- subset(nobel, nobel$group == 'Heard of')$year
read_years <- subset(nobel, nobel$group == 'Read')$year
cohen_d(read_years, unknown_years)
cohen_d(read_years, heard_of_years)
cohen_d(heard_of_years, unknown_years)

# Histogram
min_decade <- round(min(nobel$year), -1)
max_decade <- round(max(nobel$year), -1)
ggplot(nobel, aes(x = year, fill = group_factor)) +
	geom_histogram(binwidth = 10, boundary = 0, color = 'black') +
	facet_wrap(group_factor, dir = 'v') +
	scale_fill_brewer(palette = palette_name) +
	scale_x_continuous(
		limits = c(min_decade, max_decade),
		expand = expansion(add = 1),
		breaks = seq(min_decade, max_decade, 20)
	) +
	labs(title = 'Literature Nobel Prize winners') +
	xlab('Year prize received') + 
	ylab('Number of prize winners') +
	common_theme

# Kolmogorov-Smirnov
source('./nobel/ks.R')

measured_nobel_ks <- ks(read_years, unknown_years)
plot_ks(
	read_years, unknown_years,
	values_label = 'Nobel year', treatment_label = 'Read', control_label = 'Unknown'
)

# Monte Carlo
n_read <- length(read_years)
n_unknown <- length(unknown_years)

min_year <- min(nobel$year)
max_year <- max(nobel$year)
dist_years_uniform <- function() {
	list(
		treatment = sample(min_year : max_year, n_read, replace = TRUE),
		control = sample(min_year : max_year, n_unknown, replace = TRUE)
	)
}

dist_years_nobel <- function() {
	list(
		treatment = sample(nobel$year, n_read, replace = TRUE),
		control = sample(nobel$year, n_unknown, replace = TRUE)
	)
}

dist_years_partition <- function() {
	selected <- sample(nobel$year, n_read + n_unknown)
	list(
		treatment = selected[1 : n_read],
		control = selected[(n_read + 1) : (n_read + n_unknown)]
	)
}

model_dists <- c(
	'Uniform' = dist_years_uniform,
	'Random Nobel years' = dist_years_nobel,
	'Partition on Nobel years' = dist_years_partition
)


mcks <- multi_monte_carlo_ks(model_dists, 10000)
model_factor <- factor(mcks$model)
ggplot(mcks, aes(x = ks, y= ..count.. / sum(..count..), fill = model_factor)) +
	geom_histogram(color = 'black') +
	facet_wrap(model_factor, dir = 'v') +
	geom_vline(aes(xintercept = measured_nobel_ks), color = 'black') +
	labs(title = 'Kolmogorov-Smirnov statistic distribution') +
	xlab('Kolmogorov-Smirnov value') +
	ylab('Probability') +
	scale_fill_brewer(palette = palette_name) +
	common_theme

# Probability of actual data
print(paste('Probability of randomly generating Kolmogorov-Smirnov statistic >=', measured_nobel_ks))
for (name in names(model_dists)) {
	samples <- subset(mcks, model == name)$ks
	p <- sum(samples >= measured_nobel_ks) / length(samples)
	print(c(name, p))
}
