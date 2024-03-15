[![Export](https://github.com/sphiria/gbf-wiki-popular-pages/actions/workflows/export.yaml/badge.svg)](https://github.com/sphiria/gbf-wiki-popular-pages/actions/workflows/export.yaml)

# gbf-wiki-popular-pages

This repository is a simple automation that pulls top 10 visited pages in [gbf.wiki] from Cloudflare analytics
and exports it to the wiki.  


<br>
<p align="center"><img src="https://github.com/sphiria/gbf-wiki-popular-pages/assets/25855364/54007361-4c2f-4704-9cb7-f1050e49b1d4" width="700"></p>
<br>

## Local Usage
```
# Input necessary secrets
vim run.sh

# Run it
./run.sh
```

## Technical Details
The top 10 page data is fetched from Cloudflare GraphQL API via `01-fetch-top-pages.js`.  
This is simply passed as an input to `02-write-to-wiki.sh` which saves it to [`PopularPages`] page in the wiki.

This is then used by [`{{MainPage/PopularPages}}`] to be shown in the frontpage.

The workflow runs daily, and uses data from the last 7 days. 

[gbf.wiki]: https://gbf.wiki
[`PopularPages`]: https://gbf.wiki/PopularPages
[`{{MainPage/PopularPages}}`]: https://gbf.wiki/Template:MainPage/PopularPages
