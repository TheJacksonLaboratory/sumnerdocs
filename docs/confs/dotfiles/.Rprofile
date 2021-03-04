## Read following
## https://stat.ethz.ch/R-manual/R-devel/library/base/html/Startup.html
## https://support.rstudio.com/hc/en-us/articles/360047157094-Managing-R-with-Rprofile-Renviron-Rprofile-site-Renviron-site-rsession-conf-and-repos-conf

## set user specific env variables, e.g., GITHUB_PAT here
Sys.setenv("plotly_username"="foo")
Sys.setenv("plotly_api_key"="blahblahblahblahblahblahblahblahblahblah")
Sys.setenv("GITHUB_PAT"="blahblahblahblahblahblahblahblahblahblah")

## load specific shared lib if R package throws an error
# dyn.load("/projects/foo/anaconda/v4.2.0/lib/libssl.so")

## Default source to download packages
local({
  r <- getOption("repos")
  r["CRAN"] <- "https://cran.rstudio.com"
  options(repos = r)
})

## end ##

