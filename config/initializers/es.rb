Elasticsearch::Persistence.client = Elasticsearch::Client.new hosts: [ { host: 'localhost', port: 9200 }]
Hashie.logger = Logger.new('/dev/null')