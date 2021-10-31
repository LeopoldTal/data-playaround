# Top in movie (not used but interesting)
local_top_swears_in_movie <- function(raw_swears, movie_title, nb_top_swears = 6) {
	swear_set <- subset(raw_swears, type == 'word') %>%
		group_by(word) %>%
		summarise(count = n()) %>%
		arrange(desc(count))
	
	top_swears <- slice_max(swear_set, swear_set$count, n = nb_top_swears) %>% select(word, count)
	other_count <- filter(swear_set, !(word %in% top_swears$word))$count %>% sum
	
	binned_swears <- rbind(top_swears, data.frame(word = 'other', count = other_count))
	binned_swears <- binned_swears %>%
		mutate(percentage = 100 * count / sum(count), movie = movie_title)
	
	binned_swears
}

# Top overall, filtered by movie
global_top_swears_in_movie <- function(raw_swears, movie_title, top_swear_vec) {
	swear_set <- subset(raw_swears, type == 'word') %>%
		group_by(word) %>%
		summarise(count = n()) %>%
		arrange(desc(count))
	
	top_swears <- filter(swear_set, word %in% top_swear_vec) %>% select(word, count)
	other_count <- filter(swear_set, !(word %in% top_swear_vec))$count %>% sum
	
	binned_swears <- rbind(top_swears, data.frame(word = 'other', count = other_count))
	binned_swears <- binned_swears %>%
		mutate(percentage = 100 * count / sum(count), movie = movie_title)
	
	binned_swears
}

binned_by_movie <- data.frame() #global_top_swears_in_movie(tarantino, 'All', top_swears$word)
for (movie_title in levels(factor(tarantino$movie))) {
	movie_swears <- subset(tarantino, movie == movie_title)
	top <- global_top_swears_in_movie(movie_swears, movie_title, top_swears$word)
	binned_by_movie <- bind_rows(binned_by_movie, top)
}

movie_factor <- factor(binned_by_movie$movie, ordered = TRUE, levels = c(
	'All',
	'Reservoir Dogs',
	'Pulp Fiction',
	'Jackie Brown',
	'Kill Bill: Vol. 1',
	'Kill Bill: Vol. 2',
	'Inglorious Basterds',
	'Django Unchained'
))

word_factor = factor(
	binned_by_movie$word, ordered = TRUE,
	levels = c(as.character(top_swears$word), 'other')
)

ggplot(binned_by_movie, aes(x = movie_factor, y = count, fill = word_factor)) +
	geom_col() +
	scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
	scale_fill_brewer(palette = 'Set2', name = 'Swear') +
	labs(title = 'Most-used Tarantinian swears by movie') +
	ylab('Total occurrences') +
	bw_theme +
	theme(
		axis.title.y = element_text(angle = 0, margin = margin(r = -3, unit = 'cm')),
		axis.title.x = element_blank(),
		axis.text.x = element_text(angle = -70, size = 9, hjust = 0),
		legend.position = 'right',
	)

# Distribution by movie
rank_movie_swears <- function(movie_title) {
	movie_swears <- subset(tarantino, type == 'word' & movie == movie_title) %>%
		group_by(word) %>%
		summarise(count = n()) %>%
		arrange(desc(count))
	movie_swears$rank <- 1 : nrow(movie_swears)
	movie_swears$rel_freq <- movie_swears$count / sum(movie_swears$count)
	movie_swears$movie <- movie_title

	movie_swears
}
swears_by_movie <- swears
swears_by_movie$movie <- 'All'
for (movie_title in levels(factor(tarantino$movie))) {
	movie_swears <- rank_movie_swears(movie_title)
	swears_by_movie <- bind_rows(swears_by_movie, movie_swears)
}

ggplot(swears_by_movie, aes(x = log10(rank), y = log10(rel_freq), color = movie)) +
	geom_point(size = 2) +
	scale_x_continuous(
		expand = expansion(mult = c(0.01, 0.05))
	) +
	scale_y_continuous(
		expand = expansion(mult = c(0.05, 0.1))
	) +
	scale_color_brewer(palette = 'Dark2', direction = -1) +
	labs(title = 'Distribution of Tarantinian swears by movie') +
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
