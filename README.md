# MELANOBS website

Quarto (R) site, English with a French version under `/fr`, published on GitHub Pages at https://melanobs.net.

## Work locally
1. Install Quarto, then in R: `install.packages(c("leaflet", "readr", "knitr", "rmarkdown"))`
2. `quarto preview`
3. Edit the `.qmd` pages (English at the root, French in `fr/`) and the CSV files in `data/`.

## First publication
1. Create a GitHub repository and push this folder (branch `main`).
2. Locally, once: `quarto publish gh-pages` (creates the `gh-pages` branch).
3. On GitHub: Settings > Pages > branch `gh-pages`, folder `/ (root)`, custom domain `melanobs.net`, tick "Enforce HTTPS".
4. At your domain registrar, create four A records for `melanobs.net` pointing to 185.199.108.153, 185.199.109.153, 185.199.110.153 and 185.199.111.153 (check these in the GitHub Pages docs).

After that, every push to `main` republishes the site.
