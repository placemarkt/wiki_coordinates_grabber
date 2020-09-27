# Wiki Coordinates Grabber

A script to grab coordinates listed on Wikipedia pages, returning a csv formatted file containing article id, title, and lat/lng coordinate.

You can find the csv file generated by this script [here](https://github.com/placemarkt/wiki_coordinates). It's updated each month.

## Installation

The grabber uses a combination of bash and C, along with a couple of command line utilities you'll need to make sure you have installed:

- `xmlstarlet`
- `GeoConvert`
- `dd`
- `Ag`

You'll also need to download `enwiki-latest-pages-articles-multistream-index.txt.bz2` and `enwiki-latest-pages-articles-multistream.xml.bz2` from the [wikipedia data dumps page](https://dumps.wikimedia.org/enwiki/latest/). The later can take some time.

## Use

1. Unzip the multistream index.
2. Run the `get_location_articles` command from the command line.

## Contributing

Contributions welcome. Be nice.

## About Placemarkt

Placemarkt is a location bookmarking service for your favorite places. Check us out [here](https://placemarkt.net).
