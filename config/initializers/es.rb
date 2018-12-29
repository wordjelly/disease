host1 = {host: '8c8c4a8f1c5d41cda38b517c2407070b.us-east-1.aws.found.io', scheme: 'https', port: 9243}
host1.merge!({user: 'elastic', password: 'fM5mTFWHGkp2TfceF0dXgVz4'})

$remote_es_client = Elasticsearch::Client.new hosts: [ host1], headers: {"Content-Type" => "application/json" }, request: { timeout: 45 }

host = {host: 'localhost', scheme: 'http', port: 9200}

Elasticsearch::Persistence.client = Elasticsearch::Client.new hosts: [ host], headers: {"Content-Type" => "application/json" }, request: { timeout: 45 }
