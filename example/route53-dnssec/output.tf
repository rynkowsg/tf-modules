output "data" {
  value = module.dnssec_example_com
}

# The module returns, among other values, a DNSSEC signing public key.
# This key must be manually added to the registrar's configuration at Route 53.
# Without this step, DNSSEC will not function correctly.
# As of now, this step cannot be automated.
