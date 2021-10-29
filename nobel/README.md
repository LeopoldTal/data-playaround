# Nobel literature prizes

## Motivation

I've heard of and read many Nobel literature prize winners, but not others. Some have become obscure with time, some are recent and not really classics yet. Does time of Nobel prize influence what I know about?

## Data

I went through Wikipedia's [list of literature Nobel laureates](https://en.wikipedia.org/wiki/List_of_Nobel_laureates_in_Literature#Laureates) from 1901 through 2021. For each of them, I marked whether I've heard of them, and whether I've read them.

Summary:

|          | Heard of | Not heard of | Total |
|----------|---------:|-------------:|------:|
| Read     |       29 |   1 (really) |    30 |
| Not read |       17 |           71 |    88 |
| Total    |       46 |           78 |   118 |


## Look at me I doin stats

### Binary: known vs unknown

Two groups: Authors I don't know from Adam, vs those I've heard of or read.

![Strip chart: Literature Nobel winners vs whether I've heard of them](./nobel_binary.png)

There's no obvious pattern in the plot, and indeed **Cohen's d is -0.07**: no effect to speak of.

### Ternary: read vs heard of vs unknown

Three groups: Authors I don't know from Adam, vs those I've only heard of, vs those I've read.

![Strip chart: Literature Nobel winners vs whether I've heard of or read them](./nobel_ternary.png)

A pattern appears: Looks like I'm likely to have read authors who won the Nobel around the 1950s. This is right smack in the middle of the range, so Cohen's d won't help much, but let's compute it anyway, for funsies:

| Comparison          | Cohen's d |
|---------------------|----------:|
| Read vs unknown     |     -0.06 |
| Read vs heard of    |      0.03 |
| Heard of vs unknown |     -0.08 |


Fat load o' nothing, as expected. Let's bin them by decade and draw a histogram:

![Histogram: Literature Nobel winners unknown to me vs heard of vs read, by decade](./nobel_histogram.png)

Yep, definitely a bump in read authors near 1950, and a corresponding trough in unknown authors. This could be a real effect: Maybe the lack of Nobels during World War 2 means harsher selection for famous authors afterwards. Maybe I'm a 1950s kid. Or could it all be… a coincidence? Dun dun dun.

### Some Russian guys to the rescue

Are Nobel years for authors I read, and those for authors I don't know, drawn from the same random distribution, with this small cluster popping up by sheer chance? Or are those I've read genuinely more concentrated around 1950? The [Kolmogorov-Smirnov test](https://en.wikipedia.org/wiki/Kolmogorov%E2%80%93Smirnov_test) measures exactly that.

![Cumulative distribution functions of unknown vs read Nobel years](./nobel_ks.png)

The Kolmogorov-Smirnov statistic for Nobel prize authors is **0.21**. …um, okay? Is that a lot or not?

Well, how likely is that to happen if the two distributions are the same? I could compute it, but computations are for computers.

### Monte Carlo

Plan:

* Choose a distribution that will model the distribution of Nobel years.
* Generate two samples from this distribution: one with 30 points, modelling read authors; and one with 71, modelling unknown authors.
* Compute the Kolmogorov-Smirnov statistic for these samples.
* Repeat a bunch of times, and measure the probability of getting at least 0.21.

This measures the (un)likelihood that our actual 1950s-Nobel bump is due to chance.

There are a few different ways to model the distribution:

* Uniform: Pick integer years in {1901…2021}.
* Uniform over Nobel years: Pick integer years in {1901…2021}, but exclude years with no laureate, and double-count years with two laureates.
* Partition: Get all the Nobel years, and randomly assign them to read vs unknown.

![Model-generated distributions of Kolmogorov-Smirnov statistic](./nobel_monte_carlo.png)

With all 3 models, the probability of randomly generating samples with a Kolmogorov-Smirnov statistic at least equal to that of the real data (0.21) is large: 22% for the first two models, and 25% for the partition model. So it's likely that the apparent pattern in the real Nobel data is just coincidence.

## Conclusion

Nope, nothing interesting here.
