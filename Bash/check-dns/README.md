# Overview

The `check-dns.sh` script can be used for performing basic DNS tests using `dig` against a given zone. These tests revolve around the various ways in which a query for a record can result in an undesired output (i.e. something other than 'NOERROR').

This directory includes the script itself along with a **required** YAML file that includes sections for the *what* (is to be queried), the *from* (where to query), and the *check* (that is to be performed on the output). Without passing a valid YAML file as a positional parameter to the script the script will not run as it does not have any information to go on when it comes to testing.

The fact that this is a YAML file is arbitrary as it is the easiest to parse in Bash compared to, for example, a JSON file, and I think it will provide the end user the easiest way to note down the things that are going to be checked.

The output of the script is printed to STDOUT in a *statsd* format, which can then be written to a file for consumption by whatever monitoring solution.

# Usage

The script expects three positional parameters in order to work properly:

`./check-dns.sh <input YAML file> <name of the zone being targeted> <to use single or multiple sets of endpoints>`

## The YAML file

Below is an example of the required YAML file and I've chosen the most complex (at first glance) as an example:

```yaml
# What to query
what:
  record1: '10.10.10.10'
  record2: '12.12.12.10'

# From where to query
from:
  record1:
    endpoint1: '10.10.10.11'
    endpoint2: '10.10.10.12'
    endpoint3: '10.10.10.13'
  record2:
    endpoint4: '12.12.12.11'
    endpoint5: '12.12.12.12'
    endpoint6: '12.12.12.13'

# What to check in the query response
check:
  'SERVFAIL'
  'REFUSED'
  'timed'
```

Though the blocks are commented here is how to read them:

- *what*: A key-value pair of what record you want to query with the desired target value you want to see in the result. The name of the zone being targeted will be appended to the key forming *record1.yourzone*
- *from*: A key-value pair of where you are querying from with the IP included to skip an additional `dig` query where the name of the endpoint would be needed to resolve as well. Here there are two sections, one for each *what*, and these are because for each *what* there is a different set of endpoints that are targeted
- *check*: An array of strings that are expected to see when testing a record. Each of these will be checked from the output of each query from each endpoint

If you do not want to define multiple sets of endpoints then do without the separate sections and just indent once (with two spaces) all the key-value pairs you want to query from and provide **single** as the third positional parameter for the script.

## Examples

Use the provided *dns.yaml* file as a source for input values, target the zone *yourzone*, and use a single set of endpoints to query from:

```bash
$ ./check-dns.sh dns.yaml yourzone single
response.servfail.endpoint1.record1_yourzone 0
response.refused.endpoint1.record1_yourzone 0
response.timed.endpoint1.record1_yourzone 0
response.servfail.endpoint2.record1_yourzone 0
response.refused.endpoint2.record1_yourzone 0
response.timed.endpoint2.record1_yourzone 0
response.servfail.endpoint3.record1_yourzone 0
response.refused.endpoint3.record1_yourzone 0
response.timed.endpoint3.record1_yourzone 0
overall.record1_yourzone 0
response.servfail.endpoint1.record2_yourzone 0
response.refused.endpoint1.record2_yourzone 0
response.timed.endpoint1.record2_yourzone 0
response.servfail.endpoint2.record2_yourzone 0
response.refused.endpoint2.record2_yourzone 0
response.timed.endpoint2.record2_yourzone 0
response.servfail.endpoint3.record2_yourzone 0
response.refused.endpoint3.record2_yourzone 0
response.timed.endpoint3.record2_yourzone 0
overall.record2_yourzone 0
response.servfail.endpoint1.record3_yourzone 0
response.refused.endpoint1.record3_yourzone 0
response.timed.endpoint1.record3_yourzone 0
response.servfail.endpoint2.record3_yourzone 0
response.refused.endpoint2.record3_yourzone 0
response.timed.endpoint2.record3_yourzone 0
response.servfail.endpoint3.record3_yourzone 0
response.refused.endpoint3.record3_yourzone 0
response.timed.endpoint3.record3_yourzone 0
overall.record3_yourzone 0
```

## Reading the output

Usually things are all okay (as witnessed by all the zeroes in the example above), but sometimes things go awry. Below is an example of when things break and how to read that output:

```bash
$ ./check-dns.sh dns.yaml yourzone single
response.servfail.endpoint1.record1_yourzone 0
response.refused.endpoint1.record1_yourzone 0
response.timed.endpoint1.record1_yourzone 0
response.servfail.endpoint2.record1_yourzone 0
response.refused.endpoint2.record1_yourzone 0
response.timed.endpoint2.record1_yourzone 0
response.servfail.endpoint3.record1_yourzone 1
response.refused.endpoint3.record1_yourzone 0
response.timed.endpoint3.record1_yourzone 0
overall.record1_yourzone 1
response.servfail.endpoint1.record2_yourzone 0
response.refused.endpoint1.record2_yourzone 0
response.timed.endpoint1.record2_yourzone 0
response.servfail.endpoint2.record2_yourzone 0
response.refused.endpoint2.record2_yourzone 0
response.timed.endpoint2.record2_yourzone 0
response.servfail.endpoint3.record2_yourzone 1
response.refused.endpoint3.record2_yourzone 0
response.timed.endpoint3.record2_yourzone 0
overall.record2_yourzone 1
response.servfail.endpoint1.record3_yourzone 0
response.refused.endpoint1.record3_yourzone 0
response.timed.endpoint1.record3_yourzone 0
response.servfail.endpoint2.record3_yourzone 0
response.refused.endpoint2.record3_yourzone 0
response.timed.endpoint2.record3_yourzone 0
response.servfail.endpoint3.record3_yourzone 1
response.refused.endpoint3.record3_yourzone 0
response.timed.endpoint3.record3_yourzone 0
overall.record3_yourzone 1
```

Here we can see that we are getting SERVFAIL for: 'record1.yourzone', 'record2.yourzone', and 'record3.yourzone' (dots are replaced with underscores for denoting the record). When this happened the script flipped the value 0 for the value 1 to highlight which endpoint returned that value. In this example 'endpoint3' endpoint is returning SERVFAIL for all the defined records (noted above) and the overall state for each defined record is no longer 0, meaning they are no longer healthy; this is the endpoint you should look into.
