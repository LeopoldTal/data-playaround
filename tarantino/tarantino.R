library(dplyr)
library(ggplot2)

tarantino <- read.csv('./tarantino/tarantino.csv', header = TRUE)

common_theme <- theme(plot.title = element_text(hjust = 0.5), legend.position = 'none')
bw_theme <- theme_bw() +
	common_theme +
	theme(
		axis.text = element_text(size = 11),
		axis.title.x = element_text(hjust = 1),
		panel.grid.minor.x = element_blank(),
		panel.border = element_blank()
	)

swears <- subset(tarantino, type == 'word') %>%
	group_by(word) %>%
	summarise(count = n()) %>%
	arrange(desc(count))
swears$rank <- 1 : nrow(swears)
swears$rel_freq <- swears$count / sum(swears$count)
non_unique_swears <- subset(swears, count > 1)

# Most-used swears
nb_top_swears <- 6
top_swears <- slice_max(swears, swears$count, n = nb_top_swears) %>% select(word, count, rank)

other_count <- filter(swears, !(word %in% top_swears$word))$count %>% sum
binned_swears <- rbind(top_swears, data.frame(word = 'other', count = other_count, rank = nb_top_swears + 1))
binned_swears <- binned_swears %>% mutate(percentage = 100 * count / sum(count))

ggplot(binned_swears, aes(x = 'Swear', y = percentage, fill = factor(rank))) +
	geom_col(width = 1) +
	geom_text(
		aes(label = paste(word, ' (', round(percentage, 1), '%)', sep = '')),
		position = position_stack(vjust = 0.5)
	) +
	scale_x_discrete(expand = expansion(add = 0)) +
	scale_y_continuous(expand = expansion(add = 0)) +
	scale_fill_brewer(palette = 'Set2') +
	labs(title = 'Most-used Tarantinian swears') +
	ylab('%') +
	common_theme +
	theme(
		axis.title.y = element_text(angle = 0, vjust = 0.5),
		axis.text.y = element_text(size = 10),
		axis.title.x = element_blank(),
		axis.ticks.x = element_blank(),
		axis.text.x = element_blank()
	)

source('./tarantino/by_movie.R', echo = TRUE)

# Distribution (lin scale)
ggplot(swears, aes(x = rank, y = count, fill = rank)) +
	geom_col(width = 1) +
	scale_fill_viridis_c(option = 'plasma') +
	scale_x_continuous(
		expand = expansion(mult = 0)
	) +
	scale_y_continuous(
		expand = expansion(mult = c(0, 0.05))
	) +
	labs(title = 'Overall distribution of Tarantinian swears') +
	xlab('Swear rank') +
	ylab('Total occurrences') +
	bw_theme +
	theme(
		axis.title.y = element_text(angle = 0, margin = margin(r = -2.5, unit = 'cm')),
		panel.grid.major.x = element_blank(),
	)

# Fit Zipf
ggplot(swears, aes(x = log10(rank), y = log10(rel_freq), color = rank)) +
	geom_smooth(method = 'lm', data = non_unique_swears) +
	geom_point() +
	scale_color_viridis_c(option = 'plasma') +
	scale_x_continuous(
		expand = expansion(mult = c(0.01, 0.05))
	) +
	scale_y_continuous(
		expand = expansion(mult = c(0.01, 0.1))
	) +
	labs(title = 'Overall distribution of Tarantinian swears') +
	xlab('Swear rank (log)') +
	ylab('Relative frequency (log)') +
	bw_theme +
	theme(
		axis.title.y = element_text(angle = 0, margin = margin(r = -3.5, unit = 'cm')),
	)

# Fit Yule-Simon
yule <- function(index, param) { param * beta(index, param + 1) }

get_yule_square_error <- function(param) {
	actual <- log10(non_unique_swears$rel_freq)
	expected <- log10(yule(non_unique_swears$rank, param))
	errors <- (actual - expected)**2
	sum(errors)
}
params_to_try <- seq(0.001, 5, 0.001)
best_param_yule <- params_to_try[which.min(sapply(params_to_try, get_yule_square_error))]

ggplot(swears) +
	geom_point(aes(x = log10(rank), y = log10(rel_freq), color = rank)) +
	scale_color_viridis_c(option = 'plasma') +
	geom_line(aes(x = log10(rank), y = log10(yule(rank, best_param_yule))), color = 'darkgreen') +
	scale_x_continuous(
		expand = expansion(mult = c(0.01, 0.05))
	) +
	scale_y_continuous(
		expand = expansion(mult = c(0.01, 0.1))
	) +
	geom_text(aes(
		label = paste('Yule-Simon best fit ρ =', best_param_yule),
		x = 0.1,
		y = log10(yule(1, best_param_yule)),
		hjust = 0
	), color = 'darkgreen') +
	labs(title = 'Overall distribution of Tarantinian swears') +
	xlab('Swear rank (log)') +
	ylab('Relative frequency (log)') +
	bw_theme +
	theme(
		axis.title.y = element_text(angle = 0, margin = margin(r = -3.5, unit = 'cm')),
	)

# idk just try weird transforms
ggplot(swears, aes(x = rank, y = log10(rel_freq)**2, color = rank)) +
	geom_smooth(method = 'lm', data = non_unique_swears) +
	geom_point() +
	scale_color_viridis_c(option = 'plasma') +
	scale_x_continuous(
		expand = expansion(add = c(1, 1))
	) +
	scale_y_continuous(
		expand = expansion(mult = c(0.01, 0.05))
	) +
	labs(title = 'Overall distribution of Tarantinian swears') +
	xlab('Swear rank') +
	ylab('log10(relative frequency)^2') +
	bw_theme +
	theme(
		axis.title.y = element_text(angle = 0, margin = margin(r = -4.5, unit = 'cm')),
	)

# Zipf-Mandelbrot
fit_zm <- function(data) {
	get_zm_square_error <- function(param) {
		y <- log10(data$rel_freq)
		x <- log10(data$rank + param)
		fit <- lm(y ~ x)
		sum(fit$residuals**2)
	}

	params_to_try <- seq(0, 50, 0.01)
	best_param_zm <- params_to_try[which.min(sapply(params_to_try, get_zm_square_error))]

	best_param_zm
}

best_param_zm <- fit_zm(non_unique_swears)

# Try excluding the #1 swear, see if there's a king effect. Doesn't seem to matter
#middle_swears <- subset(non_unique_swears, rank != 1)
#best_param_zm <- fit_zm(middle_swears)

ggplot(swears, aes(x = log10(rank + best_param_zm), y = log10(rel_freq), color = rank)) +
	geom_smooth(method = 'lm', data = non_unique_swears) +
	geom_point() +
	scale_color_viridis_c(option = 'plasma') +
	scale_x_continuous(
		expand = expansion(mult = c(0.01, 0.05))
	) +
	scale_y_continuous(
		expand = expansion(mult = c(0.01, 0.1))
	) +
	labs(title = 'Overall distribution of Tarantinian swears\nZipf-Mandelbrot fit') +
	xlab(paste('log10(swear rank + ', best_param_zm, ')', sep = '')) +
	ylab('log10(relative frequency)') +
	bw_theme +
	theme(
		axis.title.y = element_text(angle = 0, margin = margin(r = -4, unit = 'cm')),
	)

zm_fit <- lm(log10(non_unique_swears$rel_freq) ~ log10(non_unique_swears$rank + best_param_zm))
zm_expected_freq <- log10(swears$rank + best_param_zm)*zm_fit$coefficients[2] + zm_fit$coefficients[1]
ggplot(swears) +
	geom_point(aes(x = log10(rank), y = log10(rel_freq), color = rank)) +
	scale_color_viridis_c(option = 'plasma') +
	geom_line(aes(x = log10(rank), y = zm_expected_freq), color = 'darkgreen') +
	scale_x_continuous(
		expand = expansion(mult = c(0.01, 0.05))
	) +
	scale_y_continuous(
		expand = expansion(mult = c(0.01, 0.1))
	) +
	labs(title = 'Overall distribution of Tarantinian swears\nZipf-Mandelbrot fit') +
	xlab('Swear rank (log)') +
	ylab('Relative frequency (log)') +
	bw_theme +
	theme(
		axis.title.y = element_text(angle = 0, margin = margin(r = -3.5, unit = 'cm')),
	)

source('./tarantino/fit_by_movie.R', echo = TRUE)
