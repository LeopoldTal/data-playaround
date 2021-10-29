# Kolmogorov-Smirnov statistic

# TODO: super inefficient, make it linear
cdf <- function(samples) {
	samples <- sort(samples)
	n <- length(samples)
	get_point_cdf <- function(x) {
		sum(samples <= x) / n
	}
	function(xs) {
		sapply(xs, get_point_cdf)
	}
}
ks <- function(treatment, control) {
	treatment_cdf <- cdf(treatment)
	control_cdf <- cdf(control)
	all_values = sort(c(treatment, control))
	ks_gaps <- treatment_cdf(all_values) - control_cdf(all_values)
	max(abs(ks_gaps))
}

plot_ks <- function(
	treatment, control,
	values_label = 'Distribution values',
	treatment_label = 'Treatment', control_label = 'Control'
	) {
	treatment_cdf <- cdf(treatment)
	control_cdf <- cdf(control)
	all_values = sort(c(treatment, control))
	cdf_treatment <- treatment_cdf(all_values)
	cdf_control <- control_cdf(all_values)
	
	ks_gaps <- cdf_treatment - cdf_control
	max_gap_index <- which.max(abs(ks_gaps))
	max_gap_value <- all_values[max_gap_index]
	max_gap_treatment <- treatment_cdf(max_gap_value)
	max_gap_control <- control_cdf(max_gap_value)
	max_gap_size <- abs(ks_gaps[max_gap_index])
	
	ks_data <- data.frame(all_values, cdf_treatment, cdf_control)
	
	ggplot(ks_data) +
		geom_line(aes(x = all_values, y = cdf_treatment, color = treatment_label)) +
		geom_line(aes(x = all_values, y = cdf_control, color = control_label)) +
		geom_segment(aes(
			x = max_gap_value, xend = max_gap_value,
			y = max_gap_treatment, yend = max_gap_control
		), color = 'black') +
		geom_text(
			aes(label = round(max_gap_size, 2), x = max_gap_value, y = (max_gap_treatment + max_gap_control) / 2),
			nudge_x = .05 * (max(all_values) - min(all_values))
		) +
		scale_color_manual(name = 'CDF', values = setNames(c('blue', 'red'), c(treatment_label, control_label))) +
		xlab(values_label) +
		ylab('Cumulative distribution') +
		labs(title = paste('Kolmogorov-Smirnov test:', values_label)) +
		theme(legend.position = c(0.8, 0.2), plot.title = element_text(hjust = 0.5))
}

# FIXME: linear version should look like this but this is full of boundary bugs, fix it
optimised_ks <- function(treatment, control) {
	treatment <- sort(treatment)
	control <- sort(control)
	
	nt <- length(treatment)
	nc <- length(control)
	max_gap <- 0
	treatment_index <- 1
	for(control_index in 1 : nc) {
		control_sample <- control[control_index]
		while(treatment_index < nt && treatment[treatment_index] < control_sample) {
			treatment_index <- treatment_index + 1
		}
		cum_control <- control_index / nc
		cum_treatment <- treatment_index / nt
		gap <- abs(cum_treatment - cum_control)
		if (gap > max_gap) {
			max_gap <- gap
		}
	}
	max_gap
}

monte_carlo_ks <- function(model_dist, nb_runs = 1000) {
	single_run <- function(run_index) {
		samples <- model_dist()
		ks(samples$treatment, samples$control)
	}
	sapply(1 : nb_runs, single_run)
}

multi_monte_carlo_ks <- function(model_dists, nb_runs = 1000) {
	all_runs <- data.frame()

	for (name in names(model_dists)) {
		runs <- monte_carlo_ks(model_dist = model_dists[[name]], nb_runs = nb_runs)
		runs_frame <- data.frame(ks = runs, model = name)
		all_runs <- rbind(all_runs, runs_frame)
	}

	all_runs
}
