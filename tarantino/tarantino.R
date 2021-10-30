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

nb_top_swears <- 6
top_swears <- slice_max(swears, swears$count, n = nb_top_swears)
other_count <- filter(swears, !(word %in% top_swears$word))$count %>% sum
top_swears <- rbind(top_swears, data.frame(word = 'other', count = other_count, rank = nb_top_swears + 1))
top_swears <- top_swears %>% mutate(percentage = 100 * count / sum(count))

ggplot(top_swears, aes(x = 'Swear', y = percentage, fill = factor(rank))) +
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

ggplot(swears, aes(x = log10(rank), y = log10(count), color = rank)) +
	geom_smooth(method = 'lm') +
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
	ylab('Total occurrences (log)') +
	bw_theme +
	theme(
		axis.title.y = element_text(angle = 0, margin = margin(r = -3.5, unit = 'cm')),
	)
