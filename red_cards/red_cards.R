cardsBySkinColour1 <- football %>% filter(!is.na(meanSkinColour)) %>%
	group_by(rater1) %>% summarize(count = n(), meanRedCards = mean(totalReds), sdCards = sd(totalReds))
cardsBySkinColour2 <- football %>% filter(!is.na(meanSkinColour)) %>%
	group_by(rater2) %>% summarize(count = n(), meanRedCards = mean(totalReds), sdCards = sd(totalReds))
ggplot() +
	geom_smooth(data = cardsBySkinColour1, aes(x = rater1, y = meanRedCards), method = 'lm', color = 'blue', fill = 'blue') +
	geom_smooth(data = cardsBySkinColour2, aes(x = rater2, y = meanRedCards), method = 'lm', color = 'green', fill = 'green') +
	geom_point(data = cardsBySkinColour1, aes(x = rater1, y = meanRedCards), color = 'blue') +
	geom_point(data = cardsBySkinColour2, aes(x = rater2, y = meanRedCards), color = 'green') +
	labs(title = 'Total red cards vs skin colour') +
	xlab('Skin colour (light to dark)') + ylab('Mean total red cards received') +
	theme(plot.title = element_text(hjust = 0.5))

redsBySkinColour1 <- football %>% filter(!is.na(meanSkinColour)) %>%
	group_by(rater1) %>% summarize(count = n(), meanRedCards = mean(redCards), sdCards = sd(redCards))
redsBySkinColour2 <- football %>% filter(!is.na(meanSkinColour)) %>%
	group_by(rater2) %>% summarize(count = n(), meanRedCards = mean(redCards), sdCards = sd(redCards))
ggplot() +
	geom_smooth(data = redsBySkinColour1, aes(x = rater1, y = meanRedCards), method = 'lm', color = 'blue', fill = 'blue') +
	geom_smooth(data = redsBySkinColour2, aes(x = rater2, y = meanRedCards), method = 'lm', color = 'green', fill = 'green') +
	geom_point(data = redsBySkinColour1, aes(x = rater1, y = meanRedCards), color = 'blue') +
	geom_point(data = redsBySkinColour2, aes(x = rater2, y = meanRedCards), color = 'green') +
	labs(title = 'Direct red cards vs skin colour') +
	xlab('Skin colour (light to dark)') + ylab('Mean direct red cards received') +
	theme(plot.title = element_text(hjust = 0.5))

yrBySkinColour1 <- football %>% filter(!is.na(meanSkinColour)) %>%
	group_by(rater1) %>% summarize(count = n(), meanRedCards = mean(yellowReds), sdCards = sd(yellowReds))
yrBySkinColour2 <- football %>% filter(!is.na(meanSkinColour)) %>%
	group_by(rater2) %>% summarize(count = n(), meanRedCards = mean(yellowReds), sdCards = sd(yellowReds))
ggplot() +
	geom_smooth(data = yrBySkinColour1, aes(x = rater1, y = meanRedCards), method = 'lm', color = 'blue', fill = 'blue') +
	geom_smooth(data = yrBySkinColour2, aes(x = rater2, y = meanRedCards), method = 'lm', color = 'green', fill = 'green') +
	geom_point(data = yrBySkinColour1, aes(x = rater1, y = meanRedCards), color = 'blue') +
	geom_point(data = yrBySkinColour2, aes(x = rater2, y = meanRedCards), color = 'green') +
	labs(title = 'Yellow-red cards vs skin colour') +
	xlab('Skin colour (light to dark)') + ylab('Mean yellow-red cards received') +
	theme(plot.title = element_text(hjust = 0.5))

yellowsBySkinColour1 <- football %>% filter(!is.na(meanSkinColour)) %>%
	group_by(rater1) %>% summarize(count = n(), meanRedCards = mean(yellowCards), sdCards = sd(yellowCards))
yellowsBySkinColour2 <- football %>% filter(!is.na(meanSkinColour)) %>%
	group_by(rater2) %>% summarize(count = n(), meanRedCards = mean(yellowCards), sdCards = sd(yellowCards))
ggplot() +
	geom_smooth(data = yellowsBySkinColour1, aes(x = rater1, y = meanRedCards), method = 'lm', color = 'blue', fill = 'blue') +
	geom_smooth(data = yellowsBySkinColour2, aes(x = rater2, y = meanRedCards), method = 'lm', color = 'green', fill = 'green') +
	geom_point(data = yellowsBySkinColour1, aes(x = rater1, y = meanRedCards), color = 'blue') +
	geom_point(data = yellowsBySkinColour2, aes(x = rater2, y = meanRedCards), color = 'green') +
	labs(title = 'Yellow cards vs skin colour') +
	xlab('Skin colour (light to dark)') + ylab('Mean yellow cards received') +
	theme(plot.title = element_text(hjust = 0.5))

lm(formula = cardsBySkinColour1$meanRedCards ~ cardsBySkinColour1$rater1)
lm(formula = cardsBySkinColour2$meanRedCards ~ cardsBySkinColour2$rater2)

x <- c(cardsBySkinColour1$rater1, cardsBySkinColour2$rater2)
y <- c(cardsBySkinColour1$meanRedCards, cardsBySkinColour2$meanRedCards)
reg <- lm(formula = y ~ x)

whitePlayer <- reg[[1]][[1]]
blackPlayer <- reg[[1]][[1]] + reg[[1]][[2]]

blackPlayer / whitePlayer
