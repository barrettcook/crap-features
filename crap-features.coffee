_ = require 'underscore'
http = require 'https'
{parseString} = require 'xml2js'
fs = require 'fs'
{Stats} = require 'fast-stats'
config = require './config'

sum = (memo, num) ->
    memo + parseInt(num,10)

# Fetch code coverage xml from jenkins
req = http.get config.jenkins, (res) ->
    res.setEncoding('utf8')
    data = ''
    res.on 'data', (chunk) ->
        data += chunk
    res.on 'end', () ->
        # parse the xml
        parseString data, (error, result) ->
            # Dive down into the files
            result = result.coverage.project[0].file

            # Start bucketing based on features
            # A naive filter would simply look at the filename and group
            #   based on the path to a file.
            _.each config.features, (filter, feature) ->
                # Filter out only the files we care about
                files = _.filter result, filter

                # Grab the total lines of code for this feature
                elements = _.chain(files)
                    .map (file) ->
                        file.metrics[0].$.elements
                    .flatten()
                    .value()
                linesOfCode = _.reduce elements, sum, 0

                # Extract only the methods,
                #   since they're the only ones with CRAP scores
                methods = _.chain(files)
                    .map (file) ->
                        _.filter file.line, (line) ->
                            line.$.type == 'method'
                    .flatten()
                    .filter (method) ->
                        !!method.$
                    .value()
                numMethods = methods.length

                # Grab all of the crap scores
                craps = _.map methods, (method) ->
                    parseInt(method.$.crap,10)
                craps = craps.sort()

                # Bucketize
                distribution = {};
                _.each craps, (crap) ->
                    if !distribution[crap]
                        distribution[crap] = 0
                    distribution[crap]++

                # Bucketize again (using the amazing Stats lib)
                s = new Stats({
                    # buckets: [5, 10, 50, 100, 1000, 1000000]
                    bucket_precision: 1
                })
                s.push(craps)

                # Send all the results to stdout
                console.log feature + "\n========="
                console.log 'Files:  ' + files.length
                console.log 'Methods ' + numMethods
                console.log 'Median: ' + s.median()
                console.log 'Mean:   ' + parseInt(s.amean(),10)
                console.log '95th:   ' + s.percentile(95)
                a = _.filter distribution, (v, k) ->
                    k > 30
                console.log '% > 30: ' + parseInt(a.length * 100 / files.length,10)
                console.log 'Distribution'
                _.each distribution, (v, k) ->
                    console.log "\t" + k + "\t" + v

                # console.log 's(crap) ' + crap
                # dist = s.distribution()
                # crap = _.reduce craps, sum, 0
                # console.log linesOfCode
                # console.log crap / linesOfCode
                # console.log 'Mean:   ' + crap / numMethods
                console.log "\n\n"

req.on 'error', (e) ->
    console.log('problem with request: ' + e.message)

req.end()
