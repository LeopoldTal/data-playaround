# Tarantino swears

![Quentinen and Tarantined by Writtin Directino](credits.jpg)

Inexplicably, 538 has a [tally of swears and deaths](https://fivethirtyeight.com/features/complete-catalog-curses-deaths-quentin-tarantino-films/) across seven Quentin Tarantino movies. It takes over ten minutes to [say the full list of swears](poetry.mp3).

## What swears are used?

The tally lists **1704 total swears** and **60 unique swears**.

![Most frequent swears](top_swears.png)

A few of them appear many times: _fucking_ has a comfortable lead with 407 occurrences, nearly a quarter of all swears. It is followed by _shit_ and _fuck_, both used a little over 200 times. Mr. Tarantino's reputation for loving the N-word is borne out by the data: it ranks fourth, with 179 occurrences.

Conversely, 25 swears are said only once, of which my favourite is _cockblockery_, used in _Kill Bill_.

![Most frequent swears by movie](top_by_movie.png)

Earlier movies have far more swears than later one (discussed in more detail in the original article). N-word prevalence is largely driven by _Django Unchained_ (as expected from the setting and plot), but remains high in other movies.

## How is swear frequency distributed?

### Usual word frequency distributions

Word frequency in a corpus often follows a [Zipf](https://en.wikipedia.org/wiki/Zipf%27s_law) or [Yule-Simon](https://en.wikipedia.org/wiki/Yule%E2%80%93Simon_distribution) distribution.

![Distribution of all swears](all_swears.png)

Swear frequency in the Tarantino corpus drops off fast as rank increases, suggesting it may also follow such a law. Let's try to fit Zipf's law:

![Distribution of all swears and Zipf fit](log_zipf.png)

The fit is very poor: the top swears are much less frequent than Zipf's law would predict. I also tried excluding swears only used once (very noisy, since their frequency is quantised), with little change.

Minimising the square error (in log space) between a Yule-Simon distribution and the actual swear distribution finds a best fit parameter ρ = 0.820.

![Distribution of all swears and Yule-Simon fit](log_yule.png)

However, the fit is still poor. Excluding swears used once yields similar results. This shows that Tarentinian swears are not distributed like overall English words.

### Fitting an empirical distribution

The [Zipf-Mandelbrot](https://en.wikipedia.org/wiki/Zipf%E2%80%93Mandelbrot_law) law is sometimes used to model a flatter distribution at the top ranks, just like we observe in this dataset. Fitting such a law yields

```
frequency ∝ (rank + 7.97)^-3.63
```

![Distribution of all swears and Zipf-Mandelbrot fit](zm_transform.png) ![Same in log scale](zm_log.png)

A pretty good fit! But there are 3 free parameters, and still some systematic deviation at low rank, so I suspect overfitting.

After trying to fit any random relations I can come up with, it turns out that the rank is proportional to the square log of the frequency. What could produce this? Search me.

![Swear rank vs square log of relative frequency](custom_fit.png)

### Distribution within each movie

Do these laws actually model the distribution well, or are they pure overfitting? We can validate them against the distribution of swears in each movie.

![Distribution of swears within each movie](distrib_by_movie.png)

Swears in each movie follow a similar distribution law, except for _Reservoir Dogs_, where the distribution is much flatter, with 5 different swears used 12 or 13 times. Moreover, the _Kill Bill_ movies have far fewer swears, and so provide little data on the bottom ranks.

![Distribution of swears by movie and Zipf-Mandelbrot fit](zm_transform_by_movie.png) ![Same in log scale](zm_log_by_movie.png)

Distributions for individual movies agree reasonably well with the Zipf-Mandelbrot distribution fit on the overall data, though they tend to fall off slightly faster than predicted.

![Swear rank vs square log of relative frequency, by movie](custom_fit_by_movie.png)

Likewise, the square log of the frequency predicts the actual distribution fairly well, but underestimates fall-off speed.
