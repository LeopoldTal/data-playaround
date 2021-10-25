data {
  int<lower=1> N;
  vector[N] growth;
  vector[N] vote;
}
parameters {
  real constant_vote;
  real coeff_growth;
  real<lower=0> noise;
}
transformed parameters {
  vector[N] expected_vote = constant_vote + coeff_growth * growth;
}
model {
  vote ~ normal(expected_vote, noise);
}
