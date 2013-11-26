_ = require 'underscore'
http = require 'https'
{parseString} = require 'xml2js'
fs = require 'fs'
{Stats} = require 'fast-stats'

options =
    host: 'ci.tagged.com'
    path: '/job/tagged-web-php-crap/lastSuccessfulBuild/artifact/output/coverage.clover.xml'

sum = (memo, num) ->
    memo + parseInt(num,10)

nameFilter = (regex) ->
    (file) ->
        regex.test(file.$.name)

features =
    Pets: nameFilter(/pets/i),
    User: nameFilter(/user/i),
    API: nameFilter(/api/i),
    Alerts: nameFilter(/(alerts|notification|push)/i),
    MeetMe: nameFilter(/meetme/i),
    Luv: nameFilter(/(luv|amor)/i),
    Feed: nameFilter(/newsfeed/i),
    Photos: nameFilter(/photo/i),
    Search: nameFilter(/search/i),
    Email: nameFilter(/email/i),
    Gold: nameFilter(/gold/i),

fs.readFile 'coverage.clover.xml', (err, data) ->
    parseString data, (error, result) ->
        result = result.coverage.project[0].file
        _.each features, (filter, feature) ->
            files = _.filter result, filter
            methods = _.map files, (file) ->
                _.filter file.line, (line) ->
                    line.$.type == 'method'
            elements = _.map files, (file) ->
                file.metrics[0].$.elements
            elements = _.flatten elements
            linesOfCode = _.reduce elements, sum, 0
            methods = _.flatten methods
            methods = _.filter methods, (method) ->
                !!method.$
            craps = _.map methods, (method) ->
                parseInt(method.$.crap,10)
            craps = craps.sort()
            distribution = {};
            _.each craps, (crap) ->
                if !distribution[crap]
                    distribution[crap] = 0
                distribution[crap]++
            s = new Stats({
                # buckets: [5, 10, 50, 100, 1000, 1000000]
                bucket_precision: 1
            })
            s.push(craps)
            numMethods = methods.length
            console.log feature + "\n========="
            console.log 'Files:  ' + files.length
            console.log 'Methods ' + numMethods
            console.log 'Median: ' + s.median()
            console.log 'Mean:   ' + parseInt(s.amean(),10)
            console.log '95th:   ' + s.percentile(95)
            a = _.filter distribution, (v, k) ->
                k > 30
            console.log '% > 30: ' + parseInt(a.length * 100 / files.length,10)
            # console.log 's(crap) ' + crap
            # dist = s.distribution()
            console.log 'Distribution'
            _.each distribution, (v, k) ->
                console.log "\t" + k + "\t" + v
            # crap = _.reduce craps, sum, 0
            # console.log linesOfCode
            # console.log crap / linesOfCode
            # console.log 'Mean:   ' + crap / numMethods
            console.log "\n\n"

# parseString data, (error, result) ->
#     console.log result
# req = http.get options, (res) ->
#     res.setEncoding('utf8')
#     data = ''
#     res.on 'data', (chunk) ->
#         data += chunk
#     res.on 'end', () ->
#         parseString data, (error, result) ->
#             console.log result
#         # data = JSON.parse data
#         # data = data.child
#         # durations = []
#         # _.each data, (child) ->
#         #     _.each child, (tests) ->
#         #         _.each tests, (test) ->
#         #             durations.push test
#         # durations = _.sortBy durations, (obj) ->
#         #     obj.duration * -1
#         # console.log durations

# req.on 'error', (e) ->
#     console.log('problem with request: ' + e.message)

# req.end()
