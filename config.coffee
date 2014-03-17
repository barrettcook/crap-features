nameFilter = (regex) ->
    (file) ->
        regex.test(file.$.name)

module.exports =
    jenkins:
        host: 'http://yourjenkinshost.com'
        path: '/job/<job-name>/lastSuccessfulBuild/artifact/output/coverage.clover.xml'
    features:
        Feature1: (file) ->
            /feature1/.test(file.$.name)
        Feature2: (file) ->
            /feature2/.test(file.$.name)
