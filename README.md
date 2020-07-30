# Wiki Coordinates Grabber

A script to grab coordinates listed on wikipedia pages, returning a csv formatted file containing article id, title, and GSP coordinate.

## Installation

The grabber uses a combination of bash and C, along with a couple of command line utilities you'll need to make sure you have installed:

- `xmlstarlet`
- `GeoConvert`
- `dd`
- `Ag`

You'll also need to download `enwiki-latest-pages-articles-multistream-index.txt.bz2` and `enwiki-latest-pages-articles-multistream.xml.bz2` from the [wikipedia data dumps page](https://dumps.wikimedia.org/enwiki/latest/). The later can take some time.

## Use

1. Unzip the multistream index.
2. Update the multistream index and xml file names in the bash script. Depending on what file version you use these file names might be different.
3. Run the `get_location_articles` command from the command line.

## Contributing

Contributions welcome. Be nice.
