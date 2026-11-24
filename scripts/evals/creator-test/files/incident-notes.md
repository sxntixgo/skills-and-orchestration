#incidents channel export, 2026-11-12 (times are US/Mountain)

14:02 pagerduty: checkout-api error rate > 5%
14:04 maria: looking. 502s from checkout-api, started right after the 13:58 deploy
14:06 maria: deploy 4812 changed the payment-gateway timeout from 30s to 3s (config/payments.yaml)
14:09 tom: Bob pushed that config without review again...
14:11 maria: rolling back 4812
14:19 maria: rollback done, error rate back under 0.5%
14:25 li: ~12% of checkout requests failed between 13:58 and 14:19, about 1,900 orders. Payments that timed out were not charged.
14:31 tom: the config change went through the fast-path pipeline, which skips the integration tests
14:40 li: support got 37 tickets
