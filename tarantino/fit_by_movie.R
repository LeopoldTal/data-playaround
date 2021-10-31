zm_expected <- data.frame(x = log10(swears$rank), tr_x = log10(swears$rank + best_param_zm), y = zm_expected_freq)

ggplot(swears_by_movie, aes(x = log10(rank + best_param_zm), y = log10(rel_freq), color = movie)) +
	geom_point(size = 2) +
	scale_x_continuous(
		expand = expansion(mult = c(0.01, 0.05))
	) +
	scale_y_continuous(
		expand = expansion(mult = c(0.05, 0.1))
	) +
	scale_color_brewer(palette = 'Dark2', direction = -1) +
	geom_line(data = zm_expected, aes(x = tr_x, y = y), color = 'darkgreen') +
	labs(title = 'Distribution of Tarantinian swears by movie\nZipf-Mandelbrot fit') +
	xlab(paste('log10(swear rank + ', best_param_zm, ')', sep = '')) +
	ylab('Relative frequency (log)') +
	bw_theme +
	theme(
		axis.title.y = element_text(angle = 0, margin = margin(r = -4, unit = 'cm')),
		legend.position = 'bottom',
		legend.title = element_blank(),
		legend.spacing.x = unit(0, 'pt'),
		legend.margin = margin(l = -1, unit = 'cm')
	)

ggplot(swears_by_movie, aes(x = log10(rank), y = log10(rel_freq), color = movie)) +
	geom_point(size = 2) +
	scale_x_continuous(
		expand = expansion(mult = c(0.01, 0.05))
	) +
	scale_y_continuous(
		expand = expansion(mult = c(0.05, 0.1))
	) +
	scale_color_brewer(palette = 'Dark2', direction = -1) +
	geom_line(data = zm_expected, aes(x = x, y = y), color = 'darkgreen') +
	labs(title = 'Distribution of Tarantinian swears by movie\nZipf-Mandelbrot fit') +
	xlab('Swear rank (log)') +
	ylab('Relative frequency (log)') +
	bw_theme +
	theme(
		axis.title.y = element_text(angle = 0, margin = margin(r = -4, unit = 'cm')),
		legend.position = 'bottom',
		legend.title = element_blank(),
		legend.spacing.x = unit(0, 'pt'),
		legend.margin = margin(l = -1, unit = 'cm')
	)

ggplot(swears_by_movie, aes(x = rank, y = log10(rel_freq)**2, color = movie)) +
	geom_point(size = 2) +
	scale_x_continuous(
		expand = expansion(mult = c(0.01, 0.05))
	) +
	scale_y_continuous(
		expand = expansion(mult = c(0.05, 0.1))
	) +
	scale_color_brewer(palette = 'Dark2', direction = -1) +
	labs(title = 'Distribution of Tarantinian swears by movie') +
	xlab('Swear rank') +
	ylab('log10(relative frequency)^2') +
	geom_smooth(method = 'lm', data = non_unique_swears, color = 'blue') +
	bw_theme +
	theme(
		axis.title.y = element_text(angle = 0, margin = margin(r = -4, unit = 'cm')),
		legend.position = 'bottom',
		legend.title = element_blank(),
		legend.spacing.x = unit(0, 'pt'),
		legend.margin = margin(l = -1, unit = 'cm')
	)


