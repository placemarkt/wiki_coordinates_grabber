const zlib = require("zlib"); 
var fs = require('fs');
JSONStream = require('JSONStream')
var es = require('event-stream')

var unzip = zlib.createUnzip();
var inp = fs.createReadStream('latest-all.json.gz');
var out = fs.createWriteStream('output.json');

inp.pipe(unzip).pipe(JSONStream.parse('.')).pipe(es.mapSync(function (article) {
	try {
		let id, title, lat, lng, description
		if (article.sitelinks 
			&& article.sitelinks.enwiki
			&& article.claims 
			&& article.claims.P625) {
			id = article.id
			title = article.sitelinks.enwiki.title
			lat = article.claims.P625[0].mainsnak.datavalue.value.latitude
			lng = article.claims.P625[0].mainsnak.datavalue.value.longitude
			if (article.descriptions && article.descriptions.en) {
				description = article.descriptions.en.value 
				if (typeof description === 'undefined') {
					description = ""
				}
			}
			console.log(`"${id}", "${title}", "${lat}", "${lng}", "${description}"`)
		}

	} catch (error) {
		console.log(`ERROR: ${error.code} - ${error.message}`)
	}
})
)
